local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local Left = Motion:new{ name = 'left' }

function Left.getRange(_, buffer)
  local start = buffer.selection:positionEnd()

  return {
    start = start - 1,
    finish = start,
    mode = 'exclusive',
    direction = 'characterwise'
  }
end

function Left.getMovements()
  return {
    {
      modifiers = {},
      key = 'left'
    }
  }
end

return Left
