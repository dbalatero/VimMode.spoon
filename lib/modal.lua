local AccessibilityBuffer = dofile(vimModeScriptPath .. "lib/accessibility_buffer.lua")
local ContextualModal = dofile(vimModeScriptPath .. "lib/contextual_modal.lua")
local WaitForChar = dofile(vimModeScriptPath .. "lib/wait_for_char.lua")

-- motions
local BackwardSearch = dofile(vimModeScriptPath .. "lib/motions/backward_search.lua")
local BackWord = dofile(vimModeScriptPath .. "lib/motions/back_word.lua")
local BetweenChars = dofile(vimModeScriptPath .. "lib/motions/between_chars.lua")
local BigWord = dofile(vimModeScriptPath .. "lib/motions/big_word.lua")
local CurrentSelection = dofile(vimModeScriptPath .. "lib/motions/current_selection.lua")
local EndOfWord = dofile(vimModeScriptPath .. "lib/motions/end_of_word.lua")
local EntireLine = dofile(vimModeScriptPath .. "lib/motions/entire_line.lua")
local FirstLine = dofile(vimModeScriptPath .. "lib/motions/first_line.lua")
local FirstNonBlank = dofile(vimModeScriptPath .. "lib/motions/first_non_blank.lua")
local ForwardSearch = dofile(vimModeScriptPath .. "lib/motions/forward_search.lua")
local InWord = dofile(vimModeScriptPath .. "lib/motions/in_word.lua")
local LastLine = dofile(vimModeScriptPath .. "lib/motions/last_line.lua")
local LineBeginning = dofile(vimModeScriptPath .. "lib/motions/line_beginning.lua")
local LineEnd = dofile(vimModeScriptPath .. "lib/motions/line_end.lua")
local Noop = dofile(vimModeScriptPath .. "lib/motions/noop.lua")
local TillAfterSearch = dofile(vimModeScriptPath .. "lib/motions/till_after_search.lua")
local TillBeforeSearch = dofile(vimModeScriptPath .. "lib/motions/till_before_search.lua")
local Word = dofile(vimModeScriptPath .. "lib/motions/word.lua")

local Left = dofile(vimModeScriptPath .. "lib/motions/left.lua")
local Right = dofile(vimModeScriptPath .. "lib/motions/right.lua")
local Up = dofile(vimModeScriptPath .. "lib/motions/up.lua")
local Down = dofile(vimModeScriptPath .. "lib/motions/down.lua")

-- operators
local Change = dofile(vimModeScriptPath .. "lib/operators/change.lua")
local Delete = dofile(vimModeScriptPath .. "lib/operators/delete.lua")
local Replace = dofile(vimModeScriptPath .. "lib/operators/replace.lua")
local Yank = dofile(vimModeScriptPath .. "lib/operators/yank.lua")

local times = dofile(vimModeScriptPath .. "lib/utils/times.lua")

