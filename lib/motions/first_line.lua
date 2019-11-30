local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local FirstLine = Motion:new{ name = 'first_line' }

function FirstLine.getRange(_, buffer)
  local finish = buffer:getCurrentLineRange():positionEnd()

  return {
    start = 0,
    finish = finish,
    mode = 'exclusive',
    direction = 'linewise'
  }
end

function FirstLine.getMovements()
  return {
    {
      modifiers = {'cmd'},
      key = 'up',
      selection = true
    },
    {
      modifiers = {'ctrl'},
      key = 'a',
      selection = true
    }
  }
end

return FirstLine
