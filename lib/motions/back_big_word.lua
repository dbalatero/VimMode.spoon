local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")
local isWhitespace = stringUtils.isWhitespace
local utf8 = dofile(vimModeScriptPath .. "vendor/luautf8.lua")
local BackBigWord = Motion:new{ name = 'back_big_word' }

function BackBigWord.getRange(_, buffer)
  local start = buffer:getCaretPosition()

  local range = {
    start = start,
    finish = start,
    mode = 'exclusive',
    direction = 'characterwise'
  }

  local contents = buffer:getValue()

  range.finish = start

  while range.start >= 0 do
    local charIndex = range.start
    local char = utf8.sub(contents, charIndex, charIndex)

    if isWhitespace(char) then break end
    if range.start == 0 then break end

    range.start = range.start - 1
  end

  return range
end

function BackBigWord.getMovements()
  return {
    {
      modifiers = { 'alt' },
      key = 'left',
      selection = true
    }
  }
end

return BackBigWord
