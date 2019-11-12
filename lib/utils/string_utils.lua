local Set = dofile(vimModeScriptPath .. "lib/utils/set.lua")

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

function stringUtils.isPrintableChar(char)
  return not stringUtils.isPunctuation(char) and
    not stringUtils.isWhitespace(char)
end

function stringUtils.split(delimiter, text)
  local list = {}
  local pos = 1

  if string.find("", delimiter, 1) then -- this would result in endless loops
    error("delimiter matches empty string!")
  end

  while 1 do
    local first, last = string.find(text, delimiter, pos)

    if first then -- found?
      table.insert(list, string.sub(text, pos, first - 1))
      pos = last + 1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end

  return list
end

return stringUtils
