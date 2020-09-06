import std/jsonutils
import std/json

import jason
import criterion

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

benchmark cfg:
  proc encode_stdlib_integer() {.measure.} =
    discard $(toJson thing.sheep)

  proc encode_jason_integer() {.measure.} =
    discard thing.sheep.jason.string

  proc encode_stdlib_bool() {.measure.} =
    discard $(toJson thing.cats)

  proc encode_jason_bool() {.measure.} =
    discard thing.cats.jason.string

  proc encode_stdlib_number() {.measure.} =
    discard $(toJson thing.ducks)

  proc encode_jason_number() {.measure.} =
    discard thing.ducks.jason.string

  proc encode_stdlib_string() {.measure.} =
    discard $(toJson thing.dogs)

  proc encode_jason_string() {.measure.} =
    discard thing.dogs.jason.string

  proc encode_stdlib_tuple() {.measure.} =
    discard $(toJson thing.geese)

  proc encode_jason_tuple() {.measure.} =
    discard thing.geese.jason.string

  proc encode_stdlib_mixed_tuple() {.measure.} =
    discard $(toJson thing.llama)

  proc encode_jason_mixed_tuple() {.measure.} =
    discard thing.llama.jason.string

  proc encode_stdlib_named_tuple() {.measure.} =
    discard $(toJson thing.frogs)

  proc encode_jason_named_tuple() {.measure.} =
    discard thing.frogs.jason.string

  proc encode_stdlib_array() {.measure.} =
    discard $(toJson thing.goats)

  proc encode_jason_array() {.measure.} =
    discard thing.goats.jason.string

  proc encode_stdlib_sequence() {.measure.} =
    discard $(toJson thing.fish)

  proc encode_jason_sequence() {.measure.} =
    discard thing.fish.jason.string

  proc encode_stdlib_large_object() {.measure.} =
    discard $(toJson thing)

  proc encode_jason_large_object() {.measure.} =
    discard thing.jason.string
