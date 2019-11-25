local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local LineBeginning = Motion:new{ name = 'line_beginning' }

function LineBeginning.getRange(_, buffer)
  local lineRange = buffer:getCurrentLineRange()

  return {
    start = lineRange.location,
    finish = buffer:getCaretPosition(),
    mode = 'exclusive',
    direction = 'characterwise'
  }
end

function LineBeginning.getMovements()
  return {
    {
      modifiers = { 'cmd' },
      key = 'left'
    }
  }
end

return LineBeginning
