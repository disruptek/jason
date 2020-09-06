import std/macros
import std/strutils

type
  Json* = distinct string   ## Serialized JSON.

  JasonObject = concept j
    for v in fields(j):
      v is Jasonable

  JasonArray = concept j
    for v in j:
      v is Jasonable

  Jasonable* = concept j   ## It should be serializable to JSON.
    jason(j) is Json

proc add(js: var Json; s: Json) {.borrow.}
proc `&`(js: Json; s: Json): Json {.borrow.}

proc join(a: openArray[Json]; sep = Json""): Json =
  for index, item in a:
    if index != 0:
      result.add sep
    result.add item

# these are copied from stdlib so that we can be certain we match output
# without having to import json and all of its dependencies...  i know.

proc escapeJsonUnquoted(s: string; result: var string) {.used.} =
  ## Converts a string `s` to its JSON representation without quotes.
  ## Appends to ``result``.
  for c in s:
    case c
    of '\L': result.add("\\n")
    of '\b': result.add("\\b")
    of '\f': result.add("\\f")
    of '\t': result.add("\\t")
    of '\v': result.add("\\u000b")
    of '\r': result.add("\\r")
    of '"': result.add("\\\"")
    of '\0'..'\7': result.add("\\u000" & $ord(c))
    of '\14'..'\31': result.add("\\u00" & toHex(ord(c), 2))
    of '\\': result.add("\\\\")
    else: result.add(c)

proc escapeJsonUnquoted(s: string): string {.used.} =
  ## Converts a string `s` to its JSON representation without quotes.
  result = newStringOfCap(s.len + s.len shr 3)
  escapeJsonUnquoted(s, result)

proc escapeJson(s: string; result: var string) =
  ## Converts a string `s` to its JSON representation with quotes.
  ## Appends to ``result``.
  result.add("\"")
  escapeJsonUnquoted(s, result)
  result.add("\"")

proc escapeJson(s: string): string =
  ## Converts a string `s` to its JSON representation with quotes.
  result = newStringOfCap(s.len + s.len shr 3)
  escapeJson(s, result)

proc json(node: NimNode): NimNode =
  ## Convenience for Json(...) in macros.
  result = newCall(ident"Json", node)

proc json(node: string): NimNode =
  ## Convenience for Json("[]") in macros.
  result = json newLit(node)

func jason*(node: NimNode): NimNode =
  ## Convenience for jason(...) in macros.
  result = newCall(ident"jason", node)

macro jason*(js: Json): Json =
  ## Idempotent Json handler.
  runnableExamples:
    let j = 3.jason
    let k = jason j
    assert $k == "3"

  result = js

macro jason*(s: string): Json =
  ## Escapes a string to form "JSON".
  runnableExamples:
    let j = jason"goats"
    assert $j == "\"goats\""

  let escapist = bindSym "escapeJson"
  result = json newCall(escapist, s)

macro jason*(b: bool): Json =
  ## Produce a JSON boolean, either `true` or `false`.
  runnableExamples:
    let j = jason(1 == 2)
    assert $j == "false"

  result = nnkIfExpr.newNimNode(b)
  result.add newTree(nnkElifExpr, b, json"true")
  result.add newTree(nnkElseExpr, json"false")

func jason*(e: enum): Json =
  ## Render any `enum` type as a JSON integer, by default.
  result = Json($ord(e))

func jason*(i: SomeInteger): Json =
  ## Render any Nim integer as a JSON integer.
  result = Json($i)

func jason*(f: SomeFloat): Json =
  ## Render any Nim float as a JSON number.
  result = Json($f)

when not defined(nimdoc):
  macro jason*(j: static[string]): Json = json newLit(j.jason.string)
  macro jason*(j: static[bool]): Json = json newLit(j.jason.string)
  macro jason*(j: static[int]): Json = json newLit(j.jason.string)
  macro jason*(j: static[int8]): Json = json newLit(j.jason.string)
  macro jason*(j: static[int16]): Json = json newLit(j.jason.string)
  macro jason*(j: static[int32]): Json = json newLit(j.jason.string)
  macro jason*(j: static[int64]): Json = json newLit(j.jason.string)
  macro jason*(j: static[uint]): Json = json newLit(j.jason.string)
  macro jason*(j: static[uint8]): Json = json newLit(j.jason.string)
  macro jason*(j: static[uint16]): Json = json newLit(j.jason.string)
  macro jason*(j: static[uint32]): Json = json newLit(j.jason.string)
  macro jason*(j: static[uint64]): Json = json newLit(j.jason.string)
  macro jason*(j: static[float]): Json = json newLit(j.jason.string)
  macro jason*(j: static[float32]): Json = json newLit(j.jason.string)

