local machine = dofile(vimModeScriptPath .. 'lib/utils/statemachine.lua')

local function createStateMachine(vim)
  return machine.create({
    initial = 'insert-mode',
    events = {
      { name = 'enterNormal', from = 'insert-mode', to = 'normal-mode' },
      { name = 'enterNormal', from = 'visual-mode', to = 'normal-mode' },
      { name = 'enterNormal', from = 'firing', to = 'normal-mode' },
      { name = 'enterNormal', from = 'operator-pending', to = 'normal-mode' },

      { name = 'enterMotion', from = 'normal-mode', to = 'entered-motion' },
      { name = 'enterMotion', from = 'operator-pending', to = 'entered-motion' },
      { name = 'enterMotion', from = 'visual-mode', to = 'entered-motion' },

      { name = 'enterOperator', from = 'normal-mode', to = 'operator-pending' },
      { name = 'enterOperator', from = 'visual-mode', to = 'operator-pending' },

      { name = 'enterVisual', from = 'normal-mode', to = 'visual-mode' },
      { name = 'enterVisual', from = 'firing', to = 'visual-mode' },

      { name = 'fire', from = 'entered-motion', to = 'firing' },
      { name = 'fire', from = 'visual-mode', to = 'firing' },

      { name = 'enterInsert', from = 'firing', to = 'insert-mode' },
      { name = 'enterInsert', from = 'normal-mode', to = 'insert-mode' },
      { name = 'enterInsert', from = 'operator-pending', to = 'insert-mode' },
      { name = 'enterInsert', from = 'visual-mode', to = 'insert-mode' },
    },
    callbacks = {
      onenterNormal = function()
        vim:disableSequence()
        vim:resetCommandState()
        vim:setNormalMode()
        vim:enterModal('normal')
        vimLogger.i("normal enter")
      end,
      onenterInsert = function()
        vim.visualCaretPosition = nil
        vim:exitAllModals()
        vim:setInsertMode()
        vim:resetCommandState()
        vim:enableSequence()
      end,
      onenterVisual = function()
        vim:setVisualMode()
        vim:enterModal('visual')
      end,
      onenterOperator = function(_, _, _, _, operator)
        vim:enterModal('operatorPending')
        vim.commandState.operator = operator
      end,
      onenterMotion = function(self, _, _, _, motion)
        vim.commandState.motion = motion
        self:fire()
      end,
      onfire = function(self)
        local result = vim:fireCommandState()

        if result.mode == "visual" then
          if result.hadOperator then
            self:enterNormal()
          else
            self:enterVisual()
          end
        else
          if result.transition == "normal" then self:enterNormal()
          else vim:exitAsync() end
        end
      end,
      onstatechange = function()
        vim:updateStateIndicator()
      end
    }
  })
end

return createStateMachine
