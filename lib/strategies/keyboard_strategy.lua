local KeyboardStrategy = {}

function KeyboardStrategy:new(vim)
  local strategy = {
    vim = vim
  }

  setmetatable(strategy, self)
  self.__index = self

  return strategy
end

function KeyboardStrategy:fire()
  self:fireMovement()
  self:fireOperator()
end

function KeyboardStrategy:fireMovement()
  -- select the movement
  local motion = self.vim.commandState.motion

  for _, movement in ipairs(motion.getMovements()) do
    local modifiers = movement.modifiers

    if operator then
      modifiers = { "shift", table.unpack(modifiers) }
    end

    hs.eventtap.keyStroke(modifiers, movement.key, 0)
  end
end

function KeyboardStrategy:fireOperator()
  local operator = self.vim.commandState.operator

  if operator then
    -- fire the operator
    for _, movement in pairs(operator.getKeys()) do
      hs.eventtap.keyStroke(movement.modifiers, movement.key, 0)
    end
  end
end

return KeyboardStrategy
