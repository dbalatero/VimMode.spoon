local utils = VimMode.requireFile('lib/utils')

local function motionModifiers(vim, modifiers)
  local newModifiers = utils.deepcopy(modifiers or {})

  if vim:isSelection() then
    table.insert(newModifiers, #newModifiers + 1, 'shift')
  end

  return newModifiers
end

local function buildMotion(motionDefinition)
  local definition = motionDefinition()

  return function(vim)
    return function()
      definition.fn(vim)
      vim.commandState.motionDirection = definition.direction

      if definition.complete then
        vim:runOperator()

        if not vim:isVisualMode() then vim:resetState() end
      end
    end
  end
end

local function defineMotion(key, modifiers, complete, direction)
  if complete == nil then complete = true end
  modifiers = modifiers or {}
  direction = direction or 'forward'

  return buildMotion(function()
    return {
      complete = complete,
      direction = direction,
      fn = function(vim)
        hs.eventtap.keyStroke(motionModifiers(vim, modifiers), key, 0)
      end
    }
  end)
end

return {
  backWord = defineMotion('left', {'alt'}, true, 'back'),
  word = defineMotion('right', {'alt'}),
  beginningOfLine = defineMotion('left', {'command'}),
  endOfLine = defineMotion('right', {'command'}),
  endOfText = defineMotion('down', {'command'}),

  left = defineMotion('left'),
  right = defineMotion('right'),
  up = defineMotion('up'),
  down = defineMotion('down')
}
