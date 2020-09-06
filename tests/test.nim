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

# convenience

func `==`(js: Json; s: Json): bool =
  result = system.`==`(js.string, s.string)

func `==`(js: Json; s: string): bool =
  result = system.`==`(js.string, s)

func `==`(s: string; js: Json): bool =
  result = system.`==`(js.string, s)


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
    check [1, 2, 3].jason == "[1,2,3]"
    check @[1, 2, 3].jason == "[1,2,3]"

  test "ref":
    var
      x: ref int = new(int)
    x[] = 45
    check "45" == x.jason
    check jason((ref string) nil) == "null"

  test "tuple":
    proc dumb1(): (int, string) = (1, "2")
    proc dumb2(): tuple[a: int, b: string] = (1, "2")
    proc dumb3(): tuple[a: int, b: string] = (a: 1, b: "2")

    check dumb1().jason == Json"""[1,"2"]"""
    check dumb2().jason == Json"""{"a":1,"b":"2"}"""
    check dumb3().jason == Json"""{"a":1,"b":"2"}"""

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
    check s.jason == """{"a":"hello","b":1,"c":34,"d":[1,1,2,3,5],"e":true,"f":["a","c","d","b"],"g":45,"h":"world","i":null,"j":{"goats":4,"pigs":5},"z":null}"""

  test "custom":
    type
      B = object
        x: int
        y: string
      C = seq[B]

    const a = B(x: 4, y: "compile-time!")
    let b = B(x: 3, y: "sup")
    let c: C = @[ B(x: 1), B(x: 2), B(x: 3) ]

    func jason(n: B): Json =
      if n.x mod 2 == 0: jason"even"
      else:              jason"odd"

    macro jason(n: static[B]): Json =
      newCall(ident"Json", newLit(n.jason.string))

    check a.jason == """"even""""
    check b.jason == """"odd""""
    check c.jason == """["odd","even","odd"]"""
