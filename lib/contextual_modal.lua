local Registry = dofile(vimModeScriptPath .. "lib/contextual_modal/registry.lua")
local stringUtils = dofile(vimModeScriptPath .. "lib/utils/string_utils.lua")
local tableUtils = dofile(vimModeScriptPath .. "lib/utils/table.lua")
local utf8 = dofile(vimModeScriptPath .. "vendor/luautf8.lua")

local ContextualModal = {}

local function mapToList(map)
  local list = {}

  for key, value in pairs(map) do
    table.insert(list, key)
  end

  return list
end

-- Wraps a modal and provides different key layers depending on which
-- context you happen to be in.
--
-- Swapping between multiple modals is too slow, so having a single modal
-- that has context layers helps with key latency and lets us buffer keystrokes
-- correctly.
--
-- To bind keys to a new context layer, use the withContext helper to change
-- the binding context:
--
-- local modal = ContextualModal:new()
--
-- modal
--   :withContext("foo")
--   :bind({}, 'e', function() print("foo e") end)
--
-- modal
--   :withContext("bar")
--   :bind({}, 'e', function() print("bar e") end)
--
-- modal:enterContext("foo") -- pressing 'e' prints 'foo e'
-- modal:enterContext("bar") -- pressing 'e' prints 'bar e'
function ContextualModal:new()
  local registry = Registry:new()
  local wrapper = {
    activeContext = nil,
    bindingContext = nil,
    bindings = {},
    entered = false,
    modal = hs.hotkey.modal.new(),
    onBeforePress = function() end,
    registry = registry,
  }

  setmetatable(wrapper, self)
  self.__index = self

  return wrapper
end

function ContextualModal:handlePress(mods, key, eventType)
  return function()
    local handler = self.registry:getHandler(
      self.activeContext,
      mods,
      key,
      eventType
    )

    if handler then
      self.onBeforePress(mods, key)
      handler()
    end
  end
end

function ContextualModal:setOnBeforePress(fn)
  self.onBeforePress = fn
  return self
end

function ContextualModal:hasBinding(mods, key)
  if not self.bindings[key] then return false end

  for _, boundMods in pairs(self.bindings[key]) do
    if tableUtils.matches(boundMods, mods) then
      return true
    end
  end

  return false
end

function ContextualModal:registerBinding(mods, key)
  if not self.bindings[key] then self.bindings[key] = {} end

  table.insert(self.bindings[key], mods)

  return self
end

function ContextualModal:bind(mods, key, pressedfn, releasedfn, repeatfn)
  self.registry:registerHandler(
    self.bindingContext,
    mods,
    key,
    pressedfn,
    releasedfn,
    repeatfn
  )

  -- only bind once for this modal
  if not self:hasBinding(mods, key) then
    self:registerBinding(mods, key)

    self.modal:bind(
      mods,
      key,
      self:handlePress(mods, key, 'onPressed'),
      self:handlePress(mods, key, 'onReleased'),
      self:handlePress(mods, key, 'onRepeat')
    )
  end

  return self
end

function ContextualModal:bindWithRepeat(mods, key, fn)
  return self:bind(mods, key, fn, nil, fn)
end

function ContextualModal:withContext(contextKey)
  self.bindingContext = contextKey

  return self
end

function ContextualModal:enterContext(contextKey)
  self.activeContext = contextKey

  if not self.entered then
    self.entered = true
    self.modal:enter()
  end

  return self
end

function ContextualModal:exit()
  self.activeContext = nil

  if self.entered then
    self.entered = false
    self.modal:exit()
  end

  return self
end

return ContextualModal
