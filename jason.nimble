version = "1.0.2"
author = "disruptek"
description = "compile-time json"
license = "MIT"

when not defined(release):
  requires "https://github.com/disruptek/balls#rc"
  requires "https://github.com/disruptek/criterion < 1.0.0"

task test, "run tests for ci":
  when defined(windows):
    exec "balls.cmd"
  else:
    exec findExe"balls"

task demo, "generate benchmarks":
  exec """demo docs/bench.svg "nim c --out=\$1 --panics:on --gc:arc --define:danger tests/bench.nim""""
  exec """demo docs/packed.svg "nim c --out=\$1 --panics:on --gc:arc --define:danger tests/packed.nim""""
  exec """demo docs/eminim.svg "nim c --out=\$1 --panics:on --gc:arc --define:danger tests/emi.nim""""
  exec """demo docs/jsony.svg "nim c --out=\$1 --panics:on --gc:arc --define:danger tests/sonny.nim""""
