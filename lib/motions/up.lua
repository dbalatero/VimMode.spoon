local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local Up = Motion:new{ name = 'up' }

function Up.getRange(_, buffer)
  local lineNum = buffer:getCurrentLineNumber()
  if lineNum == 1 then return nil end

  local column = buffer:getCurrentColumn()
  local start = buffer:getPositionForLineAndColumn(lineNum - 1, column)

  return {
    start = start,
    finish = buffer:getCaretPosition(),
    mode = 'exclusive',
    direction = 'linewise'
  }
end

function Up.getMovements()
  return {
    {
      modifiers = {},
      key = 'up',
      selection = true
    }
  }
end

return Up
