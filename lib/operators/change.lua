local Delete = dofile(vimModeScriptPath .. "lib/operators/delete.lua")

local Change = Delete:new{ name = 'change' }

function Change.getModeForTransition()
  return "insert"
end

return Change
