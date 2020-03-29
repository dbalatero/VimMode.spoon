local TextField = {}

function TextField:new(axElement)
  local field = {}

  setmetatable(field, self)
  self.__index = self

  field.element = axElement

  return field
end

function TextField:getLines()
  local line = self.element:attributeValue("AXValue")
  return { line }
end

return TextField
