local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local Right = Motion:new{ name = 'right' }

function Right.getRange(_, buffer)
  local start = buffer:getCaretPosition()

  return {
    start = start,
    finish = start + 1,
    mode = 'exclusive',
    direction = 'characterwise'
  }
end

function Right.getMovements()
  return {
    {
      modifiers = {},
      key = 'right'
    }
  }
end

return Right
