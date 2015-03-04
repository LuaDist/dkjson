local encode, decode, dkencode, dkdecode


local test_module, opt = ... -- command line argument
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
test_module = test_module or 'dkjson'

--local opt = &quot;esc&quot; -- Test which characters in the BMP get escaped and whether this is correct
--local opt = &quot;esc_full&quot; -- Full range from 0 to 0x10ffff
--local opt = &quot;esc_asc&quot; -- Just 0 to 127

--local opt = &quot;refcycle&quot; -- What happens when a reference cycle gets encoded?

local testlocale = &quot;de_DE.UTF8&quot;

local function inlocale(fn)
  local oldloc = os.setlocale(nil, 'numeric')
  if not os.setlocale(testlocale, 'numeric') then
    print(&quot;test could not switch to locale &quot;..testlocale)
  else
    fn()
  end
  os.setlocale(oldloc, 'numeric')
end

if test_module == 'dkjson-nopeg' then
  test_module = 'dkjson'
  package.preload[&quot;lpeg&quot;] = function () error &quot;lpeg disabled&quot; end
  package.loaded[&quot;lpeg&quot;] = nil
  lpeg = nil
end

if test_module == 'dkjson-lulpeg' then
  test_module = 'dkjson'
  package.loaded[&quot;lpeg&quot;] = require &quot;lulpeg&quot;
end

do
  -- http://chiselapp.com/user/dhkolf/repository/dkjson/
  local dkjson = require &quot;dkjson&quot;
  dkencode = dkjson.encode
  dkdecode = dkjson.decode
end

if test_module == 'cmj-json' then
  -- https://github.com/craigmj/json4lua/
  -- http://json.luaforge.net/
  local json = require &quot;cmjjson&quot; -- renamed, the original file was just 'json'
  encode = json.encode
  decode = json.decode
elseif test_module == 'dkjson' then
  -- http://chiselapp.com/user/dhkolf/repository/dkjson/
  encode = dkencode
  decode = dkdecode
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
  -- https://github.com/harningt/luajson
  -- http://luaforge.net/projects/luajson/
  local json = require &quot;json&quot;
  encode = json.encode
  decode = json.decode
else
  print &quot;No module specified&quot;
  return
end

if not encode then
  print (&quot;No encode method&quot;)
