import std/jsonutils
import std/json

import jason
import criterion

when not defined(danger):
  {.error: "benchmark with --define:danger".}

when not defined(gcArc) and not defined(gcOrc):
  {.warning: "recommend --gc:arc or --gc:orc".}

type
  Some = object
    goats: array[2, string]
    sheep: int
    ducks: float
    dogs: string
    cats: bool
    fish: seq[uint64]
    llama: (int, bool, string, float)
    frogs: tuple[toads: bool, rats: string]
    geese: (int, int, int, int, int)

const
  thing = Some(goats: ["pigs", "horses"],
               sheep: 11, ducks: 12.0,
               fish: @[8'u64, 6, 7, 5, 3, 0, 9],
               dogs: "woof", cats: false,
               llama: (1, true, "secret", 42.0),
               geese: (9, 0, 2, 1, 0),
               frogs: (toads: true, rats: "yep"))

var cfg = newDefaultConfig()
cfg.brief = true

echo "running benchmark..."

benchmark cfg:
  proc encode_stdlib_integer() {.measure.} =
    discard $(toJson thing.sheep)

benchmark cfg:
  proc encode_jason_integer() {.measure.} =
    discard thing.sheep.jason.string

benchmark cfg:
  proc encode_stdlib_bool() {.measure.} =
    discard $(toJson thing.cats)

benchmark cfg:
  proc encode_jason_bool() {.measure.} =
    discard thing.cats.jason.string

benchmark cfg:
  proc encode_stdlib_number() {.measure.} =
    discard $(toJson thing.ducks)

benchmark cfg:
  proc encode_jason_number() {.measure.} =
    discard thing.ducks.jason.string

benchmark cfg:
  proc encode_stdlib_string() {.measure.} =
    discard $(toJson thing.dogs)

benchmark cfg:
  proc encode_jason_string() {.measure.} =
    discard thing.dogs.jason.string

benchmark cfg:
  proc encode_stdlib_tuple() {.measure.} =
    discard $(toJson thing.geese)

benchmark cfg:
  proc encode_jason_tuple() {.measure.} =
    discard thing.geese.jason.string

benchmark cfg:
  proc encode_stdlib_mixed_tuple() {.measure.} =
    discard $(toJson thing.llama)

benchmark cfg:
  proc encode_jason_mixed_tuple() {.measure.} =
    discard thing.llama.jason.string

benchmark cfg:
  proc encode_stdlib_named_tuple() {.measure.} =
    discard $(toJson thing.frogs)

benchmark cfg:
  proc encode_jason_named_tuple() {.measure.} =
    discard thing.frogs.jason.string

benchmark cfg:
  proc encode_stdlib_array() {.measure.} =
    discard $(toJson thing.goats)

benchmark cfg:
  proc encode_jason_array() {.measure.} =
    discard thing.goats.jason.string

benchmark cfg:
  proc encode_stdlib_sequence() {.measure.} =
    discard $(toJson thing.fish)

benchmark cfg:
  proc encode_jason_sequence() {.measure.} =
    discard thing.fish.jason.string

benchmark cfg:
  proc encode_stdlib_large_object() {.measure.} =
    discard $(toJson thing)

benchmark cfg:
  proc encode_jason_large_object() {.measure.} =
    discard thing.jason.string
