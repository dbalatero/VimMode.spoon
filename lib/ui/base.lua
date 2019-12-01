local UiBase = {
  Element = {}
}

function UiBase:new()
  local base = {}

  setmetatable(base, self)
  self.__index = self

  return base
end

function UiBase.getCurrentElement()
  error("Implement getCurrentElement()")
end

-------------------------------
-- Element shim
-------------------------------
function UiBase.Element:new()
  local element = {}

  setmetatable(element, self)
  self.__index = self

  return element
end

return UiBase
