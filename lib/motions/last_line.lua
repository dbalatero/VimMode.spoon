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
    -- end of line
    {
      modifiers = {'ctrl'},
      key = 'e',
      selection = true
    },
    -- reset it to beginning of line
    {
      modifiers = {'ctrl'},
      key = 'a',
      selection = true
    }
  }
end

return LastLine
