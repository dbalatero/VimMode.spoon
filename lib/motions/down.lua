local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local Down = Motion:new{ name = 'down' }

function Down.getRange(_, buffer)
  if buffer:isOnLastLine() then return nil end

  local lineNum = buffer:getCurrentLineNumber()
  local column = buffer:getCurrentColumn()
  local finish = buffer:getPositionForLineAndColumn(lineNum + 1, column)

  return {
    start = buffer:getCaretPosition(),
    finish = finish,
    mode = 'exclusive',
    direction = 'linewise'
  }
end

function Down.getMovements()
  return {
    {
      modifiers = {},
      key = 'down',
      selection = true
    }
  }
end

return Down
