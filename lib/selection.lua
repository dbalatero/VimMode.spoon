local Selection = {}

function Selection:new(position, length)
  local selection = {
    position = position,
    length = length
  }

  setmetatable(selection, self)
  self.__index = self

  return selection
end

function Selection:isSelected()
  return self.length > 0
end

return Selection
