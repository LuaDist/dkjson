package = "dkjson"
version = "2.5-2"
source = {
  url = "http://dkolf.de/src/dkjson-lua.fsl/tarball/dkjson-2.5.tar.gz?uuid=release_2_5",
  file = "dkjson-2.5.tar.gz"
}
description = {
  summary = "David Kolf's JSON module for Lua",
  detailed = [[
dkjson is a module for encoding and decoding JSON data. It supports UTF-8.

JSON (JavaScript Object Notation) is a format for serializing data based
on the syntax for JavaScript data structures.

dkjson is written in Lua without any dependencies, but
when LPeg is available dkjson uses it to speed up decoding.
]],
  homepage = "http://dkolf.de/src/dkjson-lua.fsl/",
  license = "MIT/X11"
}
dependencies = {
  "lua >= 5.1, < 5.4"
}
build = {
  type = "builtin",
  modules = {
    dkjson = "dkjson.lua"
  }
}

