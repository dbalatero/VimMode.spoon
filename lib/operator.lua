local Operator = {}

function Operator:new(fields)
  local operator = fields or {}

  setmetatable(operator, self)
  self.__index = self

  return operator
end

function Operator.getKeys()
  error("Please implement getKeys()")
end

return Operator
