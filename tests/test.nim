import std/options

import testes
import jason

type
  Enum = enum
    One
    Two

  Some = object
    a: string
    b: Enum
    c: int
    d: seq[int]
    e: bool
    f: array[4, string]
    g: ref int
    h: ref string
    i: ref string
    j: tuple[goats: int; pigs: int]
    z: ref Some

  CreepyVariant = object
    foo: int
    bar: float
    case bif: Enum
    of One:
      baz: bool
    of Two:
      boz: tuple[a: int, b: float]
    bin: array[4, string]

# convenience

func `==`(js: Jason or string; s: Jason or string): bool =
  system.`==`(js.string, s.string)

testes:
  test "string":
    check jason"hello" == """"hello""""

  test "int":
    check 34.jason == "34"

  test "bool":
    check true.jason == "true"

  test "float":
    check jason(23.0) == "23.0"

  test "enum":
    check Two.jason == "1"

  test "array":
    check "arrays and seqs":
      [1, 2, 3].jason == "[1,2,3]"
      @[1, 2, 3].jason == "[1,2,3]"

  test "slow array":
    let (x, y) = ("3", 4)
    check "arrays of strings and ints":
      [x, x, x].jason == Jason"""["3","3","3"]"""
      [y, y, y].jason == Jason"""[4,4,4]"""

  test "ref":
    var
      x: ref int = new(int)
    x[] = 45
    check "refs and string":
      "45" == x.jason
      jason((ref string) nil) == "null"

  test "tuple":
    let
      dumb1: (int, string) = (1, "2")
      dumb2: tuple[a: int, b: string] = (1, "2")
      dumb3: tuple[a: int, b: string] = (a: 1, b: "2")
    check "named and unnamed tuples":
      dumb1.jason == Jason"""[1,"2"]"""
      dumb2.jason == Jason"""{"a":1,"b":"2"}"""
      dumb3.jason == Jason"""{"a":1,"b":"2"}"""

  test "slow tuple":
    let (x, y) = ("3", 4)
    check "named and unnamed tuples":
      (x, y).jason == Jason"""["3",4]"""
      (a: x, b: y).jason == Jason"""{"a":"3","b":4}"""

  test "object":
    type
      A = object
        t: int

    var a = A(t: 45)
    check a.jason == """{"t":45}"""

    var
      x: ref int = new(int)
      y: ref string = new(string)
      z: ref string
    x[] = 45
    y[] = "world"
    var
      s = Some(a: "hello", b: Two, c: 34, g: x, h: y, i: z,
               d: @[1, 1, 2, 3, 5], e: true, j: (4, 5),
               f: ["a", "c", "d", "b"], z: (ref Some) nil)
    check s.jason == """{"a":"hello","b":1,"c":34,"d":[1,1,2,3,5],""" &
                     """"e":true,"f":["a","c","d","b"],"g":45,""" &
                     """"h":"world","i":null,"j":{"goats":4,"pigs":5},""" &
                     """"z":null}"""

  test "custom":
    type
      B = object
        x: int
        y: string
      C = seq[B]

    const a = B(x: 4, y: "compile-time!")
    let b = B(x: 3, y: "sup")
    let c: C = @[ B(x: 1), B(x: 2), B(x: 3) ]

    func jason(n: B): Jason =
      if n.x mod 2 == 0: jason"even"
      else:              jason"odd"

    # enabling compile-time encoding is easy
    staticJason C

    # or you can define static encoding yourself
    macro jason(n: static[B]): Jason =
      if n.x mod 2 == 0: jasonify"1"
      else:              jasonify"0"

    check "custom serializers":
      a.jason == "1"
      b.jason == """"odd""""
      c.jason == """["odd","even","odd"]"""

  test "option":
    check "serialized options":
      $jason(some "foo") == """{"val":"foo","has":true}"""
      $jason(none int) == """{"val":0,"has":false}"""

  test "tuple attack":
    let x = ((1, 2),(3, 4),(5, 6),(7, 8))
    check $jason(x) == "[[1,2],[3,4],[5,6],[7,8]]"
    let y = (((1, 2),(3, 4)), ((5, 6),(7, 8))) # (from sealmove)
    check $jason(y) == "[[[1,2],[3,4]],[[5,6],[7,8]]]"

  test "object example":
    let j = jason Exception(name: "jeff", msg: "bummer")
    check $j == """{"parent":null,"name":"jeff","msg":"bummer","trace":[],"up":null}"""

  test "creepy variant":
    const
      c = CreepyVariant(foo: 3, bar: 4.0, bif: One, baz: true,
                        bin: ["e", "f", "g", "h"])
      d = CreepyVariant(foo: 2, bar: 8.0, bif: Two, boz: (6, 7.0),
                        bin: ["i", "j", "k", "l"])
    let
      cj = $jason(c)
      dj = $jason(d)
    check cj == """{"foo":3,"bar":4.0,"bif":0,"baz":true,"bin":["e","f","g","h"]}"""
    check dj == """{"foo":2,"bar":8.0,"bif":1,"boz":{"a":6,"b":7.0},"bin":["i","j","k","l"]}"""
