local Buffer = {}

function Buffer:new(contents, selection)
  local buffer = {
    contents = contents,
    selection = selection
  }

  setmetatable(buffer, self)
  self.__index = self

  return buffer
end

function Buffer:getContentsBeforeSelection()
  local contents = string.sub(self.contents, 0, self.selection:positionEnd())

  if contents == "" then return nil end

  return contents
end

function Buffer:getContentsAfterSelection()
  local contents = string.sub(self.contents, self.selection:positionEnd() + 1)

  if contents == "" then return nil end

  return contents
end

return Buffer
