local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local LastLine = Motion:new{ name = 'right' }

function LastLine.getRange(_, buffer)
  local start = buffer:getSelectionRange():positionEnd()

  return {
    start = start,
    finish = start + 1,
    mode = 'exclusive',
    direction = 'linewise'
  }
end

function LastLine.getMovements()
  return {
    {
      modifiers = {'cmd'},
      key = 'down'
    },
    {
      modifiers = {'cmd'},
      key = 'left'
    }
  }
end

return LastLine
