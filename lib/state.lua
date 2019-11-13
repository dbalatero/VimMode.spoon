local machine = dofile(vimModeScriptPath .. 'lib/utils/statemachine.lua')

local function createStateMachine(vim)
  return machine.create({
    initial = 'insert-mode',
    events = {
      { name = 'enterNormal', from = 'insert-mode', to = 'normal-mode' },
      { name = 'enterMotion', from = 'normal-mode', to = 'entered-motion' },
      { name = 'enterOperator', from = 'normal-mode', to = 'operator-pending' },
      { name = 'enterMotion', from = 'operator-pending', to = 'entered-motion' },
      { name = 'fire', from = 'entered-motion', to = 'firing' },
      { name = 'enterNormal', from = 'firing', to = 'normal-mode' },
      { name = 'enterInsert', from = 'firing', to = 'insert-mode' },
      { name = 'enterInsert', from = 'normal-mode', to = 'insert-mode' },
      { name = 'enterInsert', from = 'operator-pending', to = 'insert-mode' },
    },
    callbacks = {
      onenterNormal = function()
        vim:resetCommandState()
        vim:setNormalMode()

        vim:enterModal('normal')
      end,
      onenterInsert = function()
        vim:setInsertMode()
        vim:exitAllModals()
        vimLogger.i("Exiting Vim")
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
        local transition = vim:fireCommandState()

        if transition == "normal" then
          self:enterNormal()
        else
          self:enterInsert()
        end
      end,
    }
  })
end

return createStateMachine