else
  local x, r

  local escapecodes = {
    [&quot;\&quot;&quot;] = &quot;\\\&quot;&quot;, [&quot;\\&quot;] = &quot;\\\\&quot;, [&quot;\b&quot;] = &quot;\\b&quot;, [&quot;\f&quot;] = &quot;\\f&quot;,
    [&quot;\n&quot;] = &quot;\\n&quot;,  [&quot;\r&quot;] = &quot;\\r&quot;,  [&quot;\t&quot;] = &quot;\\t&quot;, [&quot;/&quot;] = &quot;\\/&quot;
  }
  local function test (x, n, expect)
    local enc = encode{ x }:match(&quot;^%s*%[%s*%\&quot;(.-)%\&quot;%s*%]%s*$&quot;)
    if not enc or (escapecodes[x] ~= enc
        and (&quot;\\u%04x&quot;):format(n) ~= enc:gsub(&quot;[A-F]&quot;, string.lower)
        and not (expect and enc:match(&quot;^&quot;..expect..&quot;$&quot;))) then
      print((&quot;U+%04X isn't encoded correctly: %q&quot;):format(n, enc))
    end
  end

  -- necessary escapes for JSON:
  for i = 0,31 do
    test(string.char(i), i)
  end
  test(&quot;\&quot;&quot;, (&quot;\&quot;&quot;):byte())
  test(&quot;\\&quot;, (&quot;\\&quot;):byte())
  -- necessary escapes for JavaScript:
  test(&quot;\226\128\168&quot;, 0x2028)
  test(&quot;\226\128\169&quot;, 0x2029)
  -- invalid escapes that were seen in the wild:
  test(&quot;'&quot;, (&quot;'&quot;):byte(), &quot;%'&quot;)

  r,x = pcall (encode, { [1000] = &quot;x&quot; })
  if not r then
    print (&quot;encoding a sparse array (#=0) raises an error:&quot;, x)
  else
    if #x &gt; 30 then
      print (&quot;sparse array (#=0) encoded as:&quot;, x:sub(1,15)..&quot; &lt;...&gt; &quot;..x:sub(-15,-1), &quot;#&quot;..#x)
    else
      print (&quot;sparse array (#=0) encoded as:&quot;, x)
    end
  end

  r,x = pcall (encode, { [1] = &quot;a&quot;, [1000] = &quot;x&quot; })
  if not r then
    print (&quot;encoding a sparse array (#=1) raises an error:&quot;, x)
  else
    if #x &gt; 30 then
      print (&quot;sparse array (#=1) encoded as:&quot;, x:sub(1,15)..&quot; &lt;...&gt; &quot;..x:sub(-15,-1), &quot;#str=&quot;..#x)
    else
      print (&quot;sparse array (#=1) encoded as:&quot;, x)
    end
  end

  r,x = pcall (encode, { [1] = &quot;a&quot;, [5] = &quot;c&quot;, [&quot;x&quot;] = &quot;x&quot; })
  if not r then
    print (&quot;encoding a mixed table raises an error:&quot;, x)
  else
    print (&quot;mixed table encoded as:&quot;, x)
  end

  r, x = pcall(encode, { math.huge*0 }) -- NaN
  if not r then
    print (&quot;encoding NaN raises an error:&quot;, x)
  else
    r = dkdecode(x)
    if not r then
      print (&quot;NaN isn't converted into valid JSON:&quot;, x)
    elseif type(r[1]) == &quot;number&quot; and r[1] == r[1] then -- a number, but not NaN
      print (&quot;NaN is converted into a valid number:&quot;, x)
    else
      print (&quot;NaN is converted to:&quot;, x)
    end
  end

  if test_module == 'fleece' then
    print (&quot;Fleece (0.3.1) is known to freeze on +/-Inf&quot;)
  else
    r, x = pcall(encode, { math.huge }) -- +Inf
    if not r then
      print (&quot;encoding +Inf raises an error:&quot;, x)
    else
      r = dkdecode(x)
      if not r then
        print (&quot;+Inf isn't converted into valid JSON:&quot;, x)
      else
        print (&quot;+Inf is converted to:&quot;, x)
      end
    end

    r, x = pcall(encode, { -math.huge }) -- -Inf
    if not r then
      print (&quot;encoding -Inf raises an error:&quot;, x)
    else
      r = dkdecode(x)
      if not r then
        print (&quot;-Inf isn't converted into valid JSON:&quot;, x)
      else
        print (&quot;-Inf is converted to:&quot;, x)
      end
    end
  end

  inlocale(function ()
    local r, x = pcall(encode, { 0.5 })
    if not r then
      print(&quot;encoding 0.5 in locale raises an error:&quot;, x)
    elseif not x:find(&quot;.&quot;, 1, true) then
      print(&quot;In locale 0.5 isn't converted into valid JSON:&quot;, x)
    end
  end)

  -- special tests for dkjson:
  if test_module == 'dkjson' then
    do -- encode a function
      local why, value, exstate
      local state = {
        exception = function (w, v, s)
          why, value, exstate = w, v, s
          return &quot;\&quot;demo\&quot;&quot;
        end
      }
      local encfunction = function () end
      r, x = pcall(dkencode, { encfunction }, state )
      if not r then
        print(&quot;encoding a function with exception handler raises an error:&quot;, x)
      else
        if x ~= &quot;[\&quot;demo\&quot;]&quot; then
          print(&quot;expected to see output of exception handler for type exception, but got&quot;, x)
        end
        if why ~= &quot;unsupported type&quot; then
          print(&quot;expected exception reason to be 'unsupported type' for type exception&quot;)
        end
        if value ~= encfunction then
          print(&quot;expected to recieve value for type exception&quot;)
        end
        if exstate ~= state then
          print(&quot;expected to recieve state for type exception&quot;)
        end
      end

      r, x = pcall(dkencode, { function () end }, {
        exception = function (w, v, s)
          return nil, &quot;demo&quot;
        end
      })
      if r or x ~= &quot;demo&quot; then
        print(&quot;expected custom error for type exception, but got:&quot;, r, x)
      end

      r, x = pcall(dkencode, { function () end }, {
        exception = function (w, v, s)
          return nil
        end
      })
      if r or x ~= &quot;type 'function' is not supported by JSON.&quot; then
        print(&quot;expected default error for type exception, but got:&quot;, r, x)
      end
    end

    do -- encode a reference cycle
      local why, value, exstate
      local state = {
        exception = function (w, v, s)
          why, value, exstate = w, v, s
          return &quot;\&quot;demo\&quot;&quot;
        end
      }
      local a = {}
      a[1] = a
      r, x = pcall(dkencode, a, state )
      if not r then
        print(&quot;encoding a reference cycle with exception handler raises an error:&quot;, x)
      else
        if x ~= &quot;[\&quot;demo\&quot;]&quot; then
          print(&quot;expected to see output of exception handler for reference cycle exception, but got&quot;, x)
        end
        if why ~= &quot;reference cycle&quot; then
          print(&quot;expected exception reason to be 'reference cycle' for reference cycle exception&quot;)
        end
        if value ~= a then
          print(&quot;expected to recieve value for reference cycle exception&quot;)
        end
        if exstate ~= state then
          print(&quot;expected to recieve state for reference cycle exception&quot;)
        end
      end
    end

    do -- example exception handler
      r = dkencode(function () end, { exception = require &quot;dkjson&quot;.encodeexception })
      if r ~= [[&quot;&lt;type 'function' is not supported by JSON.&gt;&quot;]] then
        print(&quot;expected the exception encoder to encode default error message, but got&quot;, r)
      end
    end

    do -- test state buffer for custom __tojson function
      local origstate = {}
      local usedstate, usedbuffer, usedbufferlen
      dkencode({ setmetatable({}, {
        __tojson = function(self, state)
          usedstate = state
          usedbuffer = state.buffer
          usedbufferlen = state.bufferlen
          return true
        end
      }) }, origstate)
      if usedstate ~= origstate then print(&quot;expected tojson-function to recieve the original state&quot;)  end
      if type(usedbuffer) ~= 'table' or #usedbuffer &lt; 1 then print(&quot;expected buffer in tojson-function to be an array&quot;) end
      if usedbufferlen ~= 1 then print(&quot;expected bufferlen in tojson-function to be 1, but got &quot;..tostring(usedbufferlen)) end
    end

    do -- do not keep buffer and bufferlen when they were not present initially
      local origstate = {}
      dkencode(setmetatable({}, {__tojson = function() return true end}), origstate)
      if origstate.buffer ~= nil then print(&quot;expected buffer to be reset to nil&quot;) end
      if origstate.bufferlen ~= nil then print(&quot;expected bufferlen to be reset to nil&quot;) end
    end

    do -- keep buffer and update bufferlen when they were present initially
      local origbuffer = {}
      local origstate = { buffer = origbuffer }
      dkencode(true, origstate)
      if origstate.buffer ~= origbuffer then print(&quot;expected original buffer to remain&quot;) end
      if origstate.bufferlen ~= 1 then print(&quot;expected bufferlen to be updated&quot;) end
    end
  end
end

if not decode then
  print (&quot;No decode method&quot;)
else
  local x, r

  x = decode[=[ [&quot;\u0000&quot;] ]=]
  if x[1] ~= &quot;\000&quot; then
    print (&quot;\\u0000 isn't decoded correctly&quot;)
  end

  x = decode[=[ [&quot;\u20AC&quot;] ]=]
  if x[1] ~= &quot;\226\130\172&quot; then
    print (&quot;\\u20AC isn't decoded correctly&quot;)
  end

  x = decode[=[ [&quot;\uD834\uDD1E&quot;] ]=]
  if x[1] ~= &quot;\240\157\132\158&quot; then
    print (&quot;\\uD834\\uDD1E isn't decoded correctly&quot;)
  end

  r, x = pcall(decode, [=[
{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:
{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:
{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:
{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;: {&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:{&quot;x&quot;:
&quot;deep down&quot;
    }    }    }    }    }     }    }    }    }    }     }    }    }    }    }
    }    }    }    }    }     }    }    }    }    }     }    }    }    }    }
    }    }    }    }    }     }    }    }    }    }     }    }    }    }    }
    }    }    }    }    }     }    }    }    }    }     }    }    }    }    }
]=])

  if not r then
    print (&quot;decoding a deep nested table raises an error:&quot;, x)
  else
    local i = 0
    while type(x) == 'table' do
      i = i + 1
      x = x.x
    end
    if i ~= 60 or x ~= &quot;deep down&quot; then
      print (&quot;deep nested table isn't decoded correctly&quot;)
    end
  end

  if false and test_module == 'cmj-json' then
    -- unfortunatly the version can't be read
    print (&quot;decoding a big array takes ages (or forever?) on cmj-json prior to version 0.9.5&quot;)
  else
    r, x = pcall(decode, &quot;[&quot;..(&quot;0,&quot;):rep(100000)..&quot;0]&quot;)
    if not r then
      print (&quot;decoding a big array raises an error:&quot;, x)
    else
      if type(x) ~= 'table' or #x ~= 100001 then
        print (&quot;big array isn't decoded correctly&quot;)
      end
    end
  end

  r, x = pcall(decode, &quot;{}&quot;)
  if not r then
    print (&quot;decoding an empty object raises an error:&quot;, x)
  end

  r, x = pcall(decode, &quot;[]&quot;)
  if not r then
    print (&quot;decoding an empty array raises an error:&quot;, x)
  end

  r, x = pcall(decode, &quot;[1e+2]&quot;)
  if not r then
    print (&quot;decoding a number with exponential notation raises an error:&quot;, x)
  elseif x[1] ~= 1e+2 then
    print (&quot;1e+2 decoded incorrectly:&quot;, r[1])
  end

  inlocale(function ()
    local r, x = pcall(decode, &quot;[0.5]&quot;)
    if not r then
      print(&quot;decoding 0.5 in locale raises an error:&quot;, x)
    elseif not x then
      print(&quot;cannot decode 0.5 in locale&quot;)
    elseif x[1] ~= 0.5 then
      print(&quot;decoded 0.5 incorrectly in locale:&quot;, x[1])
    end
  end)

  -- special tests for dkjson:
  if test_module == 'dkjson' then
    x = dkdecode[=[ [{&quot;x&quot;:0}] ]=]
    local m = getmetatable(x)
    if not m or m.__jsontype ~= 'array' then
      print (&quot;&lt;metatable&gt;.__jsontype ~= array&quot;)
    end
    local m = getmetatable(x[1])
    if not m or m.__jsontype ~= 'object' then
      print (&quot;&lt;metatable&gt;.__jsontype ~= object&quot;)
    end
    
    local x,p,m = dkdecode&quot; invalid &quot;
    if p ~= 2 or type(m) ~= 'string' or not m:find(&quot;at line 1, column 2$&quot;) then
      print ((&quot;Invalid location: position=%d, message=%q&quot;):format(p,m))
    end
    local x,p,m = dkdecode&quot; \n invalid &quot;
    if p ~= 4 or type(m) ~= 'string' or not m:find(&quot;at line 2, column 2$&quot;) then
      print ((&quot;Invalid location: position=%d, message=%q&quot;):format(p,m))
    end

    do -- single line comments
      local x, p, m  = dkdecode [[
{&quot;test://&quot; // comment // --?
   : [  // continues
   0]   //
}
]]
      if type(x) ~= 'table' or type(x[&quot;test://&quot;]) ~= 'table' or x[&quot;test://&quot;][1] ~= 0 then
        print(&quot;could not decode a string with single line comments: &quot;..tostring(m))
      end
    end

    do -- multi line comments
      local x, p, m  = dkdecode [[
{&quot;test:/*&quot;/**//*
   hi! this is a comment
*/   : [/** / **/  0]
}
]]
      if type(x) ~= 'table' or type(x[&quot;test:/*&quot;]) ~= 'table' or x[&quot;test:/*&quot;][1] ~= 0 then
        print(&quot;could not decode a string with multi line comments: &quot;..tostring(m))
      end
    end
  end
end

if encode and opt == &quot;refcycle&quot; then
  local a = {}
  a.a = a
  print (&quot;Trying a reference cycle...&quot;)
  encode(a)
end

if encode and (opt or &quot;&quot;):sub(1,3) == &quot;esc&quot; then

local strchar, strbyte, strformat = string.char, string.byte, string.format
local floor = math.floor

local function unichar (value)
  if value &lt; 0 then
    return nil
  elseif value &lt;= 0x007f then
    return strchar (value)
  elseif value &lt;= 0x07ff then
    return strchar (0xc0 + floor(value/0x40),
                    0x80 + (floor(value) % 0x40))
  elseif value &lt;= 0xffff then
    return strchar (0xe0 + floor(value/0x1000),
                    0x80 + (floor(value/0x40) % 0x40),
                    0x80 + (floor(value) % 0x40))
  elseif value &lt;= 0x10ffff then
    return strchar (0xf0 + floor(value/0x40000),
                    0x80 + (floor(value/0x1000) % 0x40),
                    0x80 + (floor(value/0x40) % 0x40),
                    0x80 + (floor(value) % 0x40))
  else
    return nil
  end
end

local escapecodes = {
  [&quot;\&quot;&quot;] = &quot;\\\&quot;&quot;, [&quot;\\&quot;] = &quot;\\\\&quot;, [&quot;\b&quot;] = &quot;\\b&quot;, [&quot;\f&quot;] = &quot;\\f&quot;,
  [&quot;\n&quot;] = &quot;\\n&quot;,  [&quot;\r&quot;] = &quot;\\r&quot;,  [&quot;\t&quot;] = &quot;\\t&quot;, [&quot;/&quot;] = &quot;\\/&quot;
}

local function escapeutf8 (uchar)
  local a, b, c, d = strbyte (uchar, 1, 4)
  a, b, c, d = a or 0, b or 0, c or 0, d or 0
  if a &lt;= 0x7f then
    value = a
  elseif 0xc0 &lt;= a and a &lt;= 0xdf and b &gt;= 0x80 then
    value = (a - 0xc0) * 0x40 + b - 0x80
  elseif 0xe0 &lt;= a and a &lt;= 0xef and b &gt;= 0x80 and c &gt;= 0x80 then
    value = ((a - 0xe0) * 0x40 + b - 0x80) * 0x40 + c - 0x80
  elseif 0xf0 &lt;= a and a &lt;= 0xf7 and b &gt;= 0x80 and c &gt;= 0x80 and d &gt;= 0x80 then
    value = (((a - 0xf0) * 0x40 + b - 0x80) * 0x40 + c - 0x80) * 0x40 + d - 0x80
  else
    return &quot;&quot;
  end
  if value &lt;= 0xffff then
    return strformat (&quot;\\u%.4x&quot;, value)
  elseif value &lt;= 0x10ffff then
    -- encode as UTF-16 surrogate pair
    value = value - 0x10000
    local highsur, lowsur = 0xD800 + floor (value/0x400), 0xDC00 + (value % 0x400)
    return strformat (&quot;\\u%.4x\\u%.4x&quot;, highsur, lowsur)
  else
    return &quot;&quot;
  end
end

  local isspecial = {}
  local unifile = io.open(&quot;UnicodeData.txt&quot;)
  if unifile then
    -- &lt;http://www.unicode.org/Public/UNIDATA/UnicodeData.txt&gt;
    -- each line consists of 15 parts for each defined codepoints
    local pat = {}
    for i = 1,14 do
      pat[i] = &quot;[^;]*;&quot;
    end
    pat[1] = &quot;([^;]*);&quot; -- Codepoint
    pat[3] = &quot;([^;]*);&quot; -- Category
    pat[15] = &quot;[^;]*&quot;
    pat = table.concat(pat)

    for line in unifile:lines() do
      local cp, cat = line:match(pat)
      if cat:match(&quot;^C[^so]&quot;) or cat:match(&quot;^Z[lp]&quot;) then
        isspecial[tonumber(cp, 16)] = cat
      end
    end
    unifile:close()
  end

  local x,xe

  local t = {}
  local esc = {}
  local escerr = {}
  local range
  if opt == &quot;esc_full&quot; then range = 0x10ffff
  elseif opt == &quot;esc_asc&quot; then range = 0x7f
  else range = 0xffff end

  for i = 0,range do
    t[1] = unichar(i)
    xe = encode(t)
    x = string.match(xe, &quot;^%s*%[%s*%\&quot;(.*)%\&quot;%s*%]%s*$&quot;)
    if type(x) ~= 'string' then
      escerr[i] = xe
    elseif string.lower(x) == escapeutf8(t[1]) then
      esc[i] = 'u'
    elseif x == escapecodes[t[1]] then
      esc[i] = 'c'
    elseif x:sub(1,1) == &quot;\\&quot; then
      escerr[i] = xe
    end
  end
  do
    local i = 0
    while i &lt;= range do
      local first
      while i &lt;= range and not (esc[i] or isspecial[i]) do i = i + 1 end
      if i &gt; range then break end
      first = i
      local special = isspecial[i]
      if esc[i] and special then
        while esc[i] and isspecial[i] == special do i = i + 1 end
        if i-1 &gt; first then
          print ((&quot;Escaped %s characters from U+%04X to U+%04X&quot;):format(special,first,i-1))
        else
          print ((&quot;Escaped %s character U+%04X&quot;):format(special,first))
        end
      elseif esc[i] then
        while esc[i] and not isspecial[i] do i = i + 1 end
        if i-1 &gt; first then
          print ((&quot;Escaped from U+%04X to U+%04X&quot;):format(first,i-1))
        else
          if first &gt;= 32 and first &lt;= 127 then
            print ((&quot;Escaped U+%04X (%c)&quot;):format(first,first))
          else
            print ((&quot;Escaped U+%04X&quot;):format(first))
          end
        end
      elseif special then
        while not esc[i] and isspecial[i] == special do i = i + 1 end
        if i-1 &gt; first then
          print ((&quot;Unescaped %s characters from U+%04X to U+%04X&quot;):format(special,first,i-1))
        else
          print ((&quot;Unescaped %s character U+%04X&quot;):format(special,first))
        end
      end
    end
  end
  do
    local i = 0
    while i &lt;= range do
      local first
      while i &lt;= range and not escerr[i] do i = i + 1 end
      if not escerr[i] then break end
      first = i
      while escerr[i] do i = i + 1 end
      if i-1 &gt; first then
        print ((&quot;Errors while escaping from U+%04X to U+%04X&quot;):format(first, i-1))
      else
        print ((&quot;Errors while escaping U+%04X&quot;):format(first))
      end
    end
  end

end

-- Copyright (C) 2011 David Heiko Kolf
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- &quot;Software&quot;), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
-- 
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE. 