local function createVimModal(vim)
  local motion = function(type)
    return function() vim:enterMotion(type:new()) end
  end

  local operator = function(type)
    return function() vim:enterOperator(type:new()) end
  end

  local fireMotion = function(type)
    motion(type)()
  end

  local fireOperator = function(type)
    operator(type)()
  end

  local pageDirection = function(direction)
    return function()
      local lines = 10
      local buffer = AccessibilityBuffer:new()

      if buffer:isValid() then
        visibleRange = buffer:visibleLineRange()
        lines = (visibleRange.finish - visibleRange.start) / 2
      end

      if lines > 0 then
        times(lines, function() fireMotion(direction) end)
      else
        fireMotion(Noop)
      end
    end
  end

  local operatorNeedingChar = function(type, optionalMotion)
    return function()
      local previousContext = vim:exitModalAsync()

      local op = type:new()
      vim:setPendingInput(op.name)

      WaitForChar:new{
        onCancel = function()
          vim:setPendingInput(nil)
          vim:cancel()
        end,
        onChar = function(character)
          op:setExtraChar(character)
          vim:setPendingInput(nil)

          hs.timer.doAfter(5 / 1000, function()
            vim:enterOperator(op)

            if optionalMotion then
              vim:enterMotion(optionalMotion:new())
            end
          end)
        end
      }:start()
    end
  end

  local betweenChars = function(start, finish)
    return function()
      local motion = BetweenChars:new()
      motion:setSearchChars(start, finish)
      vim:enterMotion(motion)
    end
  end

  local motionNeedingChar = function(type)
    return function()
      local previousContext = vim:exitModalAsync()

      local motion = type:new()
      vim:setPendingInput(motion.name)

      local waiter = WaitForChar:new{
        onCancel = function()
          vim:setPendingInput(nil)
          vim:cancel()
        end,
        onChar = function(character)
          motion:setExtraChar(character)
          vim:setPendingInput(nil)

          vim:enterModal(previousContext)
          hs.timer.doAfter(5 / 1000, function() vim:enterMotion(motion) end)
        end
      }

      waiter:start()
    end
  end

  local advancedModeOnly = function(fn)
    return function()
      if vim:canUseAdvancedMode() then fn() end
    end
  end

  local visualOperator = function(type)
    return function()
      fireOperator(type)
      fireMotion(CurrentSelection)
    end
  end

  local pushDigitTo = function(name, digit)
    return function() vim:pushDigitTo(name, digit) end
  end

  local modal = ContextualModal:new()

  -- reusable bindings
  modal.bindCountsToModal = function(mdl, name)
    return mdl
      :bindWithRepeat({}, '1', pushDigitTo(name, 1))
      :bindWithRepeat({}, '2', pushDigitTo(name, 2))
      :bindWithRepeat({}, '3', pushDigitTo(name, 3))
      :bindWithRepeat({}, '4', pushDigitTo(name, 4))
      :bindWithRepeat({}, '5', pushDigitTo(name, 5))
      :bindWithRepeat({}, '6', pushDigitTo(name, 6))
      :bindWithRepeat({}, '7', pushDigitTo(name, 7))
      :bindWithRepeat({}, '8', pushDigitTo(name, 8))
      :bindWithRepeat({}, '9', pushDigitTo(name, 9))
  end

  modal.bindMotionsToModal = function(mdl, type)
    return mdl
      :bindWithRepeat({}, '0', function()
        -- we've already started adding a count here
        if vim.commandState:getCount(type) then
          pushDigitTo(type, 0)()
        else
          fireMotion(LineBeginning)
        end
      end)
      :bindWithRepeat({'shift'}, '4', motion(LineEnd)) -- $
      :bindWithRepeat({}, 'b', motion(BackWord))
      :bindWithRepeat({}, 'e', motion(EndOfWord))
      :bind({}, 'f', motionNeedingChar(ForwardSearch))
      :bind({'shift'}, 'f', motionNeedingChar(BackwardSearch))
      :bindWithRepeat({}, 'h', motion(Left))
      :bindWithRepeat({}, 'j', motion(Down))
      :bindWithRepeat({}, 'k', motion(Up))
      :bindWithRepeat({}, 'l', motion(Right))
      :bind({}, 't', motionNeedingChar(TillBeforeSearch))
      :bind({'shift'}, 't', motionNeedingChar(TillAfterSearch))
      :bindWithRepeat({}, 'w', motion(Word))
      :bindWithRepeat({'shift'}, 'w', motion(BigWord))
      :bindWithRepeat({'shift'}, 'g', motion(LastLine))
      :bind({}, 'g', function() vim:enterModal('g') end)
      :bind({}, 'i', function() vim:enterModal('inTextObject') end)
      :bindWithRepeat({}, 'up', motion(Up))
      :bindWithRepeat({}, 'down', motion(Down))
      :bindWithRepeat({}, 'left', motion(Left))
      :bindWithRepeat({}, 'right', motion(Right))
  end

  -- g prefixes
  modal
    :withContext('g')
    :bind({}, 'escape', function() vim:cancel() end)
    :bind({}, 'g', motion(FirstLine))

  -- "in" text object prefixes
  modal
    :withContext('inTextObject')
    :bind({}, 'escape', function() vim:cancel() end)
    -- i`
    :bind({}, "`", betweenChars("`", "`"))

    -- i(
    :bind({'shift'}, "9", betweenChars("(", ")"))
    -- i)
    :bind({'shift'}, "0", betweenChars("(", ")"))

    -- i{
    :bind({'shift'}, "[", betweenChars("{", "}"))
    -- i}
    :bind({'shift'}, "]", betweenChars("{", "}"))

    -- i[
    :bind({}, "[", betweenChars("[", "]"))
    -- i]
    :bind({}, "]", betweenChars("[", "]"))

    -- i<
    :bind({'shift'}, ",", betweenChars("<", ">"))
    -- i>
    :bind({'shift'}, ".", betweenChars("<", ">"))

    -- i'
    :bind({}, "'", betweenChars("'", "'"))
    -- i"

    :bind({'shift'}, "'", betweenChars('"', '"'))
    :bind({}, 'w', motion(InWord))

  -- Visual mode
  modal
    :withContext('visual')
    :bindMotionsToModal('motion')
    :bind({}, 'escape', function()
      vim.state:enterNormal()
      vim:setVisualCaretPosition(nil)
    end)
    :bind({}, 'c', visualOperator(Delete))
    :bind({}, 'd', visualOperator(Delete))
    :bind({}, 'r', nil, operatorNeedingChar(Replace, CurrentSelection))
    :bind({}, 'x', visualOperator(Delete))
    :bind({}, 'y', visualOperator(Yank))

  -- Operator pending
  modal
    :withContext('operatorPending')
    :bindMotionsToModal('motion')
    :bindCountsToModal('motion')
    :bind({}, 'escape', function() vim:cancel() end)
    :bind({}, 'c', motion(EntireLine)) -- cc
    :bind({}, 'd', motion(EntireLine)) -- dd
    :bind({}, 'y', motion(EntireLine)) -- yy

  -- Normal mode
  modal
    :withContext('normal')
    :bind({}, 'i', function() vim:exitAsync() end)
    :bindMotionsToModal('operator')
    :bindCountsToModal('operator')
    :bind({}, 'c', operator(Change))
    :bind({}, 'd', operator(Delete))
    :bind({}, 'y', operator(Yank))
    :bind({}, 'r', operatorNeedingChar(Replace, Right))
    :bind({}, 'v', function()
      vim.state:enterVisual()
    end)
    :bind({}, '/', function()
      hs.eventtap.keyStroke({'cmd'}, 'f', 0)
      vim:exitAsync()
    end)
    :bind({}, 'p', function()
      hs.eventtap.keyStroke({'cmd'}, 'v', 0)
    end)
    :bind({}, 'o', function()
      hs.eventtap.keyStroke({'cmd'}, 'right', 0)
      hs.eventtap.keyStroke({}, 'return', 0)
      vim:exitAsync()
    end)
    :bind({}, 'u', function()
      -- undo
      hs.eventtap.keyStroke({'cmd'}, 'z', 0)
    end)
    :bind({'ctrl'}, 'r', function()
      -- redo
      hs.eventtap.keyStroke({'cmd','shift'}, 'z', 0)
    end)
    :bind({'ctrl'}, 'd', pageDirection(Down))
    :bind({'ctrl'}, 'u', pageDirection(Up))
    :bind({'shift'}, 'o', function()
      hs.eventtap.keyStroke({'cmd'}, 'left', 0)
      hs.eventtap.keyStroke({}, 'return', 0)
      hs.eventtap.keyStroke({}, 'up', 0)
      vim:exitAsync()
    end)
    :bind({'shift'}, 'a', function()
      fireMotion(LineEnd)
      vim:exitAsync()
    end)
    :bind({'shift'}, 'c', function()
      fireOperator(Change)
      fireMotion(LineEnd)
    end)
    :bind({'shift'}, 'd', function()
      fireOperator(Delete)
      fireMotion(LineEnd)
    end)
    :bind({'shift'}, 'i', advancedModeOnly(function()
      fireMotion(LineBeginning)
      fireMotion(FirstNonBlank)
      vim:exitAsync()
    end))
    :bindWithRepeat({}, 'x', function()
      fireOperator(Delete)
      fireMotion(Right)
    end)
    :bindWithRepeat({}, 's', function()
      fireOperator(Change)
      fireMotion(Right)
    end)

  return modal
end

return createVimModal
