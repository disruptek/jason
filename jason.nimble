version = "0.0.2"
author = "disruptek"
description = "compile-time json"
license = "MIT"

requires "nim >= 1.0.0 & < 2.0.0"

proc execCmd(cmd: string) =
  echo "exec: " & cmd
  exec cmd

proc execTest(test: string) =
  execCmd "nim c              -r " & test
  execCmd "nim c   -d:danger  -r " & test
  execCmd "nim cpp            -r " & test
  execCmd "nim cpp -d:danger  -r " & test
  when NimMajor >= 1 and NimMinor >= 1:
    execCmd "nim c   --gc:arc -r " & test
    execCmd "nim cpp --gc:arc -r " & test
    execCmd "nim c   -d:danger --gc:arc -r " & test
    execCmd "nim cpp -d:danger --gc:arc -r " & test

task test, "run tests for travis":
  execTest("tests/test.nim")
