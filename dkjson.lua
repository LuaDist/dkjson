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
<a class="label" href="/src/dkjson-lua.fsl/timeline?n=200&amp;uf=19fd705cf41e4977b7fe04c79c0808b079836024">Checkins Using</a>
<a class="label" href="/src/dkjson-lua.fsl/raw/dkjson.lua?name=19fd705cf41e4977b7fe04c79c0808b079836024">Download</a>
<a class="label" href="/src/dkjson-lua.fsl/hexdump?name=19fd705cf41e4977b7fe04c79c0808b079836024">Hex</a>
</div>
<div class="content">
<script>
function gebi(x){
if(/^#/.test(x)) x = x.substr(1);
var e = document.getElementById(x);
if(!e) throw new Error("Expecting element with ID "+x);
else return e;}
</script>
<h2>Artifact 19fd705cf41e4977b7fe04c79c0808b079836024:</h2>
<ul>
<li>File
<a id='a1' href='/src/dkjson-lua.fsl/honeypot'>dkjson.lua</a>
<ul>
<li>
2014-04-28 21:16:16
- part of checkin
<span class="timelineHistDsp">[3d24a61dd0]</span>
on branch <a id='a2' href='/src/dkjson-lua.fsl/honeypot'>trunk</a>
- fix line breaks in readme.txt, fix release year
 (user:
dhkolf
</ul>
</ul>
<hr />
<blockquote>
<pre>
-- Module options:
local always_try_using_lpeg = true
local register_global_module_table = false
local global_module_name = 'json'

--[==[

David Kolf's JSON module for Lua 5.1/5.2

Version 2.5


For the documentation see the corresponding readme.txt or visit
&lt;http://dkolf.de/src/dkjson-lua.fsl/&gt;.

You can contact the author by sending an e-mail to 'david' at the
domain 'dkolf.de'.


Copyright (C) 2010-2014 David Heiko Kolf

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
&quot;Software&quot;), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]==]

-- global dependencies:
local pairs, type, tostring, tonumber, getmetatable, setmetatable, rawset =
      pairs, type, tostring, tonumber, getmetatable, setmetatable, rawset
local error, require, pcall, select = error, require, pcall, select
local floor, huge = math.floor, math.huge
local strrep, gsub, strsub, strbyte, strchar, strfind, strlen, strformat =
      string.rep, string.gsub, string.sub, string.byte, string.char,
      string.find, string.len, string.format
local strmatch = string.match
local concat = table.concat

local json = { version = &quot;dkjson 2.5&quot; }

if register_global_module_table then
  _G[global_module_name] = json
end

local _ENV = nil -- blocking globals in Lua 5.2

pcall (function()
  -- Enable access to blocked metatables.
  -- Don't worry, this module doesn't change anything in them.
  local debmeta = require &quot;debug&quot;.getmetatable
  if debmeta then getmetatable = debmeta end
end)

json.null = setmetatable ({}, {
  __tojson = function () return &quot;null&quot; end
})

local function isarray (tbl)
  local max, n, arraylen = 0, 0, 0
  for k,v in pairs (tbl) do
    if k == 'n' and type(v) == 'number' then
      arraylen = v
      if v &gt; max then
        max = v
      end
    else
      if type(k) ~= 'number' or k &lt; 1 or floor(k) ~= k then
        return false
      end
      if k &gt; max then
        max = k
      end
      n = n + 1
    end
  end
  if max &gt; 10 and max &gt; arraylen and max &gt; n * 2 then
    return false -- don't create an array with too many holes
  end
  return true, max
end

local escapecodes = {
  [&quot;\&quot;&quot;] = &quot;\\\&quot;&quot;, [&quot;\\&quot;] = &quot;\\\\&quot;, [&quot;\b&quot;] = &quot;\\b&quot;, [&quot;\f&quot;] = &quot;\\f&quot;,
  [&quot;\n&quot;] = &quot;\\n&quot;,  [&quot;\r&quot;] = &quot;\\r&quot;,  [&quot;\t&quot;] = &quot;\\t&quot;
}

local function escapeutf8 (uchar)
  local value = escapecodes[uchar]
  if value then
    return value
  end
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

local function fsub (str, pattern, repl)
  -- gsub always builds a new string in a buffer, even when no match
  -- exists. First using find should be more efficient when most strings
  -- don't contain the pattern.
  if strfind (str, pattern) then
    return gsub (str, pattern, repl)
  else
    return str
  end
end

local function quotestring (value)
  -- based on the regexp &quot;escapable&quot; in https://github.com/douglascrockford/JSON-js
  value = fsub (value, &quot;[%z\1-\31\&quot;\\\127]&quot;, escapeutf8)
  if strfind (value, &quot;[\194\216\220\225\226\239]&quot;) then
    value = fsub (value, &quot;\194[\128-\159\173]&quot;, escapeutf8)
    value = fsub (value, &quot;\216[\128-\132]&quot;, escapeutf8)
    value = fsub (value, &quot;\220\143&quot;, escapeutf8)
    value = fsub (value, &quot;\225\158[\180\181]&quot;, escapeutf8)
    value = fsub (value, &quot;\226\128[\140-\143\168-\175]&quot;, escapeutf8)
    value = fsub (value, &quot;\226\129[\160-\175]&quot;, escapeutf8)
    value = fsub (value, &quot;\239\187\191&quot;, escapeutf8)
    value = fsub (value, &quot;\239\191[\176-\191]&quot;, escapeutf8)
  end
  return &quot;\&quot;&quot; .. value .. &quot;\&quot;&quot;
end
json.quotestring = quotestring

local function replace(str, o, n)
  local i, j = strfind (str, o, 1, true)
  if i then
    return strsub(str, 1, i-1) .. n .. strsub(str, j+1, -1)
  else
    return str
  end
end

-- locale independent num2str and str2num functions
local decpoint, numfilter

local function updatedecpoint ()
  decpoint = strmatch(tostring(0.5), &quot;([^05+])&quot;)
  -- build a filter that can be used to remove group separators
  numfilter = &quot;[^0-9%-%+eE&quot; .. gsub(decpoint, &quot;[%^%$%(%)%%%.%[%]%*%+%-%?]&quot;, &quot;%%%0&quot;) .. &quot;]+&quot;
end

updatedecpoint()

local function num2str (num)
  return replace(fsub(tostring(num), numfilter, &quot;&quot;), decpoint, &quot;.&quot;)
end

local function str2num (str)
  local num = tonumber(replace(str, &quot;.&quot;, decpoint))
  if not num then
    updatedecpoint()
    num = tonumber(replace(str, &quot;.&quot;, decpoint))
  end
  return num
end

local function addnewline2 (level, buffer, buflen)
  buffer[buflen+1] = &quot;\n&quot;
  buffer[buflen+2] = strrep (&quot;  &quot;, level)
  buflen = buflen + 2
  return buflen
end

function json.addnewline (state)
  if state.indent then
    state.bufferlen = addnewline2 (state.level or 0,
                           state.buffer, state.bufferlen or #(state.buffer))
  end
end

local encode2 -- forward declaration

local function addpair (key, value, prev, indent, level, buffer, buflen, tables, globalorder, state)
  local kt = type (key)
  if kt ~= 'string' and kt ~= 'number' then
    return nil, &quot;type '&quot; .. kt .. &quot;' is not supported as a key by JSON.&quot;
  end
  if prev then
    buflen = buflen + 1
    buffer[buflen] = &quot;,&quot;
  end
  if indent then
    buflen = addnewline2 (level, buffer, buflen)
  end
  buffer[buflen+1] = quotestring (key)
  buffer[buflen+2] = &quot;:&quot;
  return encode2 (value, indent, level, buffer, buflen + 2, tables, globalorder, state)
end

local function appendcustom(res, buffer, state)
  local buflen = state.bufferlen
  if type (res) == 'string' then
    buflen = buflen + 1
    buffer[buflen] = res
  end
  return buflen
end

local function exception(reason, value, state, buffer, buflen, defaultmessage)
  defaultmessage = defaultmessage or reason
  local handler = state.exception
  if not handler then
    return nil, defaultmessage
  else
    state.bufferlen = buflen
    local ret, msg = handler (reason, value, state, defaultmessage)
    if not ret then return nil, msg or defaultmessage end
    return appendcustom(ret, buffer, state)
  end
end

function json.encodeexception(reason, value, state, defaultmessage)
  return quotestring(&quot;&lt;&quot; .. defaultmessage .. &quot;&gt;&quot;)
end

encode2 = function (value, indent, level, buffer, buflen, tables, globalorder, state)
  local valtype = type (value)
  local valmeta = getmetatable (value)
  valmeta = type (valmeta) == 'table' and valmeta -- only tables
  local valtojson = valmeta and valmeta.__tojson
  if valtojson then
    if tables[value] then
      return exception('reference cycle', value, state, buffer, buflen)
    end
    tables[value] = true
    state.bufferlen = buflen
    local ret, msg = valtojson (value, state)
    if not ret then return exception('custom encoder failed', value, state, buffer, buflen, msg) end
    tables[value] = nil
    buflen = appendcustom(ret, buffer, state)
  elseif value == nil then
    buflen = buflen + 1
    buffer[buflen] = &quot;null&quot;
  elseif valtype == 'number' then
    local s
    if value ~= value or value &gt;= huge or -value &gt;= huge then
      -- This is the behaviour of the original JSON implementation.
      s = &quot;null&quot;
    else
      s = num2str (value)
    end
    buflen = buflen + 1
    buffer[buflen] = s
  elseif valtype == 'boolean' then
    buflen = buflen + 1
    buffer[buflen] = value and &quot;true&quot; or &quot;false&quot;
  elseif valtype == 'string' then
    buflen = buflen + 1
    buffer[buflen] = quotestring (value)
  elseif valtype == 'table' then
    if tables[value] then
      return exception('reference cycle', value, state, buffer, buflen)
    end
    tables[value] = true
    level = level + 1
    local isa, n = isarray (value)
    if n == 0 and valmeta and valmeta.__jsontype == 'object' then
      isa = false
    end
    local msg
    if isa then -- JSON array
      buflen = buflen + 1
      buffer[buflen] = &quot;[&quot;
      for i = 1, n do
        buflen, msg = encode2 (value[i], indent, level, buffer, buflen, tables, globalorder, state)
        if not buflen then return nil, msg end
        if i &lt; n then
          buflen = buflen + 1
          buffer[buflen] = &quot;,&quot;
        end
      end
      buflen = buflen + 1
      buffer[buflen] = &quot;]&quot;
    else -- JSON object
      local prev = false
      buflen = buflen + 1
      buffer[buflen] = &quot;{&quot;
      local order = valmeta and valmeta.__jsonorder or globalorder
      if order then
        local used = {}
        n = #order
        for i = 1, n do
          local k = order[i]
          local v = value[k]
          if v then
            used[k] = true
            buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
            prev = true -- add a seperator before the next element
          end
        end
        for k,v in pairs (value) do
          if not used[k] then
            buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
            if not buflen then return nil, msg end
            prev = true -- add a seperator before the next element
          end
        end
      else -- unordered
        for k,v in pairs (value) do
          buflen, msg = addpair (k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
          if not buflen then return nil, msg end
          prev = true -- add a seperator before the next element
        end
      end
      if indent then
        buflen = addnewline2 (level - 1, buffer, buflen)
      end
      buflen = buflen + 1
      buffer[buflen] = &quot;}&quot;
    end
    tables[value] = nil
  else
    return exception ('unsupported type', value, state, buffer, buflen,
      &quot;type '&quot; .. valtype .. &quot;' is not supported by JSON.&quot;)
  end
  return buflen
end

function json.encode (value, state)
  state = state or {}
  local oldbuffer = state.buffer
  local buffer = oldbuffer or {}
  state.buffer = buffer
  updatedecpoint()
  local ret, msg = encode2 (value, state.indent, state.level or 0,
                   buffer, state.bufferlen or 0, state.tables or {}, state.keyorder, state)
  if not ret then
    error (msg, 2)
  elseif oldbuffer == buffer then
    state.bufferlen = ret
    return true
  else
    state.bufferlen = nil
    state.buffer = nil
    return concat (buffer)
  end
end

local function loc (str, where)
  local line, pos, linepos = 1, 1, 0
  while true do
    pos = strfind (str, &quot;\n&quot;, pos, true)
    if pos and pos &lt; where then
      line = line + 1
      linepos = pos
      pos = pos + 1
    else
      break
    end
  end
  return &quot;line &quot; .. line .. &quot;, column &quot; .. (where - linepos)
end

local function unterminated (str, what, where)
  return nil, strlen (str) + 1, &quot;unterminated &quot; .. what .. &quot; at &quot; .. loc (str, where)
end

local function scanwhite (str, pos)
  while true do
    pos = strfind (str, &quot;%S&quot;, pos)
    if not pos then return nil end
    local sub2 = strsub (str, pos, pos + 1)
    if sub2 == &quot;\239\187&quot; and strsub (str, pos + 2, pos + 2) == &quot;\191&quot; then
      -- UTF-8 Byte Order Mark
      pos = pos + 3
    elseif sub2 == &quot;//&quot; then
      pos = strfind (str, &quot;[\n\r]&quot;, pos + 2)
      if not pos then return nil end
    elseif sub2 == &quot;/*&quot; then
      pos = strfind (str, &quot;*/&quot;, pos + 2)
      if not pos then return nil end
      pos = pos + 2
    else
      return pos
    end
  end
end

local escapechars = {
  [&quot;\&quot;&quot;] = &quot;\&quot;&quot;, [&quot;\\&quot;] = &quot;\\&quot;, [&quot;/&quot;] = &quot;/&quot;, [&quot;b&quot;] = &quot;\b&quot;, [&quot;f&quot;] = &quot;\f&quot;,
  [&quot;n&quot;] = &quot;\n&quot;, [&quot;r&quot;] = &quot;\r&quot;, [&quot;t&quot;] = &quot;\t&quot;
}

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

local function scanstring (str, pos)
  local lastpos = pos + 1
  local buffer, n = {}, 0
  while true do
    local nextpos = strfind (str, &quot;[\&quot;\\]&quot;, lastpos)
    if not nextpos then
      return unterminated (str, &quot;string&quot;, pos)
    end
    if nextpos &gt; lastpos then
      n = n + 1
      buffer[n] = strsub (str, lastpos, nextpos - 1)
    end
    if strsub (str, nextpos, nextpos) == &quot;\&quot;&quot; then
      lastpos = nextpos + 1
      break
    else
      local escchar = strsub (str, nextpos + 1, nextpos + 1)
      local value
      if escchar == &quot;u&quot; then
        value = tonumber (strsub (str, nextpos + 2, nextpos + 5), 16)
        if value then
          local value2
          if 0xD800 &lt;= value and value &lt;= 0xDBff then
            -- we have the high surrogate of UTF-16. Check if there is a
            -- low surrogate escaped nearby to combine them.
            if strsub (str, nextpos + 6, nextpos + 7) == &quot;\\u&quot; then
              value2 = tonumber (strsub (str, nextpos + 8, nextpos + 11), 16)
              if value2 and 0xDC00 &lt;= value2 and value2 &lt;= 0xDFFF then
                value = (value - 0xD800)  * 0x400 + (value2 - 0xDC00) + 0x10000
              else
                value2 = nil -- in case it was out of range for a low surrogate
              end
            end
          end
          value = value and unichar (value)
          if value then
            if value2 then
              lastpos = nextpos + 12
            else
              lastpos = nextpos + 6
            end
          end
        end
      end
      if not value then
        value = escapechars[escchar] or escchar
        lastpos = nextpos + 2
      end
      n = n + 1
      buffer[n] = value
    end
  end
  if n == 1 then
    return buffer[1], lastpos
  elseif n &gt; 1 then
    return concat (buffer), lastpos
  else
    return &quot;&quot;, lastpos
  end
end

local scanvalue -- forward declaration

local function scantable (what, closechar, str, startpos, nullval, objectmeta, arraymeta)
  local len = strlen (str)
  local tbl, n = {}, 0
  local pos = startpos + 1
  if what == 'object' then
    setmetatable (tbl, objectmeta)
  else
    setmetatable (tbl, arraymeta)
  end
  while true do
    pos = scanwhite (str, pos)
    if not pos then return unterminated (str, what, startpos) end
    local char = strsub (str, pos, pos)
    if char == closechar then
      return tbl, pos + 1
    end
    local val1, err
    val1, pos, err = scanvalue (str, pos, nullval, objectmeta, arraymeta)
    if err then return nil, pos, err end
    pos = scanwhite (str, pos)
    if not pos then return unterminated (str, what, startpos) end
    char = strsub (str, pos, pos)
    if char == &quot;:&quot; then
      if val1 == nil then
        return nil, pos, &quot;cannot use nil as table index (at &quot; .. loc (str, pos) .. &quot;)&quot;
      end
      pos = scanwhite (str, pos + 1)
      if not pos then return unterminated (str, what, startpos) end
      local val2
      val2, pos, err = scanvalue (str, pos, nullval, objectmeta, arraymeta)
      if err then return nil, pos, err end
      tbl[val1] = val2
      pos = scanwhite (str, pos)
      if not pos then return unterminated (str, what, startpos) end
      char = strsub (str, pos, pos)
    else
      n = n + 1
      tbl[n] = val1
    end
    if char == &quot;,&quot; then
      pos = pos + 1
    end
  end
end

scanvalue = function (str, pos, nullval, objectmeta, arraymeta)
  pos = pos or 1
  pos = scanwhite (str, pos)
  if not pos then
    return nil, strlen (str) + 1, &quot;no valid JSON value (reached the end)&quot;
  end
  local char = strsub (str, pos, pos)
  if char == &quot;{&quot; then
    return scantable ('object', &quot;}&quot;, str, pos, nullval, objectmeta, arraymeta)
  elseif char == &quot;[&quot; then
    return scantable ('array', &quot;]&quot;, str, pos, nullval, objectmeta, arraymeta)
  elseif char == &quot;\&quot;&quot; then
    return scanstring (str, pos)
  else
    local pstart, pend = strfind (str, &quot;^%-?[%d%.]+[eE]?[%+%-]?%d*&quot;, pos)
    if pstart then
      local number = str2num (strsub (str, pstart, pend))
      if number then
        return number, pend + 1
      end
    end
    pstart, pend = strfind (str, &quot;^%a%w*&quot;, pos)
    if pstart then
      local name = strsub (str, pstart, pend)
      if name == &quot;true&quot; then
        return true, pend + 1
      elseif name == &quot;false&quot; then
        return false, pend + 1
      elseif name == &quot;null&quot; then
        return nullval, pend + 1
      end
    end
    return nil, pos, &quot;no valid JSON value at &quot; .. loc (str, pos)
  end
end

local function optionalmetatables(...)
  if select(&quot;#&quot;, ...) &gt; 0 then
    return ...
  else
    return {__jsontype = 'object'}, {__jsontype = 'array'}
  end
end

function json.decode (str, pos, nullval, ...)
  local objectmeta, arraymeta = optionalmetatables(...)
  return scanvalue (str, pos, nullval, objectmeta, arraymeta)
end

function json.use_lpeg ()
  local g = require (&quot;lpeg&quot;)

  if g.version() == &quot;0.11&quot; then
    error &quot;due to a bug in LPeg 0.11, it cannot be used for JSON matching&quot;
  end

  local pegmatch = g.match
  local P, S, R = g.P, g.S, g.R

  local function ErrorCall (str, pos, msg, state)
    if not state.msg then
      state.msg = msg .. &quot; at &quot; .. loc (str, pos)
      state.pos = pos
    end
    return false
  end

  local function Err (msg)
    return g.Cmt (g.Cc (msg) * g.Carg (2), ErrorCall)
  end

  local SingleLineComment = P&quot;//&quot; * (1 - S&quot;\n\r&quot;)^0
  local MultiLineComment = P&quot;/*&quot; * (1 - P&quot;*/&quot;)^0 * P&quot;*/&quot;
  local Space = (S&quot; \n\r\t&quot; + P&quot;\239\187\191&quot; + SingleLineComment + MultiLineComment)^0

  local PlainChar = 1 - S&quot;\&quot;\\\n\r&quot;
  local EscapeSequence = (P&quot;\\&quot; * g.C (S&quot;\&quot;\\/bfnrt&quot; + Err &quot;unsupported escape sequence&quot;)) / escapechars
  local HexDigit = R(&quot;09&quot;, &quot;af&quot;, &quot;AF&quot;)
  local function UTF16Surrogate (match, pos, high, low)
    high, low = tonumber (high, 16), tonumber (low, 16)
    if 0xD800 &lt;= high and high &lt;= 0xDBff and 0xDC00 &lt;= low and low &lt;= 0xDFFF then
      return true, unichar ((high - 0xD800)  * 0x400 + (low - 0xDC00) + 0x10000)
    else
      return false
    end
  end
  local function UTF16BMP (hex)
    return unichar (tonumber (hex, 16))
  end
  local U16Sequence = (P&quot;\\u&quot; * g.C (HexDigit * HexDigit * HexDigit * HexDigit))
  local UnicodeEscape = g.Cmt (U16Sequence * U16Sequence, UTF16Surrogate) + U16Sequence/UTF16BMP
  local Char = UnicodeEscape + EscapeSequence + PlainChar
  local String = P&quot;\&quot;&quot; * g.Cs (Char ^ 0) * (P&quot;\&quot;&quot; + Err &quot;unterminated string&quot;)
  local Integer = P&quot;-&quot;^(-1) * (P&quot;0&quot; + (R&quot;19&quot; * R&quot;09&quot;^0))
  local Fractal = P&quot;.&quot; * R&quot;09&quot;^0
  local Exponent = (S&quot;eE&quot;) * (S&quot;+-&quot;)^(-1) * R&quot;09&quot;^1
  local Number = (Integer * Fractal^(-1) * Exponent^(-1))/str2num
  local Constant = P&quot;true&quot; * g.Cc (true) + P&quot;false&quot; * g.Cc (false) + P&quot;null&quot; * g.Carg (1)
  local SimpleValue = Number + String + Constant
  local ArrayContent, ObjectContent

  -- The functions parsearray and parseobject parse only a single value/pair
  -- at a time and store them directly to avoid hitting the LPeg limits.
  local function parsearray (str, pos, nullval, state)
    local obj, cont
    local npos
    local t, nt = {}, 0
    repeat
      obj, cont, npos = pegmatch (ArrayContent, str, pos, nullval, state)
      if not npos then break end
      pos = npos
      nt = nt + 1
      t[nt] = obj
    until cont == 'last'
    return pos, setmetatable (t, state.arraymeta)
  end

  local function parseobject (str, pos, nullval, state)
    local obj, key, cont
    local npos
    local t = {}
    repeat
      key, obj, cont, npos = pegmatch (ObjectContent, str, pos, nullval, state)
      if not npos then break end
      pos = npos
      t[key] = obj
    until cont == 'last'
    return pos, setmetatable (t, state.objectmeta)
  end

  local Array = P&quot;[&quot; * g.Cmt (g.Carg(1) * g.Carg(2), parsearray) * Space * (P&quot;]&quot; + Err &quot;']' expected&quot;)
  local Object = P&quot;{&quot; * g.Cmt (g.Carg(1) * g.Carg(2), parseobject) * Space * (P&quot;}&quot; + Err &quot;'}' expected&quot;)
  local Value = Space * (Array + Object + SimpleValue)
  local ExpectedValue = Value + Space * Err &quot;value expected&quot;
  ArrayContent = Value * Space * (P&quot;,&quot; * g.Cc'cont' + g.Cc'last') * g.Cp()
  local Pair = g.Cg (Space * String * Space * (P&quot;:&quot; + Err &quot;colon expected&quot;) * ExpectedValue)
  ObjectContent = Pair * Space * (P&quot;,&quot; * g.Cc'cont' + g.Cc'last') * g.Cp()
  local DecodeValue = ExpectedValue * g.Cp ()

  function json.decode (str, pos, nullval, ...)
    local state = {}
    state.objectmeta, state.arraymeta = optionalmetatables(...)
    local obj, retpos = pegmatch (DecodeValue, str, pos, nullval, state)
    if state.msg then
      return nil, state.pos, state.msg
    else
      return obj, retpos
    end
  end

  -- use this function only once:
  json.use_lpeg = function () return json end

  json.using_lpeg = true

  return json -- so you can get the module using json = require &quot;dkjson&quot;.use_lpeg()
end

if always_try_using_lpeg then
  pcall (json.use_lpeg)
end

return json


</pre>
</blockquote>
</div>
<div class="footer">
  <a href="./">dkolf.de</a>
  <a href="/contact">contact</a>
  (This page was generated by <a class="extlink" href="http://www.fossil-scm.org/">Fossil</a>.)
</div>
</body></html>
