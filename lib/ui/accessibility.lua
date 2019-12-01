local ax = require("hs._asm.axuielement")

local UiBase = dofile(vimModeScriptPath .. "lib/ui/base.lua")

local UiAccessibility = UiBase:new()
UiAccessibility.Element = UiBase.Element.new()

function UiAccessibility.getCurrentElement()
  local systemElement = ax.systemWideElement()
  local axElement = systemElement:attributeValue("AXFocusedUIElement")

  return axElement
end

function UiAccessibility.Element:new(axElement)
  local element = {
    axElement = axElement
  }

  setmetatable(element, self)
  self.__index = self

  return element
end

return UiAccessibility
