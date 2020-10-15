local Selection = {}

function Selection:new(location, length)
  local selection = {
    location = location,
    length = length
  }

  setmetatable(selection, self)
  self.__index = self

  return selection
end

function Selection.fromRange(axRange)
  -- Older versions of axuielement return `loc/len`
  local location = axRange.location or axRange.loc
  local length = axRange.length or axRange.len

  return Selection:new(location, length)
end

function Selection:isSelected()
  return self.length > 0
end

function Selection:positionEnd()
  return self.location + self.length
end

function Selection:getCharRange()
  return {
    start = self.location,
    finish = self:positionEnd()
  }
end

return Selection
