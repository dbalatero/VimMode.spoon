local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local ForwardSearch = Motion:new{ name = 'forward_search' }

function ForwardSearch:getRange(buffer)
  local start = buffer:getCaretPosition()
  local stringStart = start + 1
  local searchChar = self:getExtraChar()

  local nextOccurringIndex = stringUtils.findNextIndex(
    buffer:getValue(),
    searchChar,
    stringStart + 1 -- start from the next char
  )

  if not nextOccurringIndex then return nil end

  return {
    start = start,
    finish = nextOccurringIndex - 1,
    mode = 'exclusive',
    direction = 'characterwise'
  }
end

function ForwardSearch.getMovements()
  return nil
end

return ForwardSearch
