local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local LineEnd = Motion:new{ name = 'line_end' }

function LineEnd.getRange(_, buffer)
  local lineRange = buffer:getCurrentLineRange()
  local line = buffer:getCurrentLine()
  local finish = lineRange:positionEnd()

  if stringUtils.lastChar(line) == "\n" then
    finish = finish - 1
  end

  local range = {
    start = buffer:getCaretPosition(),
    finish = finish,
    -- the vim manual says this is an inclusive motion, but I swear
    -- it *behaves* like an exclusive motion, so I'm keeping it this way
    -- for now as it feels more correct. I might be missing some key things
    -- here though.
    mode = 'exclusive',
    direction = 'characterwise'
  }

  return range
end

function LineEnd.getMovements()
  return {
    {
      modifiers = { 'ctrl' },
      key = 'e',
      selection = true
    }
  }
end

return LineEnd
