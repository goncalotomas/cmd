# cmd
[![hex version](https://img.shields.io/hexpm/v/cmd.svg)](https://hex.pm/packages/cmd)
[![Build Status](https://travis-ci.org/goncalotomas/cmd.svg?branch=master)](https://travis-ci.org/goncalotomas/cmd)
![Dialyzer Enabled](https://img.shields.io/badge/dialyzer-enabled-brightgreen.svg)  

An OTP library for when you want `os:cmd` but sometimes need to check return codes.

Build
-----

    $ rebar3 compile

Try it out
```erl-sh
$ rebar3 shell
===> Verifying dependencies...
===> Compiling cmd
Erlang/OTP 21 [erts-10.0.6] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]

Eshell V10.0.6  (abort with ^G)
1> cmd:run("echo hi").
"hi\n"
2> cmd:run("echo hi", return_code).
0
3> cmd:run("cp / # this is an invalid command").
"usage: cp [-R [-H | -L | -P]] [-fi | -n] [-apvXc] source_file target_file\n       cp [-R [-H | -L | -P]] [-fi | -n] [-apvXc] source_file ... target_directory\n"
4> cmd:run("cp / # this is an invalid command", return_code).
64
```
