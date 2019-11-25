local machine = dofile(vimModeScriptPath .. 'lib/utils/statemachine.lua')

local function createStateMachine(vim)
  return machine.create({
    initial = 'insert-mode',
    events = {
      { name = 'enterNormal', from = 'insert-mode', to = 'normal-mode' },
      { name = 'enterNormal', from = 'visual-mode', to = 'normal-mode' },
      { name = 'enterMotion', from = 'normal-mode', to = 'entered-motion' },
      { name = 'enterOperator', from = 'normal-mode', to = 'operator-pending' },
      { name = 'enterMotion', from = 'operator-pending', to = 'entered-motion' },
      { name = 'enterMotion', from = 'visual-mode', to = 'entered-motion' },
      { name = 'enterVisual', from = 'normal-mode', to = 'visual-mode' },
      { name = 'enterOperator', from = 'visual-mode', to = 'operator-pending' },
      { name = 'fire', from = 'entered-motion', to = 'firing' },
      { name = 'fire', from = 'visual-mode', to = 'firing' },
      { name = 'enterNormal', from = 'firing', to = 'normal-mode' },
      { name = 'enterInsert', from = 'firing', to = 'insert-mode' },
      { name = 'enterVisual', from = 'firing', to = 'visual-mode' },
      { name = 'enterInsert', from = 'normal-mode', to = 'insert-mode' },
      { name = 'enterInsert', from = 'operator-pending', to = 'insert-mode' },
      { name = 'enterInsert', from = 'visual-mode', to = 'insert-mode' },
    },
    callbacks = {
      onenterNormal = function()
        vim:resetCommandState()
        vim:setNormalMode()

        vim:enterModal('normal')
      end,
      onenterInsert = function()
        vimLogger.i("Exiting Vim")
        vim:setInsertMode()
        vim:exitAllModals()
        vim:enableSequence()
        vim:hideAlert()
      end,
      onenterVisual = function()
        vimLogger.i("Visual mode")
        vim:setVisualMode()
        vim:enterModal('visual')
      end,
      onenterOperator = function(_, _, _, _, operator)
        vim.commandState.operator = operator
        vim:enterModal('operatorPending')
      end,
      onenterMotion = function(self, _, _, _, motion)
        vim.commandState.motion = motion
        self:fire()
      end,
      onfire = function(self)
        local result = vim:fireCommandState()

        if result.mode == "visual" then
          if result.hadOperator then self:enterNormal()
          else self:enterVisual() end
        else
          if result.transition == "normal" then self:enterNormal()
          else self:enterInsert() end
        end
      end,
    }
  })
end

return createStateMachine
