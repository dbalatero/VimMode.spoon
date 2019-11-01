local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local Set = dofile(vimModeScriptPath .. "lib/utils/set.lua")

local Word = Motion:new{ name = 'word' }

-- word motion, exclusive
--
-- from :help motions.txt
--
-- <S-Right>	or					*<S-Right>* *w*
-- w			[count] words forward.  |exclusive| motion.
--
--

local punctuation = Set{
  "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "=", "+", "[", "{",
  "}", "]", "|", " '", "\"", ":", ";", ",", ".", "/", "?", "`"
}

function isPunctuation(char)
  return not not punctuation[char]
end

-- TODO handle more edge cases for :help word
function Word:getRange(buffer)
  local start = buffer.selection:positionEnd()

  local range = {
    start = start,
    mode = 'exclusive',
    direction = 'characterwise'
  }

  range.finish = start

  local seenWhitespace = false
  local bufferLength = buffer:getLength()

  while range.finish < bufferLength do
    local charIndex = range.finish + 1 -- lua strings are 1-indexed :(
    local char = string.sub(buffer.contents, charIndex, charIndex)

    if seenWhitespace and char ~= " " then break end
    if isPunctuation(char) then break end

    if not seenWhitespace and char == " " then
      seenWhitespace = true
    end

    range.finish = range.finish + 1
  end

  if range.finish == bufferLength then
    -- don't go off the right edge of the buffer
    range.finish = range.finish - 1
    range.mode = 'inclusive'
  end

  return range
end

function Word.getMovements()
  return {
    {
      modifiers = { 'alt' },
      key = 'right'
    }
  }
end

return Word
