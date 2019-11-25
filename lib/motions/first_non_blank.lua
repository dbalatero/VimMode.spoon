local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local FirstNonBlank = Motion:new{ name = 'first_non_blank' }

function FirstNonBlank.getRange(_, buffer)
  local start = buffer:getCaretPosition()
  local bufferLength = buffer:getLength()
  local contents = buffer:getValue()

  local range = {
    start = start,
    mode = 'exclusive',
    direction = 'characterwise'
  }

  range.finish = start

  while range.finish < bufferLength do
    local charIndex = range.finish + 1 -- lua strings are 1-indexed :(
    local char = string.sub(contents, charIndex, charIndex)

    if char == "\n" then break end
    if not stringUtils.isWhitespace(char) then break end

    range.finish = range.finish + 1
  end

  return range
end

-- TODO not possible without context
function FirstNonBlank.getMovements()
  return {}
end

return FirstNonBlank
