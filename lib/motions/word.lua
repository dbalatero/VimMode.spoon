local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local Word = Motion:new{ name = 'word' }

local isPunctuation = stringUtils.isPunctuation
local isWhitespace = stringUtils.isWhitespace
local isPrintableChar = stringUtils.isPrintableChar

-- word motion, exclusive
--
-- from :help motions.txt
--
-- <S-Right>	or					*<S-Right>* *w*
-- w			[count] words forward.  |exclusive| motion.
--
--
-- https://pubs.opengroup.org/onlinepubs/9699919799/utilities/vi.html
--

-- TODO handle more edge cases for :help word
function Word.getRange(_, buffer)
  local start = buffer.selection:positionEnd()

  local range = {
    start = start,
    mode = 'exclusive',
    direction = 'characterwise'
  }

  range.finish = start

  local seenWhitespace = false
  local bufferLength = buffer:getLength()

  local startingChar = string.sub(
    buffer.contents,
    range.finish + 1,
    range.finish + 1
  )

  local startedOnPunctuation = isPunctuation(startingChar)

  while range.finish < bufferLength do
    local charIndex = range.finish + 1 -- lua strings are 1-indexed :(
    local char = string.sub(buffer.contents, charIndex, charIndex)

    if char == "\n" then
      if start == range.finish then range.finish = range.finish + 1 end

      break
    end

    if startedOnPunctuation then
      if isPrintableChar(char) then break end
    else
      if seenWhitespace and not isWhitespace(char) then break end
      if isPunctuation(char) then break end

      if not seenWhitespace and isWhitespace(char) then
        seenWhitespace = true
      end
    end

    range.finish = range.finish + 1
  end

  if range.finish == bufferLength then
    -- don't go off the right edge of the buffer
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
