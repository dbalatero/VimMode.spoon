local Operator = dofile(vimModeScriptPath .. "lib/operator.lua")
local Delete = Operator:new()

function Delete.getKeys()
  return {
    {
      modifiers = {},
      key = 'delete'
    }
  }
end

return Delete
