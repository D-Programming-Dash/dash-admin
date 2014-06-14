#!/bin/bash
dub build

./dash-admin addMachine example_machine "A dummy machine used for testing."

./dash-admin addCompiler ldc_master "LDC, the LLVM-based D compiler (Git master)." '{"name": "Official LDC GitHub repository", "type": 0, "config": {"owner": "ldc-developers", "project": "ldc", "branch": "master"}}' ldcGit
./dash-admin addRunConfig "ldc_master" "debug" "Standard debug info build without optimizations." '[{"priority": 10, "strings": {"dflags": "-g"}}]'
./dash-admin addRunConfig "ldc_master" "release" "Optimized build, but no outlandish settings." '[{"priority": 10, "strings": {"dflags": "-O3 -release -disable-boundscheck -singleobj"}}]'

./dash-admin addCompiler dmd_master "The D programming language reference implementation (Git master)." '{"type": 1, "config": [{"owner": "D-Programming-Language", "project": "dmd", "branch": "master"}, {"owner": "D-Programming-Language", "project": "druntime", "branch": "master"}, {"owner": "D-Programming-Language", "project": "phobos", "branch": "master"}]}' dmdGit
./dash-admin addRunConfig "dmd_master" "debug" "Standard debug info build without optimizations." '[{"priority": 10, "strings": {"dflags": "-g"}}]'
./dash-admin addRunConfig "dmd_master" "release" "Optimized build." '[{"priority": 10, "strings": {"dflags": "-O -release -inline -noboundscheck"}}]'

./dash-admin addBenchmarkBundle trivial '{"name": "dash-benchmark-trivial", "type": 0, "config": { "owner": "D-Programming-Dash", "project": "dash-benchmark-trivial", "branch": "master"}}'
