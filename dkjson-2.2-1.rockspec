package = "dkjson"
version = "2.2-1"
source = {
  url = "http://chiselapp.com/user/dhkolf/repository/dkjson/tarball/dkjson-2.2.tar.gz?uuid=release_2_2",
  file = "dkjson-2.2.tar.gz"
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
  homepage = "http://chiselapp.com/user/dhkolf/repository/dkjson/",
  license = "MIT/X11"
}
dependencies = {
  "lua >= 5.1"
}
build = {
  type = "builtin",
  modules = {
    dkjson = "dkjson.lua"
  }
}

