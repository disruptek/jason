# jason

[![Test Matrix](https://github.com/disruptek/jason/workflows/CI/badge.svg)](https://github.com/disruptek/jason/actions?query=workflow%3ACI)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/disruptek/jason?style=flat)](https://github.com/disruptek/jason/releases/latest)
![Minimum supported Nim version](https://img.shields.io/badge/nim-1.0.8%2B-informational?style=flat&logo=nim)
[![License](https://img.shields.io/github/license/disruptek/jason?style=flat)](#license)
[![buy me a coffee](https://img.shields.io/badge/donate-buy%20me%20a%20coffee-orange.svg)](https://www.buymeacoffee.com/disruptek)

**mostly** compile-time JSON encoding

"I don't care." -- _Araq, 2020_

## Goals

Making some assumptions (ie. that our types aren't changing) allows...

- predictably fast performance
- predictably mild memory behavior
- predictably _idiomatic_ API
- **hard to misuse**

It's _fairly_ hard to misuse, but it's not fully optimized yet. In some cases,
it's much faster than the standard json module. In a few, it's a little slower.

The main advantage is that you get JSON encoding of tuples, objects, and
iterators "for free" -- no serialization to implement and no duplication of
data.

Everything is type-checked, too, so there will be no runtime serialization
exceptions.

And, if you _want_ to implement custom serialization, it's now trivial to do
so for individual types.

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

func jason(n: B): Json =
  if n.x mod 2 == 0: jason"even"
  else:              jason"odd"

echo b.jason      # "odd"
echo c.jason      # ["odd","even","odd"]
```

`Json` is a proper type.

```nim
var n: string = jason"foo"      # type error
var x: string = $"foo".jason    # ok
var y = jason"foo"              # ok
y.add "bif"                     # type error
```

## Installation

```
$ nimph clone disruptek/jason
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
