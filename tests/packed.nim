import jason
import criterion

import packedjson
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
    #frogs: tuple[toads: bool, rats: string]
    #geese: (int, int, int, int, int)

const
  thing = Some(goats: ["black", "pigs", "pink", "horses"],
               sheep: 11, ducks: 12.0,
               fish: @[8'i32, 6, 7, 5, 3, 0, 9],
               dogs: "woof", cats: false)
               #llama: (1, true, "secret", 42.0),
               #geese: (9, 0, 2, 1, 0),
               #frogs: (toads: true, rats: "yep"))

var cfg = newDefaultConfig()
cfg.brief = true
cfg.budget = 1.0

echo "running benchmark..."

benchmark cfg:
  proc encode_packed_integer() {.measure.} =
    discard $(toJson thing.sheep)

benchmark cfg:
  proc encode_jason_integer() {.measure.} =
    discard thing.sheep.jason.string

benchmark cfg:
  proc encode_packed_bool() {.measure.} =
    discard $(toJson thing.cats)

benchmark cfg:
  proc encode_jason_bool() {.measure.} =
    discard thing.cats.jason.string

benchmark cfg:
  proc encode_packed_number() {.measure.} =
    discard $(toJson thing.ducks)

benchmark cfg:
  proc encode_jason_number() {.measure.} =
    discard thing.ducks.jason.string

benchmark cfg:
  proc encode_packed_string() {.measure.} =
    discard $(toJson thing.dogs)

benchmark cfg:
  proc encode_jason_string() {.measure.} =
    discard thing.dogs.jason.string

when false:
  benchmark cfg:
    proc encode_packed_tuple() {.measure.} =
      discard $(toJson thing.geese)

  benchmark cfg:
    proc encode_jason_tuple() {.measure.} =
      discard thing.geese.jason.string

  benchmark cfg:
    proc encode_packed_mixed_tuple() {.measure.} =
      discard $(toJson thing.llama)

  benchmark cfg:
    proc encode_jason_mixed_tuple() {.measure.} =
      discard thing.llama.jason.string

  benchmark cfg:
    proc encode_packed_named_tuple() {.measure.} =
      discard $(toJson thing.frogs)

  benchmark cfg:
    proc encode_jason_named_tuple() {.measure.} =
      discard thing.frogs.jason.string

else:
  echo "\nNOTE: tuple serialization is unsupported by packedjson\n"

benchmark cfg:
  proc encode_packed_array() {.measure.} =
    discard $(toJson thing.goats)

benchmark cfg:
  proc encode_jason_array() {.measure.} =
    discard thing.goats.jason.string

echo "\nNOTE: uint serialization is unsupported by packedjson\n"

benchmark cfg:
  proc encode_packed_sequence() {.measure.} =
    discard $(toJson thing.fish)

benchmark cfg:
  proc encode_jason_sequence() {.measure.} =
    discard thing.fish.jason.string

benchmark cfg:
  proc encode_packed_large_object() {.measure.} =
    discard $(toJson thing)

benchmark cfg:
  proc encode_jason_large_object() {.measure.} =
    discard thing.jason.string
