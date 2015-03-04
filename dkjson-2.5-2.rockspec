package = &quot;dkjson&quot;
version = &quot;2.5-2&quot;
source = {
  url = &quot;http://dkolf.de/src/dkjson-lua.fsl/tarball/dkjson-2.5.tar.gz?uuid=release_2_5&quot;,
  file = &quot;dkjson-2.5.tar.gz&quot;
}
description = {
  summary = &quot;David Kolf's JSON module for Lua&quot;,
  detailed = [[
dkjson is a module for encoding and decoding JSON data. It supports UTF-8.

JSON (JavaScript Object Notation) is a format for serializing data based
on the syntax for JavaScript data structures.

dkjson is written in Lua without any dependencies, but
when LPeg is available dkjson uses it to speed up decoding.
]],
  homepage = &quot;http://dkolf.de/src/dkjson-lua.fsl/&quot;,
  license = &quot;MIT/X11&quot;
}
dependencies = {
  &quot;lua &gt;= 5.1, &lt; 5.4&quot;
}
build = {
  type = &quot;builtin&quot;,
  modules = {
    dkjson = &quot;dkjson.lua&quot;
  }
}
