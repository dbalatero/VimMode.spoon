local Motion = require("lib/motion")
local Word = Motion:new()

function Word:getMovements()
  return {
    {
      modifiers = { 'alt' },
      character = 'right'
    }
  }
end

return Word
