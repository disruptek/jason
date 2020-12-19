import std/streams

import jason
import criterion

import eminim
template toJson(x: untyped): untyped = %* x

when not defined(danger):
  {.error: "benchmark with --define:danger".}

when not defined(gcArc) and not defined(gcOrc):
  {.warning: "recommend --gc:arc or --gc:orc".}

type
  Some = object
    goats: array[4, string]
    sheep: int
    ducks: float
    dogs: string
    cats: bool
    fish: seq[int32]
    #llama: (int, bool, string, float)
    frogs: tuple[toads: bool, rats: string]
    #geese: (int, int, int, int, int)

const
  thing = Some(goats: ["black", "pigs", "pink", "horses"],
               sheep: 11, ducks: 12.0,
               fish: @[8'i32, 6, 7, 5, 3, 0, 9],
               dogs: "woof", cats: false,
               #llama: (1, true, "secret", 42.0),
               #geese: (9, 0, 2, 1, 0),
               frogs: (toads: true, rats: "yep"))

var cfg = newDefaultConfig()
cfg.brief = true
cfg.budget = 1.0

echo "running benchmark..."

var s = newStringStream(newStringOfCap 4000)

benchmark cfg:
  proc encode_eminim_integer() {.measure.} =
    s.setPosition 0
    s.storeJson thing.sheep

benchmark cfg:
  proc encode_jason_integer() {.measure.} =
    s.setPosition 0
    s.write thing.sheep.jason.string

benchmark cfg:
  proc encode_eminim_bool() {.measure.} =
    s.setPosition 0
    s.storeJson thing.cats

benchmark cfg:
  proc encode_jason_bool() {.measure.} =
    s.setPosition 0
    s.write thing.cats.jason.string

benchmark cfg:
  proc encode_eminim_number() {.measure.} =
    s.setPosition 0
    s.storeJson thing.ducks

benchmark cfg:
  proc encode_jason_number() {.measure.} =
    s.setPosition 0
    s.write thing.ducks.jason.string

benchmark cfg:
  proc encode_eminim_string() {.measure.} =
    s.setPosition 0
    s.storeJson thing.dogs

benchmark cfg:
  proc encode_jason_string() {.measure.} =
    s.setPosition 0
    s.write thing.dogs.jason.string

when false:
  benchmark cfg:
    proc encode_eminim_tuple() {.measure.} =
      s.setPosition 0
      s.storeJson thing.geese

  benchmark cfg:
    proc encode_jason_tuple() {.measure.} =
      s.setPosition 0
      s.write thing.geese.jason.string

  benchmark cfg:
    proc encode_eminim_mixed_tuple() {.measure.} =
      s.setPosition 0
      s.storeJson thing.llama

  benchmark cfg:
    proc encode_jason_mixed_tuple() {.measure.} =
      s.setPosition 0
      s.write thing.llama.jason.string

else:
  echo "\nNOTE: anonymous tuple serialization is unsupported by eminim\n"

  benchmark cfg:
    proc encode_eminim_named_tuple() {.measure.} =
      s.setPosition 0
      s.storeJson thing.frogs

  benchmark cfg:
    proc encode_jason_named_tuple() {.measure.} =
      s.setPosition 0
      s.write thing.frogs.jason.string


benchmark cfg:
  proc encode_eminim_array() {.measure.} =
    s.setPosition 0
    s.storeJson thing.goats

benchmark cfg:
  proc encode_jason_array() {.measure.} =
    s.setPosition 0
    s.write thing.goats.jason.string

echo "\nNOTE: uint serialization is unsupported by eminim\n"

benchmark cfg:
  proc encode_eminim_sequence() {.measure.} =
    s.setPosition 0
    s.storeJson thing.fish

benchmark cfg:
  proc encode_jason_sequence() {.measure.} =
    s.setPosition 0
    s.write thing.fish.jason.string

benchmark cfg:
  proc encode_eminim_large_object() {.measure.} =
    s.setPosition 0
    s.storeJson thing

benchmark cfg:
  proc encode_jason_large_object() {.measure.} =
    s.setPosition 0
    s.write thing.jason.string
