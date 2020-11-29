local Motion = dofile(vimModeScriptPath .. "lib/motion.lua")

local Noop = Motion:new{ name = 'noop' }

function Noop.getRange(_, _)
  return nil
end

function Noop.getMovements()
  return nil
end

return Noop
