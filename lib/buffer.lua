local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")
local Buffer = {}

function Buffer:new()
  local buffer = {}

  setmetatable(buffer, self)
  self.__index = self

  buffer.value = self.value or nil
  buffer.selection = nil

  return buffer
end

function Buffer:getClass()
  return Buffer
end

function Buffer:createNew(value, rangeLocation, rangeLength)
  local buffer = self.getClass():new()
  buffer:setValue(value)
  buffer:setSelectionRange(rangeLocation or 0, rangeLength or 0)

  return buffer
end

function Buffer:setValue(value)
  self.value = value
end

function Buffer:getValue()
  return self.value
end

function Buffer:getSelectionRange()
  return self.selection
end

function Buffer:setSelectionRange(location, length)
  self.selection = Selection:new(location, length)
end

function Buffer:nextChar()
  local nextPosition = self.selection:positionEnd() + 1
  local contents = string.sub(self:getValue(), nextPosition, nextPosition)

  if contents == "" then return nil end

  return contents
end

function Buffer:getLength()
  return #(self:getValue())
end

function Buffer:getContentsBeforeSelection()
  local contents = string.sub(self:getValue(), 0, self.selection:positionEnd())

  if contents == "" then return nil end

  return contents
end

function Buffer:getContentsAfterSelection()
  local contents = string.sub(self:getValue(), self.selection:positionEnd() + 1)

  if contents == "" then return nil end

  return contents
end

return Buffer
