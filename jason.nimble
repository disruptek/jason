version = "0.4.0"
author = "disruptek"
description = "compile-time json"
license = "MIT"

requires "nim >= 1.4.0 & < 2.0.0"
requires "https://github.com/disruptek/testes >= 0.7.12 & < 1.0.0"
requires "https://github.com/disruptek/criterion < 1.0.0"

task test, "run tests for ci":
  when defined(windows):
    exec "testes.cmd"
  else:
    exec findExe"testes"

task demo, "generate benchmarks":
  exec """demo docs/bench.svg "nim c --out=\$1 --gc:arc --define:danger tests/bench.nim""""
  exec """demo docs/packed.svg "nim c --out=\$1 --gc:arc --define:danger tests/packed.nim""""
  exec """demo docs/eminim.svg "nim c --out=\$1 --gc:arc --define:danger tests/emi.nim""""
