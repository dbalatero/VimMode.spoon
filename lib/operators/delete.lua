local Operator = require("lib/operator")
local Delete = Operator:new()

function Delete.getKeys()
  return {
    {
      modifiers = {},
      key = 'delete'
    }
  }
end
