version = "0.0.1"
author = "disruptek"
description = "compile-time json"
license = "MIT"

requires "nim >= 1.0.0 & < 2.0.0"

proc execCmd(cmd: string) =
  echo "exec: " & cmd
  exec cmd

proc execTest(test: string) =
  when true:
    execCmd "nim c -d:danger -r " & test & " write"
    execCmd "nim c -d:danger -r " & test & " read"
    execCmd "nim c -d:danger -r " & test & " write 500"
    execCmd "nim c -d:danger -r " & test & " read 500"
  else:
    execCmd "nim c              -r " & test & " write"
    execCmd "nim c   -d:danger  -r " & test & " read"
    execCmd "nim cpp            -r " & test & " write"
    execCmd "nim cpp -d:danger  -r " & test & " read"
    when NimMajor >= 1 and NimMinor >= 1:
      execCmd "nim c --useVersion:1.0 -d:danger -r " & test & " write"
      execCmd "nim c --useVersion:1.0 -d:danger -r " & test & " read"
      execCmd "nim c   --gc:arc -r " & test & " write"
      execCmd "nim cpp --gc:arc -r " & test & " read"

task test, "run tests for travis":
  execTest("tests/test.nim")
