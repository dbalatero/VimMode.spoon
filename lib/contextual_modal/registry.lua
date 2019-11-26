local tableUtils = dofile(vimModeScriptPath .. "lib/utils/table.lua")

local Registry = {}

function Registry:new()
  local registry = {
    fns = {}
  }

  setmetatable(registry, self)
  self.__index = self

  return registry
end

function Registry:registerHandler(contextKey, mods, key, pressedfn, releasedfn, repeatfn)
  if not self.fns[contextKey] then self.fns[contextKey] = {} end
  local context = self.fns[contextKey]

  if not context[key] then context[key] = {} end
  local keyHandlers = context[key]

  table.insert(keyHandlers, {
    mods = mods,
    handlers = {
      onPressed = pressedfn,
      onReleased = releasedfn,
      onRepeat = repeatfn
    }
  })

  return self
end

function Registry:getHandler(contextKey, mods, key, eventType)
  local context = self.fns[contextKey]
  if not context then return nil end

  local keyHandlers = context[key]
  if not keyHandlers then return nil end

  for _, entry in pairs(keyHandlers) do
    if tableUtils.matches(entry.mods, mods) then
      return entry.handlers[eventType]
    end
  end

  return nil
end

return Registry
