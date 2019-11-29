local Strategy = dofile(vimModeScriptPath .. "lib/strategy.lua")

local KeyboardStrategy = Strategy:new()

function KeyboardStrategy:new(vim)
  local strategy = {
    vim = vim
  }

  setmetatable(strategy, self)
  self.__index = self

  return strategy
end

function KeyboardStrategy:fire()
  local result = self:fireMovement()

  -- If the movement is canceled or impossible with the KB strategy, don't do
  -- the operator.
  if result then self:fireOperator() end
end

function KeyboardStrategy:fireMovement()
  -- select the movement
  local motion = self.vim.commandState.motion
  local operator = self.vim.commandState.operator
  local visualMode = self.vim:isMode('visual')

  if not motion then return true end

  local movements = motion.getMovements()
  if not movements then return false end

  for _, movement in ipairs(movements) do
    local modifiers = movement.modifiers

    local isSelection = visualMode or (operator and movement.selection)

    if isSelection then
      modifiers = { "shift", table.unpack(modifiers) }
    end

    hs.eventtap.keyStroke(modifiers, movement.key, 0)
  end

  return true
end

function KeyboardStrategy:fireOperator()
  local operator = self.vim.commandState.operator

  if operator then
    -- fire the operator
    for _, movement in pairs(operator:getKeys()) do
      hs.eventtap.keyStroke(movement.modifiers, movement.key, 0)
    end
  end
end

return KeyboardStrategy
