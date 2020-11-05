version = "0.2.2"
author = "disruptek"
description = "compile-time json"
license = "MIT"

requires "nim >= 1.0.0 & < 2.0.0"
requires "https://github.com/disruptek/testes >= 0.3.2 & < 1.0.0"
requires "https://github.com/disruptek/criterion < 1.0.0"

proc execCmd(cmd: string) =
  echo "exec: " & cmd
  exec cmd

proc execTest(test: string) =
  when getEnv("GITHUB_ACTIONS", "false") != "true":
    execCmd "nim c -r " & test
    when (NimMajor, NimMinor) >= (1, 2):
      execCmd "nim cpp --gc:arc -d:danger -r " & test
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

task docs, "generate benchmark":
  exec "termtosvg docs/bench.svg --max-frame-duration=3000 --loop-delay=3000 --screen-geometry=80x30 --template=window_frame_powershell --command=\"nim c --gc:arc --define:danger -r tests/bench.nim\""
  exec "termtosvg docs/packed.svg --max-frame-duration=3000 --loop-delay=3000 --screen-geometry=80x30 --template=window_frame_powershell --command=\"nim c --gc:arc --define:danger -r tests/packed.nim\""