proc composeWithComma(parent: NimNode; js: NimNode): NimNode =
  # whether we need to add a comma before the next element
  let adder = bindSym "add"
  var comma = gensym(nskVar, "comma")
  parent.add newVarStmt(comma, ident"false")         # var comma = false

  var cond = nnkElifExpr.newNimNode
  cond.add comma                                     # if comma:
  cond.add adder.newCall(js, json",")                # js.add ","

  var toggle = nnkElseExpr.newNimNode                # else:
  toggle.add newAssignment(comma, ident"true")       # comma = true

  var sep = nnkIfExpr.newNimNode
  sep.add cond                                       # if comma: js.add ","
  sep.add toggle                                     # else: comma = true

  sep

macro jason*(a: JasonArray): Json =
  ## Render an iterable that isn't a named-tuple or object as a JSON array.
  runnableExamples:
    let j = jason [1, 3, 5, 7]
    assert $j == "[1,3,5,7]"

  let adder = bindSym "add"
  result = newStmtList()

  var js = gensym(nskVar, "js")
  result.add newVarStmt(js, json"[")          # the leading [

  # make a loop over the items in the iterable
  let loop = block:
    var value = gensym(nskForVar, "value")    # make loop var

    var body = nnkStmtList.newNimNode         # make body of a loop
    body.add composeWithComma(result, js)     # maybe add a separator
    body.add adder.newCall(js, value.jason)   # add the json for value

    var loop = nnkForStmt.newNimNode          # for loop
    loop.add value                            # add loop var
    loop.add a                                # add any iterable
    loop.add body                             # add loop body

    loop

  result.add loop                             # add the loop
  result.add adder.newCall(js, json"]")       # add the trailing ]

  # the last statement in the statement list is the json
  result.add js

proc jasonCurly(o: NimNode): NimNode =
  let adder = bindSym "add"
  result = newStmtList()

  var js = gensym(nskVar, "js")
  result.add newVarStmt(js, json"{")

  # make a loop over the items in the iterable
  let loop = block:
    var key = gensym(nskForVar, "key")             # loop var for key
    var val = gensym(nskForVar, "val")             # loop var for val

    var body = nnkStmtList.newNimNode              # make body of a loop
    body.add composeWithComma(result, js)          # maybe add a separator
    body.add adder.newCall(js, key.jason)          # "somekey" (json)
    body.add adder.newCall(js, json":")            # : (json)
    body.add adder.newCall(js, val.jason)          # someval (json)

    var loop = nnkForStmt.newNimNode               # make for loop
    loop.add key                                   # add key to the loop
    loop.add val                                   # add val to the loop
    loop.add newCall(ident"fieldPairs", o)         # object fieldPairs
    loop.add body                                  # loop body

    loop

  result.add loop                                  # add the loop
  result.add adder.newCall(js, json"}")            # add the trailing ]

  # the last statement in the statement list is the json
  result.add js

macro jason*(o: JasonObject): Json =
  ## Render an anonymous Nim tuple as a JSON array; objects and named
  ## tuples become JSON objects.
  runnableExamples:
    let j = jason (1, "two", 3.0)
    assert $j == """[1,"two",3.0]"""
    let k = jason (one: 1, two: "two", three: 3.0)
    assert $k == """{"one":1,"two":"two","three":3.0}"""

  let
    joiner = bindSym "join"
    ander = bindSym "&"
    typ = o.getTypeInst
  if typ.kind != nnkTupleConstr:
    # use our object construction code for named tuples, objects
    result = jasonCurly(o)
  else:
    # it is a (34, "hello")-style anonymous tuple construction
    result = newStmtList()
    # first, stash the tuple temporarily
    let temp = gensym(nskLet, "temp")
    result.add newLetStmt(temp, o)

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
    arr.add newCall(joiner, inf, json",")
    # and add the trailing "]"
    arr.add json"]"

    # now fold the array with &
    result.add nestList(ander, arr)

# i want this to be jason(o: ref Jasonable)
func jason*(o: ref): Json =
  ## Render a Nim `ref` as either `null` or the value to which it refers.
  if o.isNil:
    result = Json"null"
  else:
    result = jason o[]

func `$`*(j: Json): string =
  ## Convenience for Json.
  result = j.string
