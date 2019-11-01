local machine = dofile(vimModeScriptPath .. 'lib/utils/statemachine.lua')

local function createStateMachine(vim)
  return machine.create({
    initial = 'insert-mode',
    events = {
      { name = 'enterNormal', from = 'insert-mode', to = 'normal-mode' },
      { name = 'enterMotion', from = 'normal-mode', to = 'entered-motion' },
      { name = 'enterOperator', from = 'normal-mode', to = 'operator-pending' },
      { name = 'cancelOperator', from = 'operator-pending', to = 'normalmode' },
      { name = 'enterMotion', from = 'operator-pending', to = 'entered-motion' },
      { name = 'fire', from = 'entered-motion', to = 'firing' },
      { name = 'enterNormal', from = 'firing', to = 'normal-mode' },
      { name = 'enterInsert', from = 'firing', to = 'insert-mode' },
      { name = 'enterInsert', from = 'normal-mode', to = 'insert-mode' },
    },
    callbacks = {
      onenterNormal = function()
        vim:resetCommandState()
        vim:setNormalMode()

        vim.modals.normal:enter()
      end,
      onenterInsert = function()
        vim:setInsertMode()
        vim.modals.normal:exit()
      end,
      onenterOperator = function(_, _, _, _, operator)
        vim.commandState.operator = operator
      end,
      onenterMotion = function(self, _, _, _, motion)
        vim.commandState.motion = motion
        self:fire()
      end,
      onfire = function(self)
        vim:fireCommandState()
        self:enterNormal()
      end,
    }
  })
end

return createStateMachine
