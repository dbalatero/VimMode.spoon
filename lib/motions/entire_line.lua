local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local EntireLine = Motion:new{ name = 'entire_line' }

function EntireLine.getRange(_, buffer)
  local lineRange = buffer:getCurrentLineRange()

  return {
    start = lineRange.location,
    finish = lineRange:positionEnd(),
    mode = 'inclusive',
    direction = 'characterwise'
  }
end

function EntireLine.getMovements()
  -- TODO
  return {}
end

return EntireLine
