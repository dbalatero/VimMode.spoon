local Buffer = {}

function Buffer:new(session)
  local buffer = {}

  setmetatable(buffer, self)
  self.__index = self

  buffer.session = session

  -- scratch buffer
  local _, ref = buffer.session:request('nvim_create_buf', false, true)
  buffer.ref = ref

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

  self.session:request(
    "nvim_buf_set_lines",
    scratchBuffer,
    startLine,
    endLine,
    strictIndexing,
    lines
  )
end

function Buffer:getRef()
  return self.ref
end

-- lineNum is 1 based
-- columnNum is 0 based
function Buffer:setCursorPosition(lineNum, columnNum)
  self.session:request("nvim_win_set_cursor", 0, { lineNum,  columnNum })
end

return Buffer
