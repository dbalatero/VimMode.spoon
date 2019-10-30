local Motion = require("lib/motion")
local Word = Motion:new()

function Word:getMovements(buffer)
  local nextChar = buffer:nextChar()

  if not nextChar then return nil end
  if nextChar == "\n" then return nil end

  return {
    {
      modifiers = { 'alt' },
      character = 'right'
    }
  }
end

return Word
