local Operator = dofile(vimModeScriptPath .. "lib/operator.lua")
local Delete = Operator:new{name = 'delete'}
local utf8 = dofile(vimModeScriptPath .. "vendor/luautf8.lua")

function Delete.getModifiedBuffer(_, buffer, rangeStart, rangeFinish)
  local value = buffer:getValue()
  local length = rangeFinish - rangeStart + 1

  local contents = ""
  local stringStart, stringFinish = rangeStart + 1, rangeFinish + 1

  if stringStart > 1 then
    contents = utf8.sub(value, 1, stringStart - 1)
  end

  contents = contents .. utf8.sub(value, stringFinish + 1, -1)

  return buffer:createNew(contents, rangeStart, 0)
end

function Delete.modifySelection()
  hs.eventtap.keyStroke({}, 'delete', 0)
end

function Delete.getKeys()
  return {
    {
      modifiers = {},
      key = 'delete'
    }
  }
end

return Delete
