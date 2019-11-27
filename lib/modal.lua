local ContextualModal = dofile(vimModeScriptPath .. "lib/contextual_modal.lua")
local WaitForChar = dofile(vimModeScriptPath .. "lib/wait_for_char.lua")

-- motions
local BackWord = dofile(vimModeScriptPath .. "lib/motions/back_word.lua")
local BigWord = dofile(vimModeScriptPath .. "lib/motions/big_word.lua")
local CurrentSelection = dofile(vimModeScriptPath .. "lib/motions/current_selection.lua")
local EndOfWord = dofile(vimModeScriptPath .. "lib/motions/end_of_word.lua")
local EntireLine = dofile(vimModeScriptPath .. "lib/motions/entire_line.lua")
local FirstLine = dofile(vimModeScriptPath .. "lib/motions/first_line.lua")
local FirstNonBlank = dofile(vimModeScriptPath .. "lib/motions/first_non_blank.lua")
local LastLine = dofile(vimModeScriptPath .. "lib/motions/last_line.lua")
local LineBeginning = dofile(vimModeScriptPath .. "lib/motions/line_beginning.lua")
local LineEnd = dofile(vimModeScriptPath .. "lib/motions/line_end.lua")
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

local function createVimModal(vim)
  local modal = ContextualModal:new()

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

  local operatorNeedingChar = function(type, optionalMotion)
    return function()
      vim:exitAllModals()
      vimLogger.i("waiting on char...")

      local waiter = WaitForChar:new{
        onCancel = function()
          vimLogger.i("onCancel()")
          vim:cancel()
        end,
        onChar = function(character)
          local op = type:new()
          op:setExtraChar(character)

          vimLogger.i("Got a character " .. character .. " for " .. op.name)

          vim:enterOperator(op)

          if optionalMotion then
            vim:enterMotion(optionalMotion:new())
          end
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
      :bindWithRepeat({}, 'h', motion(Left))
      :bindWithRepeat({}, 'j', motion(Down))
      :bindWithRepeat({}, 'k', motion(Up))
      :bindWithRepeat({}, 'l', motion(Right))
      :bindWithRepeat({}, 'w', motion(Word))
      :bindWithRepeat({'shift'}, 'w', motion(BigWord))
      :bindWithRepeat({'shift'}, 'g', motion(LastLine))
      :bind({}, 'g', function() vim:enterModal('g') end)
  end

  -- g prefixes
  modal
    :withContext('g')
    :bind({}, 'escape', function() vim:exit() end)
    :bind({}, 'g', motion(FirstLine))

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

  -- Normal mode
  modal
    :withContext('normal')
    :bindMotionsToModal('operator')
    :bindCountsToModal('operator')
    :bind({}, 'i', function() vim:exit() end)
    :bind({}, 'c', operator(Change))
    :bind({}, 'd', operator(Delete))
    :bind({}, 'y', operator(Yank))
    :bind({}, 'r', operatorNeedingChar(Replace, Right))
    :bind({}, 'v', function()
      vim.state:enterVisual()
    end)
    :bind({}, '/', function()
      hs.eventtap.keyStroke({'cmd'}, 'f', 0)
      vim:exit()
    end)
    :bind({}, 'p', function()
      hs.eventtap.keyStroke({'cmd'}, 'v', 0)
    end)
    :bind({}, 'o', function()
      vim:exit()
      hs.eventtap.keyStroke({'cmd'}, 'right', 0)
      hs.eventtap.keyStroke({}, 'return', 0)
    end)
    :bind({}, 'u', function()
      -- undo
      hs.eventtap.keyStroke({'cmd'}, 'z', 0)
    end)
    :bind({'ctrl'}, 'r', function()
      -- redo
      hs.eventtap.keyStroke({'cmd','shift'}, 'z', 0)
    end)
    :bind({'shift'}, 'o', function()
      vim:exit()
      hs.eventtap.keyStroke({'cmd'}, 'left', 0)
      hs.eventtap.keyStroke({}, 'return', 0)
      hs.eventtap.keyStroke({}, 'up', 0)
    end)
    :bind({'shift'}, 'a', function()
      fireMotion(LineEnd)
      vim:exit()
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
      vim:exit()
    end))
    :bindWithRepeat({}, 'x', function()
      fireOperator(Delete)
      fireMotion(Right)
    end)
    :bindWithRepeat({}, 's', function()
      vimLogger.i("in here")
      fireOperator(Change)
      fireMotion(Right)
    end)

  modal
    :withContext('operatorPending')
      :bind({}, 'escape', function() vim:exit() end)
      :bindWithRepeat({}, 'b', motion(BackWord))
      :bindWithRepeat({}, 'w', motion(Word))

  return modal
end

return createVimModal
