local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local EntireLine = Motion:new{ name = 'entire_line' }

function EntireLine.getRange(_, buffer)
  local lineRange = buffer:getCurrentLineRange()
  local start = lineRange.location

  if buffer:isOnLastLine() and buffer:charAt(start - 1) == "\n" then
    -- delete upwards from the last line and remove the trailing \n
    start = start - 1
  end

  return {
    start = math.max(start, 0),
    finish = lineRange:positionEnd(),
    mode = 'exclusive',
    direction = 'linewise'
  }
end

function EntireLine.getMovements()
  return {
    {
      modifiers = { 'cmd' },
      key = 'left'
    },
    {
      modifiers = { 'cmd' },
      key = 'right',
      selection = true
    }
  }
end

return EntireLine
