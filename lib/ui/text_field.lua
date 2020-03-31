local ax = require("hs._asm.axuielement")

local TextField = {}

function TextField.fromCurrentElement()
  local systemElement = ax.systemWideElement()
  local currentElement = systemElement:attributeValue("AXFocusedUIElement")

  return TextField:new(currentElement)
end

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

function TextField:getLineNumber()
  return 1
end

function TextField:getColumnNumber()
  local range = self.element:attributeValue("AXSelectedTextRange")
  return range.loc
end

function TextField:setCursorPosition(_lineNum, columnNum)
  self.element:setAttributeValue("AXSelectedTextRange", {
    location = columnNum,
    length = 0
  })
end

function TextField:setLine(_lineIndex, line)
  vimLogger.i("setting line to " .. line)
  self.element:setValue(line)
end

function TextField:setLines(startLineIndex, lines)
  -- we only should have one line
  self:setLine(0, lines[1])
end

return TextField
