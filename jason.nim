import std/macros
import std/strutils

type
  Json = distinct string

  JasonObject = concept j
    for v in fields(j):
      jason(v) is Json

  JasonArray = concept j
    for v in j:
      jason(v) is Json

  Jasonable = concept j
    jason(j) is Json

# practically a bug that i have to export these!
proc add*(js: var Json; s: Json) {.borrow.}
proc `&`*(js: Json; s: Json): Json {.borrow.}

proc join*(a: openArray[Json]; sep = Json""): Json =
  for index, item in a:
    if index != 0:
      result.add sep
    result.add item

proc json(node: NimNode): NimNode =
  ## Convenience for Json(...)
  result = newCall(ident"Json", node)

proc json(node: string): NimNode =
  ## Convenience for Json"[]"
  result = json newLit(node)

func jason*(node: NimNode): NimNode =
  ## Convenience for jason(...)
  result = newCall(ident"jason", node)

macro jason*(js: Json): Json =
  result = js

macro jason*(s: string): Json =
  result = json newCall(ident"escape", s)

macro jason*(b: bool): Json =
  var cond = nnkElifExpr.newNimNode
  cond.add b
  cond.add json"true"

  var els = nnkElseExpr.newNimNode
  els.add json"false"

  result = nnkIfExpr.newNimNode
  result.add cond
  result.add els

func jason*(e: enum): Json =
  result = Json($ord(e))

func jason*(i: SomeInteger): Json =
  result = Json($i)

func jason*(f: SomeFloat): Json =
  result = Json($f)

proc composeWithComma(parent: NimNode; js: NimNode): NimNode =
  # whether we need to add a comma before the next element
  var comma = gensym(nskVar)
  parent.add newVarStmt(comma, ident"false")         # var comma = false

  var cond = nnkElifExpr.newNimNode
  cond.add comma                                     # if comma:
  cond.add ident"add".newCall(js, json",")           # js.add ","

  var toggle = nnkElseExpr.newNimNode                # else:
  toggle.add newAssignment(comma, ident"true")       # comma = true

  var sep = nnkIfExpr.newNimNode
  sep.add cond                                       # if comma: js.add ","
  sep.add toggle                                     # else: comma = true

  sep

macro jason*(a: JasonArray): Json =
  result = newStmtList()

  var js = gensym(nskVar)
  result.add newVarStmt(js, json"[")          # the leading [

  # make a loop over the items in the iterable
  let loop = block:
    var value = gensym(nskForVar)             # make loop var

    var body = nnkStmtList.newNimNode         # make body of a loop
    body.add composeWithComma(result, js)     # maybe add a separator
    body.add ident"add".newCall(js,           # add the json for value
                        value.jason)

    var loop = nnkForStmt.newNimNode          # for loop
    loop.add value                            # add loop var
    loop.add a                                # add any iterable
    loop.add body                             # add loop body

    loop

  result.add loop                             # add the loop
  result.add ident"add".newCall(js, json"]")  # add the trailing ]

  # the last statement in the statement list is the json
  result.add js

proc jasonCurly(o: NimNode): NimNode =
  result = newStmtList()

  var js = gensym(nskVar, "js")
  result.add newVarStmt(js, json"{")

  # make a loop over the items in the iterable
  let loop = block:
    var key = gensym(nskForVar, "key")             # loop var for key
    var val = gensym(nskForVar, "val")             # loop var for val

    var body = nnkStmtList.newNimNode              # make body of a loop
    body.add composeWithComma(result, js)          # maybe add a separator
    body.add ident"add".newCall(js, key.jason)     # "somekey" (json)
    body.add ident"add".newCall(js, json":")       # : (json)
    body.add ident"add".newCall(js, val.jason)     # someval (json)

    var loop = nnkForStmt.newNimNode               # make for loop
    loop.add key                                   # add key to the loop
    loop.add val                                   # add val to the loop
    loop.add newCall(ident"fieldPairs", o)         # object fieldPairs
    loop.add body                                  # loop body

    loop

  result.add loop                                  # add the loop
  result.add ident"add".newCall(js, json"}")       # add the trailing ]

  # the last statement in the statement list is the json
  result.add js

macro jason*(o: object): Json =
  result = jasonCurly(o)

macro jason*(o: tuple): Json =
  result = newStmtList()
  # first, stash the tuple temporarily
  let temp = gensym(nskLet)
  result.add newLetStmt(temp, o)

  let typ = o.getTypeInst
  if typ.kind != nnkTupleConstr:
    # use our object construction code for named tuples
    return jasonCurly(o)
  else:
    # it is a (34, "hello")-style anonymous tuple construction

    # arr will hold a list of strings we'll concatenate at the end
    var arr = newStmtList()
    # this is the left-bracket of the json array syntax, `[ ... ]`
    arr.add json"["
    # a nim array will serve as input to the join()
    var inf = newNimNode(nnkBracket)
    for index, sym in pairs(typ):
      # create an index expression for the temporary tuple, `:tmp[n]`
      var exp = newNimNode(nnkBracketExpr)
      # the :tmp in :tmp[3]
      exp.add temp
      # the 3 in :tmp[3]
      exp.add index.newLit # token[#] = token[#+1]
      # the jason() in jason(:tmp[3])
      inf.add exp.jason
    # now join the array with commas
    arr.add newCall(ident"join", inf, json",")
    # and add the trailing "]"
    arr.add json"]"

    # now fold the array with &
    result.add nestList(ident"&", arr)

func jason*(o: ref): Json =
  if o.isNil:
    result = Json"null"
  else:
    result = jason o[]

func `$`*(j: Json): string =
  result = j.string

# practically a bug that i have to export these!
export Json, escape
