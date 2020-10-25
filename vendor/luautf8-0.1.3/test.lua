local utf8 = require 'lua-utf8'
local unpack = unpack or table.unpack
local E = utf8.escape

local function get_codes(s)
   return table.concat({utf8.byte(s, 1, -1)}, ' ')
end

local t = { 20985, 20984, 26364, 25171, 23567, 24618, 20861 } 
-- test escape & len
assert(get_codes(E"%123%xabc%x{ABC}%d%u{456}") == '123 2748 2748 100 456')

local s = E('%'..table.concat(t, '%'))
assert(utf8.len(s) == 7)
assert(get_codes(s) == table.concat(t, ' '))


-- test offset

local function assert_error(f, msg)
   local s,e = pcall(f)
   return assert(not s and e:match(msg))
end

assert(utf8.offset("中国", 0) == 1)
assert(utf8.offset("中国", 0,1) == 1)
assert(utf8.offset("中国", 0,2) == 1)
assert(utf8.offset("中国", 0,3) == 1)
assert(utf8.offset("中国", 0,4) == 4)
assert(utf8.offset("中国", 0,5) == 4)
assert(utf8.offset("中国", 1) == 1)
assert_error(function() utf8.offset("中国", 1,2) end,
             "initial position is a continuation byte")
assert(utf8.offset("中国", 2) == 4)
assert(utf8.offset("中国", 3) == 7)
assert(utf8.offset("中国", 4) == nil)
assert(utf8.offset("中国", -1,-3) == 1)
assert(utf8.offset("中国", -1,1) == nil)

