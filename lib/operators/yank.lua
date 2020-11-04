local Operator = dofile(vimModeScriptPath .. "lib/operator.lua")
local Yank = Operator:new{name = 'yank'}
local utf8 = dofile(vimModeScriptPath .. "vendor/luautf8.lua")

function Yank:modifySelection(buffer, rangeStart, rangeFinish)
  if hs then
    local stringStart, stringFinish = rangeStart + 1, rangeFinish + 1
    local toCopy = utf8.sub(buffer:getValue(), stringStart, stringFinish)

    hs.pasteboard.setContents(toCopy)
  end
end

function Yank.getModifiedBuffer(_, buffer, rangeStart, rangeFinish)
  -- we just want to set it in the pasteboard
  if hs then
    local stringStart, stringFinish = rangeStart + 1, rangeFinish + 1
    local toCopy = utf8.sub(buffer:getValue(), stringStart, stringFinish)

    hs.pasteboard.setContents(toCopy)
  end

  -- we actually don't need to modify the buffer
  return buffer
end

function Yank.getKeys()
  return {
    {
      modifiers = {'cmd'},
      key = 'c'
    }
  }
end

return Yank
