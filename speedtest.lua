<!DOCTYPE html>
<html>
<head>
<base href="http://dkolf.de/src/dkjson-lua.fsl/artifact" />
<title>Artifact Content - dkjson</title>
<link rel="alternate" type="application/rss+xml" title="RSS Feed"
      href="/src/dkjson-lua.fsl/timeline.rss" />
<link rel="stylesheet" href="/src/dkjson-lua.fsl/style.css?default" type="text/css"
      media="screen" />
</head>
<body>
  <h1>Artifact Content &mdash; dkjson</h1>
<div class="mainmenu">
<a href='/'>dkolf.de</a>
<a href='/src/dkjson-lua.fsl/home'>dkjson</a>
<a href='/src/dkjson-lua.fsl/timeline'>Timeline</a>
<a href='/src/dkjson-lua.fsl/brlist'>Branches</a>
<a href='/src/dkjson-lua.fsl/taglist'>Tags</a>
<a href='/src/dkjson-lua.fsl/wiki'>Wiki</a>
<a href='/src/dkjson-lua.fsl/login'>Login</a>
</div>
<div class="submenu">
<a class="label" href="/src/dkjson-lua.fsl/timeline?n=200&amp;uf=18fa972b68042a87ff3ae03c9f6accf575b13d2d">Checkins Using</a>
<a class="label" href="/src/dkjson-lua.fsl/raw/speedtest.lua?name=18fa972b68042a87ff3ae03c9f6accf575b13d2d">Download</a>
<a class="label" href="/src/dkjson-lua.fsl/hexdump?name=18fa972b68042a87ff3ae03c9f6accf575b13d2d">Hex</a>
</div>
<div class="content">
<script>
function gebi(x){
if(/^#/.test(x)) x = x.substr(1);
var e = document.getElementById(x);
if(!e) throw new Error("Expecting element with ID "+x);
else return e;}
</script>
<h2>Artifact 18fa972b68042a87ff3ae03c9f6accf575b13d2d:</h2>
<ul>
<li>File
<a id='a1' href='/src/dkjson-lua.fsl/honeypot'>speedtest.lua</a>
<ul>
<li>
2011-08-05 21:59:09
- part of checkin
<span class="timelineHistDsp">[e0a83a39ad]</span>
on branch <a id='a2' href='/src/dkjson-lua.fsl/honeypot'>trunk</a>
- updated the tests to reflect the new version of cmj-JSON4Lua
 (user:
dhkolf
</ul>
</ul>
<hr />
<blockquote>
<pre>
local encode, decode

local test_module = ... -- command line argument
--local test_module = 'cmj-json'
--local test_module = 'dkjson'
--local test_module = 'dkjson-nopeg'
--local test_module = 'fleece'
--local test_module = 'jf-json'
--locel test_module = 'lua-yajl'
--local test_module = 'mp-cjson'
--local test_module = 'nm-json'
--local test_module = 'sb-json'
--local test_module = 'th-json'


if test_module == 'cmj-json' then
  -- http://json.luaforge.net/
  local json = require &quot;cmjjson&quot; -- renamed, the original file was just 'json'
  encode = json.encode
  decode = json.decode
elseif test_module == 'dkjson' then
  -- http://chiselapp.com/user/dhkolf/repository/dkjson/
  local dkjson = require &quot;dkjson&quot;
  encode = dkjson.encode
  decode = dkjson.decode
elseif test_module == 'dkjson-nopeg' then
  package.preload[&quot;lpeg&quot;] = function () error &quot;lpeg disabled&quot; end
  package.loaded[&quot;lpeg&quot;] = nil
  lpeg = nil
  local dkjson = require &quot;dkjson&quot;
  encode = dkjson.encode
  decode = dkjson.decode
elseif test_module == 'fleece' then
  -- http://www.eonblast.com/fleece/
  local fleece = require &quot;fleece&quot;
  encode = function(x) return fleece.json(x, &quot;E4&quot;) end
elseif test_module == 'jf-json' then
  -- http://regex.info/blog/lua/json
  local json = require &quot;jfjson&quot; -- renamed, the original file was just 'JSON'
  encode = function(x) return json:encode(x) end
  decode = function(x) return json:decode(x) end
elseif test_module == 'lua-yajl' then
  -- http://github.com/brimworks/lua-yajl
  local yajl = require (&quot;yajl&quot;)
  encode = yajl.to_string
  decode = yajl.to_value
elseif test_module == 'mp-cjson' then
  -- http://www.kyne.com.au/~mark/software/lua-cjson.php
  local json = require &quot;cjson&quot;
  encode = json.encode
  decode = json.decode
elseif test_module == 'nm-json' then
  -- http://luaforge.net/projects/luajsonlib/
  local json = require &quot;LuaJSON&quot;
  encode = json.encode or json.stringify
  decode = json.decode or json.parse
elseif test_module == 'sb-json' then
  -- http://www.chipmunkav.com/downloads/Json.lua
  local json = require &quot;sbjson&quot; -- renamed, the original file was just 'Json'
  encode = json.Encode
  decode = json.Decode
elseif test_module == 'th-json' then
  -- http://luaforge.net/projects/luajson/
  local json = require &quot;json&quot;
  encode = json.encode
  decode = json.decode
else
  print &quot;No module specified&quot;
  return
end

-- example data taken from
-- http://de.wikipedia.org/wiki/JavaScript_Object_Notation

local str = [[
{
  &quot;Herausgeber&quot;: &quot;Xema&quot;,
  &quot;Nummer&quot;: &quot;1234-5678-9012-3456&quot;,
  &quot;Deckung&quot;: 26,
  &quot;Währung&quot;: &quot;EUR&quot;,
  &quot;Inhaber&quot;: {
    &quot;Name&quot;: &quot;Mustermann&quot;,
    &quot;Vorname&quot;: &quot;Max&quot;,
    &quot;männlich&quot;: true,
    &quot;Depot&quot;: {},
    &quot;Hobbys&quot;: [ &quot;Reiten&quot;, &quot;Golfen&quot;, &quot;Lesen&quot; ],
    &quot;Alter&quot;: 42,
    &quot;Kinder&quot;: [0],
    &quot;Partner&quot;: null
  }
}
]]

local tbl = {
  Herausgeber= &quot;Xema&quot;,
  Nummer= &quot;1234-5678-9012-3456&quot;,
  Deckung= 2e+6,
  [&quot;Währung&quot;]= &quot;EUR&quot;,
  Inhaber= {
    Name= &quot;Mustermann&quot;,
    Vorname= &quot;Max&quot;,
    [&quot;männlich&quot;]= true,
    Depot= {},
    Hobbys= { &quot;Reiten&quot;, &quot;Golfen&quot;, &quot;Lesen&quot; },
    Alter= 42,
    Kinder= {},
    Partner= nil
    --Partner= json.null
  }
}

local t1, t2

if decode then
  t1 = os.clock ()
  for i = 1,100000 do
    decode (str)
  end
  t2 = os.clock ()
  print (&quot;Decoding:&quot;, t2 - t1)
end

if encode then
  t1 = os.clock ()
  for i = 1,100000 do
    encode (tbl)
  end
  t2 = os.clock ()
  print (&quot;Encoding:&quot;, t2 - t1)
end


</pre>
</blockquote>
</div>
<div class="footer">
  <a href="./">dkolf.de</a>
  <a href="/contact">contact</a>
  (This page was generated by <a class="extlink" href="http://www.fossil-scm.org/">Fossil</a>.)
</div>
</body></html>