-- test byte
local function assert_table_equal(t1, t2, i, j)
   i = i or 1
   j = j or #t2
   local len = j-i+1
   assert(#t1 == len)
   for cur = 1, len do
      assert(t1[cur] == t2[cur+i-1])
   end
end
assert_table_equal({utf8.byte(s, 2)}, t, 2, 2)
assert_table_equal({utf8.byte(s, 1, -1)}, t)
assert_table_equal({utf8.byte(s, -100)}, {})
assert_table_equal({utf8.byte(s, -100, -200)}, {})
assert_table_equal({utf8.byte(s, -200, -100)}, {})
assert_table_equal({utf8.byte(s, 100)}, {})
assert_table_equal({utf8.byte(s, 100, 200)}, {})
assert_table_equal({utf8.byte(s, 200, 100)}, {})


-- test char
assert(s == utf8.char(unpack(t)))

-- test range
for i = 1, #t do
    assert(utf8.byte(s, i) == t[i])
end

-- test sub
assert(get_codes(utf8.sub(s, 2, -2)) == table.concat(t, ' ', 2, #t-1))
assert(get_codes(utf8.sub(s, -100)) == table.concat(t, ' '))
assert(get_codes(utf8.sub(s, -100, -200)) == "")
assert(get_codes(utf8.sub(s, -100, -100)) == "")
assert(get_codes(utf8.sub(s, -100, 0)) == "")
assert(get_codes(utf8.sub(s, -200, -100)) == "")
assert(get_codes(utf8.sub(s, 100, 200)) == "")
assert(get_codes(utf8.sub(s, 200, 100)) == "")


-- test insert/remove
assert(utf8.insert("abcdef", "...") == "abcdef...")
assert(utf8.insert("abcdef", 0, "...") == "abcdef...")
assert(utf8.insert("abcdef", 1, "...") == "...abcdef")
assert(utf8.insert("abcdef", 6, "...") == "abcde...f")
assert(utf8.insert("abcdef", 7, "...") == "abcdef...")
assert(utf8.insert("abcdef", 3, "...") == "ab...cdef")
assert(utf8.insert("abcdef", -3, "...") == "abc...def")
assert(utf8.remove("abcdef", 3, 3) == "abdef")
assert(utf8.remove("abcdef", 3, 4) == "abef")
assert(utf8.remove("abcdef", 4, 3) == "abcdef")
assert(utf8.remove("abcdef", -3, -3) == "abcef")
assert(utf8.remove("abcdef", 100) == "abcdef")
assert(utf8.remove("abcdef", -100) == "")
assert(utf8.remove("abcdef", -100, 0) == "abcdef")
assert(utf8.remove("abcdef", -100, -200) == "abcdef")
assert(utf8.remove("abcdef", -200, -100) == "abcdef")
assert(utf8.remove("abcdef", 100, 200) == "abcdef")
assert(utf8.remove("abcdef", 200, 100) == "abcdef")

do
    local s = E"a%255bc"
    assert(utf8.len(s, 4))
    assert(string.len(s, 6))
    assert(utf8.charpos(s) == 1)
    assert(utf8.charpos(s, 0) == 1)
    assert(utf8.charpos(s, 1) == 1)
    assert(utf8.charpos(s, 2) == 2)
    assert(utf8.charpos(s, 3) == 4)
    assert(utf8.charpos(s, 4) == 5)
    assert(utf8.charpos(s, 5) == nil)
    assert(utf8.charpos(s, 6) == nil)
    assert(utf8.charpos(s, -1) == 5)
    assert(utf8.charpos(s, -2) == 4)
    assert(utf8.charpos(s, -3) == 2)
    assert(utf8.charpos(s, -4) == 1)
    assert(utf8.charpos(s, -5) == nil)
    assert(utf8.charpos(s, -6) == nil)
    assert(utf8.charpos(s, 3, -1) == 2)
    assert(utf8.charpos(s, 3, 0) == 2)
    assert(utf8.charpos(s, 3, 1) == 4)
    assert(utf8.charpos(s, 6, -3) == 2)
    assert(utf8.charpos(s, 6, -4) == 1)
    assert(utf8.charpos(s, 6, -5) == nil)
end

local idx = 1
for pos, code in utf8.next, s do
   assert(t[idx] == code)
   idx = idx + 1
end

assert(utf8.ncasecmp("abc", "AbC") == 0)
assert(utf8.ncasecmp("abc", "AbE") == -1)
assert(utf8.ncasecmp("abe", "AbC") == 1)
assert(utf8.ncasecmp("abc", "abcdef") == -1)
assert(utf8.ncasecmp("abcdef", "abc") == 1)
assert(utf8.ncasecmp("abZdef", "abcZef") == 1)

assert(utf8.gsub("x^[]+$", "%p", "%%%0") == "x%^%[%]%+%$")


-- test invalid

-- 1110-1010 10-000000 0110-0001
do
   local s = "\234\128\97"
   assert(utf8.len(s, nil, nil, true) == 2)
   assert_table_equal({utf8.len(s)}, {nil, 1}, 1, 2)

   -- 1111-0000 10-000000 10-000000 ...
   s = "\240\128\128\128\128"
   assert_table_equal({utf8.len(s)}, {nil, 1}, 1, 2)
end


-- test compose
local function assert_fail(f, patt)
   local ok, msg = pcall(f)
   assert(not ok)
   assert(msg:match(patt), msg)
end
do
   local s = "नमस्ते"
   assert(utf8.len(s) == 6)
   assert(utf8.reverse(s) == "तेस्मन")
   assert(utf8.reverse(s.." ", true) == " ेत्समन")
   assert(utf8.match(s..'\2', "%g+") == s)
   assert_fail(function() utf8.reverse(E"%xD800") end, "invalid UTF%-8 code")
end

-- test codepoint
for i = 1, 1000 do
   assert(utf8.codepoint(E("%"..i)) == i)
end
assert_fail(function() utf8.codepoint(E"%xD800") end, "invalid UTF%-8 code")

-- test escape
assert_fail(function() E"%{1a1}" end, "invalid escape 'a'")


-- test codes
local result = { [1]  = 20985; [4]  = 20984; [7]  = 26364;
   [10] = 25171; [13] = 23567; [16] = 24618; [19] = 20861; }
for p, c in utf8.codes(s) do
   assert(result[p] == c)
end
for p, c in utf8.codes(s, true) do
   assert(result[p] == c)
end
assert_fail(function()
   for p, c in utf8.codes(E"%xD800") do
      assert(result[p] == c)
   end
end, "invalid UTF%-8 code")


-- test width
assert(utf8.width('नमस्ते\2') == 5)
assert(utf8.width(E'%xA1') == 1)
assert(utf8.width(E'%xA1', 2) == 2)
assert(utf8.width(E'%x61C') == 0)
assert(utf8.width "A" == 1)
assert(utf8.width "Ａ" == 2)
assert(utf8.width(97) == 1)
assert(utf8.width(65313) == 2)
assert_fail(function() utf8.width(true) end, "number/string expected, got boolean")
assert(utf8.widthindex("abcdef", 3) == 3)
assert(utf8.widthindex("abcdef", 7) == 7)

-- test patterns
assert_fail(function() utf8.gsub("a", ".", function() return {} end) end,
   "invalid replacement value %(a table%)")
assert_fail(function() utf8.gsub("a", ".", "%z") end,
   "invalid use of '%%' in replacement string")
assert(utf8.find("abcabc", "ab", -10) == 1)

-- test charpattern
do
  local subj, n = "school=школа", 0
  for c in string.gmatch(subj, utf8.charpattern) do n = n+1 end
  assert(n == utf8.len(subj))
end


print "OK"

-- cc: run='lua -- $input'

