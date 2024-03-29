# jason

[![Test Matrix](https://github.com/disruptek/jason/workflows/CI/badge.svg)](https://github.com/disruptek/jason/actions?query=workflow%3ACI)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/disruptek/jason?style=flat)](https://github.com/disruptek/jason/releases/latest)
![Minimum supported Nim version](https://img.shields.io/badge/nim-1.4.8%2B-informational?style=flat&logo=nim)
[![License](https://img.shields.io/github/license/disruptek/jason?style=flat)](#license)

**mostly** compile-time JSON encoding

"I don't care." -- _Araq, 2020_

## Why?

- [This is the fastest known JSON serializer for Nim.](https://github.com/disruptek/jason#benchmarks)
- It's pretty hard to misuse, but as simple as it is, it will get even better if a new concepts implementation lands in Nim.
- It's not *fully* optimized yet; there's quite a bit more room to improve.
- I *may* add a deserializer if a strong candidate doesn't materialize.  🤔

Advantages of `jason` over other serializers:

1. encoding of tuples, objects, and iterators is "free" -- no loops to write
and few-to-zero copies

1. no runtime serialization exceptions and a distinct JSON type for safety

1. easy custom serialization for your types, and even custom compile-time
serialization

## Usage

```nim
# an integer
echo 45.jason                  # 45

# a float
echo jason(5.0)                # 5.0

# a bool
echo jason true                # true

# an enum (see below for custom serialization overriding)
echo Two.jason                 # 2

# a string
echo jason"foo"                # "foo"

# ref types are fine
echo jason((ref string) nil)   # null
```

Tuples without named fields become JSON arrays.  Tuples with named fields
become JSON objects.

```nim
echo (1, 2, 3).jason                       # [1,2,3]
echo (cats: "meow", dogs: "woof").jason    # {"cats":"meow","dogs":"woof"}
```

Objects are supported, with or without `ref` fields.

```nim
type
  O = object
   cats: string
   dogs: int
   q: ref O

let o = O(cats: "yuk", dogs: 2)
echo o.jason   # {"cats":"yuk","dogs":2,"q":null}
```

Custom serialization is trivial; just implement `jason` for your type.  No
need to guess as to whether you've implemented all necessary serializers;
if it compiles, you're golden.

```nim
type
  B = object
    x: int
    y: string
  C = seq[B]

let b = B(x: 3, y: "sup")
let c: C = @[ B(x: 1), B(x: 2), B(x: 3) ]

const a = B(x: 4, y: "compile-time!")

func jason(n: B): Jason =
  if n.x mod 2 == 0: jason"even"
  else:              jason"odd"

# enabling compile-time encoding is easy
staticJason C

# or you can define static encoding yourself
macro jason(n: static[B]): Jason =
  if n.x mod 2 == 0: jasonify"1"
  else:              jasonify"0"

check a.jason == "1"
check b.jason == """"odd""""
check c.jason == """["odd","even","odd"]"""
```

`Jason` is a proper type.

```nim
var n: string = jason"foo"      # type error
var x: string = $"foo".jason    # ok
var y = jason"foo"              # ok
y.add "bif"                     # type error
```

## Benchmarks

### jason versus jsony

[This is a comparison with the jsony
library.](https://github.com/disruptek/jason/blob/master/tests/sonny.nim)

![jsony](docs/jsony.svg "jsony")

### jason versus std/json

[The source to the benchmark is found in the tests
directory.](https://github.com/disruptek/jason/blob/master/tests/bench.nim)

![bench](docs/bench.svg "bench")

### jason versus packedjson

[There is also a benchmark for the packedjson
library.](https://github.com/disruptek/jason/blob/master/tests/packed.nim)
**Note:** The primary reason to choose `packedjson` is low memory overhead
during *deserialization*.

![packedjson](docs/packed.svg "packedjson")

### jason versus eminim

[This is a comparison with the eminim
library.](https://github.com/disruptek/jason/blob/master/tests/emi.nim) As
`eminim` serializes only to streams, we similarly issue a stream write in the
`jason` benchmarks here, so that fair comparison may be made.

![eminim](docs/eminim.svg "eminim")

## Installation

```
$ nimph clone jason
```
or if you're still using Nimble like it's 2012,
```
$ nimble install https://github.com/disruptek/jason
```

## Documentation

I'm going to try a little harder with these docs by using `runnableExamples`
so the documentation demonstrates _current_ usage examples and working tests.

[See the documentation for the jason module as generated directly from the
source.](https://disruptek.github.io/jason/jason.html)

## License
MIT
