local Buffer = {}

function Buffer:new(session)
  local buffer = {}

  setmetatable(buffer, self)
  self.__index = self

  buffer.session = session

  -- scratch buffer
  local _, ref = session:request('nvim_create_buf', false, true)

  buffer.ref = ref
  buffer.lineNum = nil
  buffer.columnNum = nil

  buffer:setCursorPosition(1, 0)

  return buffer
end

function Buffer:focus()
  self.session:request("nvim_win_set_buf", 0, self.ref)
  return self
end

function Buffer:setLines(lines)
  local startLine = 0
  local endLine = -1
  local strictIndexing = true

  self:withoutEvents(function()
    self.session:request(
      "nvim_buf_set_lines",
      self.ref,
      startLine,
      endLine,
      strictIndexing,
      lines
    )
  end)
end

function Buffer:withoutEvents(fn)
  self:unsubscribeFromEvents()
  fn()
  self:subscribeToEvents()
end

function Buffer:unsubscribeFromEvents()
  self.session:request("nvim_buf_detach", self.ref)
end

function Buffer:subscribeToEvents()
  self.session:request("nvim_buf_attach", self.ref, false, {})
end

function Buffer:getLines()
  startLineIndex = 0
  endLineIndex = -1
  local strictIndexing = true

  local _, lines = self.session:request(
    "nvim_buf_get_lines",
    self.ref,
    startLineIndex,
    endLineIndex,
    strictIndexing
  )

  return lines
end

function Buffer:updateLocalCursorPosition(lineNum, columnNum)
  self.lineNum = lineNum
  self.columnNum = columnNum

  return self
end

function Buffer:getCursorPosition()
  _, result = self.session:request('nvim_win_get_cursor', 0)

  local lineNum = result[1]
  local columnNum = result[2]

  return lineNum, columnNum
end

-- lineNum is 1 based
-- columnNum is 0 based
function Buffer:setCursorPosition(lineNum, columnNum)
  self:updateLocalCursorPosition(lineNum, columnNum)
  self.session:request("nvim_win_set_cursor", 0, { lineNum,  columnNum })
end

return Buffer
