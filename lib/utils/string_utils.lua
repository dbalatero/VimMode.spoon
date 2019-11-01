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

return stringUtils
