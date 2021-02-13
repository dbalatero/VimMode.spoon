local ax = dofile(vimModeScriptPath .. "lib/axuielement.lua")
local debug = require('debug')

local debugUtil = {}

local function createTestSuite()
  local testLogger = hs.logger.new('axtest', 'debug')

  local suite = {
    passed = 0,
    failed = 0,
    after = function() end,
  }

  suite.afterTest = function(fn)
    suite.after = fn
  end

  suite.runTest = function(name, fn)
    local status, value = xpcall(fn, debug.traceback)
    suite.after()

    local error = not status
    local failed = not value

    if error then
      suite.failed = suite.failed + 1

      testLogger.i("[FAIL]" .. " " .. name)
      if error then
        local errorMessage = value
        testLogger.e(errorMessage)
      end
    else
      suite.passed = suite.passed + 1
      testLogger.i("[ OK ]" .. " " .. name)
    end

    return status
  end

  suite.printResults = function ()
    local app = hs.application.frontmostApplication()

    testLogger.i("-----------------------------------")
    testLogger.i("")
    testLogger.i("Ran for application: " .. app:name())
    testLogger.i("=> " .. suite.passed .. " passed, " .. suite.failed .. " failed")
    testLogger.i("")
  end

  return suite
end

-- Bind this to a hotkey with Hammerspoon, open the Hammerspoon console, focus
-- a field, and hit your hotkey to run a bunch of Accessibility tests.
--
-- Example of binding it to cmd+shift+ctrl+2:
--
-- local VimMode = hs.loadSpoon('VimMode')
--
-- hs.hotkey.bind(
--   {'cmd','shift','ctrl'},
--   '2',
--   VimMode.util.debug.testAccessibilityField
-- )
--
debugUtil.testAccessibilityField = function()
  local suite = createTestSuite()

  -- for now force manual accessibility on
  local axApp = ax.applicationElement(hs.application.frontmostApplication())
  axApp:setAttributeValue('AXManualAccessibility', true)
  axApp:setAttributeValue('AXEnhancedUserInterface', true)

  local systemElement = ax.systemWideElement()
  local currentElement = systemElement:attributeValue("AXFocusedUIElement")

  suite.afterTest(function()
    -- Clear the field
    currentElement:setAttributeValue('AXValue', '')
  end)

  suite.runTest("AXFocusedUIElement is selectable", function()
    assert(currentElement, "Expected a value for AXFocusedUIElement")
  end)

  suite.runTest("Can set/get AXValue", function()
    currentElement:setAttributeValue('AXValue', 'Test value')
    local value = currentElement:attributeValue('AXValue')

    assert(value == "Test value", "Expected to be able to set the AXValue to 'Test value'")
  end)

  suite.runTest("Can get the default (0, 0) AXSelectedTextRange", function()
    local range = currentElement:attributeValue('AXSelectedTextRange')

    assert(range.location == 0, "Expected AXSelectedTextRange's location to be 0")
    assert(range.length == 0, "Expected AXSelectedTextRange's length to be 0")
  end)

  suite.runTest("Can set/get a cursor selection", function()
    currentElement:setAttributeValue('AXValue', 'Test value')
    currentElement:setAttributeValue('AXSelectedTextRange', { location = 1, length = 5 })

    local range = currentElement:attributeValue('AXSelectedTextRange')
    assert(range.location == 1, "Expected AXSelectedTextRange's location to be 1")
    assert(range.length == 5, "Expected AXSelectedTextRange's length to be 5")
  end)

  suite.printResults()
end

return debugUtil
