local ax = require("hs._asm.axuielement")

local axUtils = dofile(vimModeScriptPath .. "lib/utils/ax.lua")

local StateIndicator = {}

local elementIndexBox = 1
local elementIndexText = 2

local function rgba(r, g, b, a)
  a = a or 1.0

  return {
    red = r / 255,
    green = g / 255,
    blue = b / 255,
    alpha = a
  }
end

local colors = {
  default = rgba(4, 135, 250, 0.95),
  normal = rgba(4, 135, 250, 0.95),
  visual = rgba(210, 152, 97, 0.95)
}

local defaultWidth = 125
local defaultHeight = 25

local function getFocusedElementPosition()
  local systemElement = ax.systemWideElement()
  if not systemElement then return nil end

  local currentElement = systemElement:attributeValue("AXFocusedUIElement")
  if not currentElement then return nil end

  -- we don't want to get position for anything that isn't a text field
  if not axUtils.isTextField(currentElement) then return nil end

  local position = currentElement:position()
  if not position then return nil end

  return {
    x = position.x,
    y = position.y
  }
end

function StateIndicator:new(vim)
  local canvas = hs.canvas.new{
    w = defaultWidth,
    h = defaultHeight,
    x = 100,
    y = 100,
  }

  canvas:insertElement(
    {
      type = 'rectangle',
      action = 'fill',
      roundedRectRadii = { xRadius = 2, yRadius = 2 },
      fillColor = colors.normal,
      strokeColor = { white = 1.0 },
      strokeWidth = 3.0,
      frame = { x = "0%", y = "0%", h = "100%", w = "100%", },
      withShadow = true
    },
    elementIndexBox
  )

  canvas:insertElement(
    {
      type = 'text',
      action = 'fill',
      frame = {
        x = "5%", y = "10%", h = "100%", w = "95%"
      },
      text = "placeholder" -- we'll override this in render()
    }
  )

  local indicator = {
    canvas = canvas,
    vim = vim,
    showing = false
  }

  setmetatable(indicator, self)
  self.__index = self

  return indicator
end

-- Returns true if we should show the state indicator,
-- false if we should not show it.
function StateIndicator:render()
  local vim = self.vim

  if not vim.config.shouldShowAlertInNormalMode then return false end
  if vim:isMode('insert') then return false end

  local canvas = self.canvas

  -- set the inner text
  canvas:elementAttribute(elementIndexText, 'text', self:getBoxText())

  -- set the box color
  local boxFillColor = colors[vim.mode] or colors.default
  canvas:elementAttribute(elementIndexBox, 'fillColor', boxFillColor)

  -- move the canvas to the element
  canvas:topLeft(self:getElementPosition(defaultWidth))

  return true
end

local modes = {
  insert = "INSERT",
  normal = "NORMAL",
  visual = "VISUAL"
}

function StateIndicator:getElementPosition(canvasWidth)
  local elementPosition = getFocusedElementPosition()

  if elementPosition then
    local yOffset = 3 -- OS X adds a blue focused border, we want to clear it

    return {
      x = elementPosition.x,
      y = elementPosition.y - defaultHeight - yOffset
    }
  else
    -- get the frame of the screen we are currently focused on
    local frame = hs.screen.mainScreen():frame()

    local width = frame.w
    local yBottom = frame.y + frame.h
    local yOffset = defaultHeight / 2

    -- center the canvas
    local x = (width / 2) - (canvasWidth / 2)

    return {
      x = x,
      y = yBottom - defaultHeight - yOffset
    }
  end
end

function StateIndicator:getBoxText()
  local vim = self.vim
  local modeText = modes[vim.mode]
  local text = modeText

  return hs.styledtext.new(
    text,
    {
      font = { name = "Courier New Bold", size = 14 },
      color = { white = 1.0 }
    }
  )
end

function StateIndicator:update()
  if self:render() then
    if not self.showing then
      self.canvas:show()
      self.canvas:bringToFront()
      self.showing = true
    end
  elseif self.showing then
    self.canvas:hide()
    self.showing = false
  end

  return self
end

return StateIndicator
