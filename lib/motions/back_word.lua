local machine = dofile(vimModeScriptPath .. 'lib/utils/statemachine.lua')
local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local isPunctuation = stringUtils.isPunctuation
local isWhitespace = stringUtils.isWhitespace
local isPrintableChar = stringUtils.isPrintableChar

local BackWord = Motion:new{ name = 'back_word' }

local parser = machine.create({
  initial = 'started',
  events = {
    { name = 'seenPrintable', from = 'started', to = 'first-printable' },
    { name = 'seenPunctuation', from = 'started', to = 'first-punctuation' },
    { name = 'seenWhitespace', from = 'started', to = 'ignore-whitespace' },

    { name = 'seenPrintable', from = 'first-printable', to = 'printable-sequence' },
    { name = 'seenPunctuation', from = 'first-printable', to = 'punctuation-sequence' },
    { name = 'seenWhitespace', from = 'first-printable', to = 'ignore-whitespace' },
    { name = 'reset', from = 'first-printable', to = 'started' },

    { name = 'seenPrintable', from = 'ignore-whitespace', to = 'first-printable' },
    { name = 'seenPunctuation', from = 'ignore-whitespace', to = 'first-punctuation' },
    { name = 'seenWhitespace', from = 'ignore-whitespace', to = 'ignore-whitespace' },
    { name = 'reset', from = 'ignore-whitespace', to = 'started' },

    { name = 'seenPrintable', from = 'printable-sequence', to = 'printable-sequence' },
    { name = 'seenPunctuation', from = 'printable-sequence', to = 'finished' },
    { name = 'seenWhitespace', from = 'printable-sequence', to = 'finished' },
    { name = 'reset', from = 'printable-sequence', to = 'started' },

    { name = 'seenPrintable', from = 'first-punctuation', to = 'first-printable' },
    { name = 'seenPunctuation', from = 'first-punctuation', to = 'punctuation-sequence' },
    { name = 'seenWhitespace', from = 'first-punctuation', to = 'ignore-whitespace' },
    { name = 'reset', from = 'first-punctuation', to = 'started' },

    { name = 'seenPrintable', from = 'punctuation-sequence', to = 'finished' },
    { name = 'seenPunctuation', from = 'punctuation-sequence', to = 'punctuation-sequence' },
    { name = 'seenWhitespace', from = 'punctuation-sequence', to = 'finished' },
    { name = 'reset', from = 'punctuation-sequence', to = 'started' },

    { name = 'reset', from = 'finished', to = 'started' },
  },
  callbacks = {
    -- onstatechange = function(_, event, from, to, char)
    --   char = char or ""

    --   vimLogger.i(
    --     "Firing: " .. event .. " from: " .. from .. "to: " .. to ..
    --     " | for char: " .. char
    --   )
    -- end
  }
})

function BackWord.getRange(_, buffer)
  local start = buffer:getCaretPosition()

  local range = {
    start = start,
    finish = start,
    mode = 'exclusive',
    direction = 'characterwise'
  }

  local bufferLength = buffer:getLength()
  local contents = buffer:getValue()

  while range.start >= 0 do
    local charIndex = range.start + 1 -- lua strings are 1-indexed :(
    local char = string.sub(contents, charIndex, charIndex)

    if char == "\n" then parser:seenWhitespace(char) end
    if isPunctuation(char) then parser:seenPunctuation(char) end
    if isWhitespace(char) then parser:seenWhitespace(char) end
    if isPrintableChar(char) then parser:seenPrintable(char) end

    if parser.current == "finished" then
      range.start = range.start + 1
      break
    end

    if range.start == 0 then
      break
    else
      range.start = range.start - 1
    end
  end

  parser:reset()

  return range
end

function BackWord.getMovements()
  return {
    {
      modifiers = { ' alt' },
      key = 'left',
      selection = true
    }
  }
end

return BackWord
