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
      key = 'down',
      selection = true
    },
    {
      modifiers = {'cmd'},
      key = 'right',
      selection = true
    },
    {
      modifiers = {'cmd'},
      key = 'left',
      selection = true
    }
  }
end

return LastLine
