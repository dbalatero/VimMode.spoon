local AccessibilityBuffer = dofile(vimModeScriptPath .. "lib/accessibility_buffer.lua")

local BlockCursor = {}

function BlockCursor:new()
  local canvas = hs.canvas.new({ x = 0, y = 0, h = 1, w = 1 })
  local rectangleElementIndex = 1

  canvas:level('overlay')
  canvas:insertElement(
    {
      type = 'rectangle',
      action = 'fill',
      fillColor = { red = 0, green = 0, blue = 0, alpha = 0.2 },
      frame = { x = "0%", y = "0%", h = "100%", w = "100%", },
      withShadow = false
    },
    rectangleElementIndex
  )

  local cursor = {
    canvas = canvas,
  }

  setmetatable(cursor, self)
  self.__index = self

  cursor.redrawTimer = hs.timer.new(1 / 60, function()
    local result = cursor:_renderFrame()

    if not result then
      cursor:hide()
    end
  end)

  return cursor
end

function BlockCursor:show()
  if self.canvas:isShowing() then return nil end

  self.redrawTimer:start()
  self.canvas:show()
end

function BlockCursor:hide()
  if not self.canvas:isShowing() then return nil end

  self.canvas:hide()
  self.redrawTimer:stop()
end

-- Renders a single frame. Returns `true` if successful.
function BlockCursor:_renderFrame()
  local buffer = AccessibilityBuffer:new()
  if not buffer:isValid() then return false end

  local currentElement = buffer:getCurrentElement()

  -- We don't want to draw the cursor if we're at the end of the textbox (or
  -- past the end!)
  if buffer:isAtLastVisibleCharacter() then return false end

  -- Get the range for the next character after the blinking cursor
  local range = buffer:getSelectionRange()
  local caretRange = {
    location = range.location,
    length = 1,
  }

  -- Get the { h, w, x, y } bounding box for the next character's range so we
  -- can draw over it.
  local bounds = currentElement:parameterizedAttributeValue(
    "AXBoundsForRange",
    caretRange
  )

  -- chrome doesn't have good support for AXBoundsForRange and returns a 0-sized
  -- bounds:
  --
  -- https://groups.google.com/a/chromium.org/g/chromium-accessibility/c/eB34iqVFAu8
  if bounds.h == 0 or bounds.w == 0 then return false end

  -- move the position and resize
  self.canvas:topLeft({ x = bounds.x, y = bounds.y })
  self.canvas:size({ h = bounds.h, w = bounds.w })

  return true
end

return BlockCursor
