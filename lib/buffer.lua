local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")

local Buffer = {}

function Buffer:new()
  local buffer = {}

  setmetatable(buffer, self)
  self.__index = self

  buffer.value = self.value or nil
  buffer.selection = nil
  buffer.lines = nil
  buffer.caretPosition = nil

  return buffer
end

function Buffer.getClass()
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
  self.lines = nil

  return self
end

function Buffer:getValue()
  return self.value
end

function Buffer:getSelectionRange()
  return self.selection
end

function Buffer:setCaretPosition(caretPosition)
  self.caretPosition = caretPosition

  return self
end

function Buffer:getCaretPosition()
  if not self.caretPosition then
    return self:getSelectionRange():positionEnd()
  else
    return self.caretPosition
  end
end

function Buffer:setSelectionRange(location, length)
  self.selection = Selection:new(location, length)
  return self
end

function Buffer:setSelectionRangeFromSelection(selection)
  self.selection = selection
  return self
end

function Buffer:nextChar()
  local nextPosition = self:getCursorPosition() + 1
  local contents = string.sub(self:getValue(), nextPosition, nextPosition)

  if contents == "" then return nil end

  return contents
end

function Buffer:getCurrentLineNumber()
  local cursorPosition = self:getCursorPosition()
  if cursorPosition == 0 then return 1 end

  local lines = self:getLines()

  local currentLine = 0
  local currentPosition = 0

  while currentPosition <= cursorPosition do
    if currentLine > #lines then break end

    currentLine = currentLine + 1

    -- add 1 for the missing \n that was on the line before splitting
    currentPosition = currentPosition + string.len(lines[currentLine])
  end

  return currentLine
end

function Buffer:getLength()
  return #(self:getValue())
end

function Buffer:getLastIndex()
  return self:getLength()
end

function Buffer:lastValueIndex()
  local length = self:getLength()

  if length == 0 then return 0 end

  return length - 1
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

function Buffer:getLines()
  if not self.lines then
    self.lines = stringUtils.split("\n", self:getValue(), true)
  end

  return self.lines
end

function Buffer:getLineCount()
  return #self:getLines()
end

function Buffer:getCurrentLine()
  local lines = self:getLines()
  return lines[self:getCurrentLineNumber()]
end

function Buffer:charAt(position)
  return string.sub(self:getValue(), position + 1, position + 1)
end

-- 1 indexed
-- clamps the position to the end of the line in case the column is
-- out of bounds.
function Buffer:getPositionForLineAndColumn(line, column)
  local lineRange = self:getRangeForLineNumber(line)
  local maxColumn = lineRange.length

  column = math.min(column, maxColumn)

  return lineRange.location + column - 1
end

function Buffer:getCurrentColumn()
  local start = self:getCurrentLineRange().location
  local currentPosition = self:getCursorPosition()

  return currentPosition - start + 1
end

function Buffer:getCurrentLineRange()
  local currentLineNumber = self:getCurrentLineNumber()

  return self:getRangeForLineNumber(currentLineNumber)
end

function Buffer:getRangeForLineNumber(lineNumber)
  local lines = self:getLines()
  local start = 0

  for i, line in ipairs(lines) do
    if i == lineNumber then break end
    start = start + string.len(line)
  end

  local length = #lines[lineNumber]

  return Selection:new(start, length)
end

function Buffer:getCursorPosition()
  return self:getSelectionRange():positionEnd()
end

function Buffer:isOnLastLine()
  return self:getCurrentLineNumber() == self:getLineCount()
end

return Buffer
