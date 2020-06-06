import std/macros
import std/json

import jason
import criterion

var
  tJsA {.compileTime.} = newJArray()
  tJsO {.compileTime.} = newJObject()
  tJs {.compileTime.} = newJObject()

tJsA.add newJString"pigs"
tJsA.add newJString"horses"

tJsO.add "toads", newJBool(true)
tJsO.add "rats", newJString"yep"

for k, v in {
  "goats": tJsA,
  "sheep": newJInt(11),
  "ducks": newJFloat(12.0),
  "dogs": newJString("woof"),
  "cats": newJBool(false),
  "frogs": tJsO,
}.items:
  tJs[k] = v

const
  jsSize = len($tJs)

type
  Some = object
    goats: array[2, string]
    sheep: int
    ducks: float
    dogs: string
    cats: bool
    frogs: tuple[toads: bool, rats: string]

const
  thing = Some(goats: ["pigs", "horses"],
               sheep: 11, ducks: 12.0,
               dogs: "woof", cats: false,
               frogs: (toads: true, rats: "yep"))

var
  thang = Some(goats: ["pigs", "horses"],
               sheep: 11, ducks: 12.0,
               dogs: "woof", cats: false,
               frogs: (toads: true, rats: "yep"))

var cfg = newDefaultConfig()
cfg.budget = 0.5

benchmark cfg:
  let
    jint = newJInt(45)
    nint = 45
    jstr = newJString("goats")
    nstr = "pigs"
  var
    ntup1 = ("goats", "pigs")
    jtup1 = newJArray()
  jtup1.add newJString("goats")
  jtup1.add newJString("pigs")
  var
    ntup2 = ("goats", 3)
    jtup2 = newJArray()
  jtup2.add newJString("goats")
  jtup2.add newJInt(3)
  type
    Obj = object
      goats: string
      dogs: int

  var
    nobj = Obj(goats: "pigs", dogs: 3)
    ntup3 = (goats: "pigs", dogs: 3)
    jtup3 = newJObject()
  jtup3.add "goats", newJString("pigs")
  jtup3.add "dogs", newJInt(3)
  var
    narr = ["goats", "pigs"]
    jarr = newJArray()
  jarr.add newJString("goats")
  jarr.add newJString("pigs")

  proc encode_stdlib_int() {.measure.} =
    discard $jint

  proc encode_jason_int() {.measure.} =
    discard nint.jason

  proc encode_stdlib_str() {.measure.} =
    discard $jstr

  proc encode_jason_str() {.measure.} =
    discard nstr.jason

  proc encode_stdlib_tup1() {.measure.} =
    discard $jtup1

  proc encode_jason_tup1() {.measure.} =
    discard ntup1.jason

  proc encode_stdlib_tup2() {.measure.} =
    discard $jtup2

  proc encode_jason_tup2() {.measure.} =
    discard ntup2.jason

  proc encode_stdlib_tup3() {.measure.} =
    discard $jtup3

  proc encode_jason_tup3() {.measure.} =
    discard ntup3.jason

  proc encode_stdlib_arr() {.measure.} =
    discard $jarr

  proc encode_jason_arr() {.measure.} =
    discard narr.jason

  proc encode_jason_obj() {.measure.} =
    discard nobj.jason

  when false:
    proc encode_stdlib() {.measure.} =
      discard $tJsO

    proc encode_jason() {.measure.} =
      discard thing.jason
