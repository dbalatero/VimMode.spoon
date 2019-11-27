local Registry = dofile(vimModeScriptPath .. "lib/contextual_modal/registry.lua")
local tableUtils = dofile(vimModeScriptPath .. "lib/utils/table.lua")
local inspect = hs.inspect.inspect

local ContextualModal = {}

-- Wraps a modal and provides different key layers depending on which
-- context you happen to be in.
--
-- Swapping between multiple modals is too slow, so having a single modal
-- that has context layers helps with key latency and lets us buffer keystrokes.
function ContextualModal:new()
  local wrapper = {
    activeContext = nil,
    bindingContext = nil,
    bindings = {},
    modal = hs.hotkey.modal.new(),
    registry = Registry:new()
  }

  setmetatable(wrapper, self)
  self.__index = self

  wrapper.modal.entered = function()
    vimLogger.i("entering modal context is " .. inspect(wrapper.activeContext))
  end

  wrapper.modal.exited = function()
    vimLogger.i("exited modal context is " .. inspect(wrapper.activeContext))
  end

  return wrapper
end

function ContextualModal:handlePress(mods, key, eventType)
  return function()
    vimLogger.i(
      "Handling a press of ",
      inspect(mods),
      key,
      eventType
    )

    local handler = self.registry:getHandler(
      self.activeContext,
      mods,
      key,
      eventType
    )

    if handler then handler() end
  end
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
  vimLogger.i("Binding ", inspect(mods), key, self.bindingContext)

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
    vimLogger.i("First time binding ", inspect(mods), key)

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
  self.modal:enter()

  return self
end

function ContextualModal:exit()
  vimLogger.i("Exiting modal context")
  self.activeContext = nil
  self.modal:exit()

  return self
end

return ContextualModal
