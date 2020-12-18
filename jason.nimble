version = "0.4.0"
author = "disruptek"
description = "compile-time json"
license = "MIT"

requires "nim >= 1.3.5 & < 2.0.0"
requires "https://github.com/disruptek/testes >= 0.3.2 & < 1.0.0"
requires "https://github.com/disruptek/criterion < 1.0.0"

proc execCmd(cmd: string) =
  echo "exec: " & cmd
  exec cmd

proc execTest(test: string) =
  when getEnv("GITHUB_ACTIONS", "false") != "true":
    execCmd "nim c -f -r " & test
    when (NimMajor, NimMinor) >= (1, 2):
      execCmd "nim cpp --gc:arc -d:danger -f -r " & test
  else:
    execCmd "nim c              -r " & test
    execCmd "nim cpp            -r " & test
    execCmd "nim c   -d:danger  -r " & test
    execCmd "nim cpp -d:danger  -r " & test
    when (NimMajor, NimMinor) >= (1, 2):
      execCmd "nim c --useVersion:1.0 -d:danger -r " & test
      execCmd "nim c   --gc:arc -d:danger -r " & test
      execCmd "nim cpp --gc:arc -d:danger -r " & test

task test, "run tests for ci":
  execTest("tests/test.nim")

task demo, "generate benchmarks":
  exec """demo docs/bench.svg "nim c --out=\$1 --gc:arc --define:danger tests/bench.nim""""
  exec """demo docs/packed.svg "nim c --out=\$1 --gc:arc --define:danger tests/packed.nim""""
