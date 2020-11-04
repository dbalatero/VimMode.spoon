local Set = dofile(vimModeScriptPath .. "lib/utils/set.lua")
local utf8 = dofile(vimModeScriptPath .. "vendor/luautf8.lua")

local stringUtils = {}

local punctuation = Set{
  "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "+", "[", "{",
  "}", "]", "|", " '", "\"", ":", ";", ",", ".", "/", "?", "`"
}

function stringUtils.isPunctuation(char)
  return not not punctuation[char]
end

function stringUtils.isWhitespace(char)
  return char == " "
end

function stringUtils.isNonAlphanumeric(str)
  return not not str:match("%W")
end

function stringUtils.isPrintableChar(char)
  return not stringUtils.isPunctuation(char) and
    not stringUtils.isWhitespace(char)
end

function stringUtils.toChars(str)
  local chars = {}
  local current = 1

  while current <= #str do
    table.insert(chars, utf8.sub(str, current, current))
    current = current + 1
  end

  return chars
end

function stringUtils.findPrevIndex(str, searchChar, startPos)
  local length = utf8.len(str)
  local position = math.min(startPos or length, length)

  while position > 0 do
    if utf8.sub(str, position, position) == searchChar then
      return position
    end

    position = position - 1
  end

  return nil
end

function stringUtils.findNextIndex(str, searchChar, startPos)
  local length = utf8.len(str)
  local position = math.max(startPos or 1, 1)

  while position <= length do
    if utf8.sub(str, position, position) == searchChar then
      return position
    end

    position = position + 1
  end

  return nil
end

function stringUtils.split(delimiter, text, includeDelimiter)
  local includeDelimiter = includeDelimiter or false
  local list = {}
  local pos = 1

  if utf8.find("", delimiter, 1) then -- this would result in endless loops
    error("delimiter matches empty string!")
  end

  while 1 do
    local first, last = utf8.find(text, delimiter, pos)

    if first then -- found?
      local part = utf8.sub(text, pos, first - 1)
      if includeDelimiter then part = part .. delimiter end

      table.insert(list, part)
      pos = last + 1
    else
      table.insert(list, utf8.sub(text, pos))
      break
    end
  end

  return list
end

function stringUtils.lastChar(text)
  return utf8.sub(text, #text, #text)
end

return stringUtils
