local Buffer = dofile(vimModeScriptPath .. "lib/buffer.lua")
local Operator = dofile(vimModeScriptPath .. "lib/operator.lua")
local Selection = dofile(vimModeScriptPath .. "lib/selection.lua")

local Delete = Operator:new{name = 'delete'}

function Delete.getModifiedBuffer(buffer, rangeStart, rangeFinish)
  local stringStart, stringFinish = rangeStart + 1, rangeFinish + 1
  local contents = ""

  if stringStart > 1 then
    contents = string.sub(buffer.contents, 1, stringStart - 1)
  end

  contents = contents .. string.sub(buffer.contents, stringFinish + 1, -1)

  local selection = Selection:new(rangeStart, 0)

  return Buffer:new(contents, selection)
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
