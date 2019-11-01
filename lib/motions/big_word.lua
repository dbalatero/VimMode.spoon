local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local BigWord = Motion:new{ name = 'big_word' }

local isPunctuation = stringUtils.isPunctuation
local isWhitespace = stringUtils.isWhitespace
local isPrintableChar = stringUtils.isPrintableChar

-- <C-Right>	or					*<C-Right>* *W*
-- W			[count] WORDS forward.  |exclusive| motion.
--
--
-- bigword

-- In the POSIX locale, vi shall recognize four kinds of bigwords:
-- 1. A maximal sequence of non- <blank> characters preceded and followed by
-- <blank> characters or the beginning or end of a line or the edit buffer

-- 2. One or more sequential blank lines

-- 3. The first character in the edit buffer

-- 4. The last non- <newline> in the edit buffer

function BigWord.getRange(_, buffer)
  local start = buffer.selection:positionEnd()

  local range = {
    start = start,
    mode = 'exclusive',
    direction = 'characterwise'
  }

  local seenWhitespace = false
  local bufferLength = buffer:getLength()

  range.finish = start

  while range.finish < bufferLength do
    local charIndex = range.finish + 1 -- lua strings are 1-indexed :(
    local char = string.sub(buffer.contents, charIndex, charIndex)

    if seenWhitespace and not isWhitespace(char) then break end
    if not seenWhitespace and isWhitespace(char) then seenWhitespace = true end

    range.finish = range.finish + 1
  end

  if range.finish == bufferLength then
    -- don't go off the right edge of the buffer
    range.mode = 'inclusive'
  end

  return range
end

function BigWord.getMovements()
  return {
    {
      modifiers = { 'alt' },
      key = 'right'
    }
  }
end

return BigWord
