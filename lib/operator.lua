local Operator = {}

function Operator:new(fields)
  local operator = fields or {}

  operator.extraChar = nil

  setmetatable(operator, self)
  self.__index = self

  return operator
end

function Operator.getModeForTransition()
  return "normal"
end

function Operator:setExtraChar(char)
  self.extraChar = char

  return self
end

function Operator:getExtraChar()
  return self.extraChar
end

function Operator.getKeys()
  error("Please implement getKeys()")
end

return Operator
