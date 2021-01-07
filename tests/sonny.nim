import jason
import jsony
import criterion

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
    fish: seq[uint64]
    llama: (int, bool, string, float)
    frogs: tuple[toads: bool, rats: string]
    geese: (int, int, int, int, int)

const
  thing = Some(goats: ["black", "pigs", "pink", "horses"],
               sheep: 11, ducks: 12.0,
               fish: @[8'u64, 6, 7, 5, 3, 0, 9],
               dogs: "woof", cats: false,
               llama: (1, true, "secret", 42.0),
               geese: (9, 0, 2, 1, 0),
               frogs: (toads: true, rats: "yep"))

var cfg = newDefaultConfig()
cfg.brief = true
cfg.budget = 1.0

echo "running benchmark..."

benchmark cfg:
  proc encode_jsony_integer() {.measure.} =
    discard thing.sheep.toJson

benchmark cfg:
  proc encode_jason_integer() {.measure.} =
    discard thing.sheep.jason

benchmark cfg:
  proc encode_jsony_bool() {.measure.} =
    discard thing.cats.toJson

benchmark cfg:
  proc encode_jason_bool() {.measure.} =
    discard thing.cats.jason

benchmark cfg:
  proc encode_jsony_number() {.measure.} =
    discard thing.ducks.toJson

benchmark cfg:
  proc encode_jason_number() {.measure.} =
    discard thing.ducks.jason

benchmark cfg:
  proc encode_jsony_string() {.measure.} =
    discard thing.dogs.toJson

benchmark cfg:
  proc encode_jason() {.measure.} =
    discard thing.dogs.jason

benchmark cfg:
  proc encode_jsony_tuple() {.measure.} =
    discard thing.geese.toJson

benchmark cfg:
  proc encode_jason_tuple() {.measure.} =
    discard thing.geese.jason

benchmark cfg:
  proc encode_jsony_mixed_tuple() {.measure.} =
    discard thing.llama.toJson

benchmark cfg:
  proc encode_jason_mixed_tuple() {.measure.} =
    discard thing.llama.jason

benchmark cfg:
  proc encode_jsony_named_tuple() {.measure.} =
    discard thing.frogs.toJson

benchmark cfg:
  proc encode_jason_named_tuple() {.measure.} =
    discard thing.frogs.jason

benchmark cfg:
  proc encode_jsony_array() {.measure.} =
    discard thing.goats.toJson

benchmark cfg:
  proc encode_jason_array() {.measure.} =
    discard thing.goats.jason

benchmark cfg:
  proc encode_jsony_sequence() {.measure.} =
    discard thing.fish.toJson

benchmark cfg:
  proc encode_jason_sequence() {.measure.} =
    discard thing.fish.jason

benchmark cfg:
  proc encode_jsony_large_object() {.measure.} =
    discard thing.toJson

benchmark cfg:
  proc encode_jason_large_object() {.measure.} =
    discard thing.jason
