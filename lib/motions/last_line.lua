local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local LastLine = Motion:new{ name = 'last_line' }

function LastLine.getRange(_, buffer)
  local start = buffer:getCurrentLineRange().position

  return {
    start = start,
    finish = buffer:getLastIndex(),
    mode = 'exclusive',
    direction = 'linewise'
  }
end

function LastLine.getMovements()
  return {
    {
      modifiers = {'cmd'},
      key = 'left' -- reset to beginning of line
    },
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
