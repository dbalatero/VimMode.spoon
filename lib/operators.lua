local utils = VimMode.requireFile('lib/utils')

local function operator(fn)
  local definition = fn()

  return function(vim)
    return function()
      vim.commandState.selection = definition.selection or false
      vim.commandState.operatorFn = definition.fn

      if vim.commandState.visualMode then vim.runOperator() end
    end
  end
end

-- Operators
local operators = {}

operators.delete = operator(function()
  return {
    selection = true,
    fn = function() utils.sendKeys({}, 'delete') end
  }
end)

operators.yank = operator(function()
  return {
    selection = true,
    fn = function(vim)
      utils.sendKeys({'cmd'}, 'c')
      vim:restoreCursor()
    end
  }
end)

operators.paste = operator(function()
  return {
    selection = false,
    fn = function()
      hs.printf("pasting")
      utils.sendKeys({'cmd'}, 'v')
    end
  }
end)

operators.undo = operator(function()
  return {
    selection = false,
    fn = function(vim)
      hs.printf("undo")
      utils.sendKeys({'cmd'}, 'z')
      vim:restoreCursor()
    end
  }
end)

operators.change = operator(function()
  return {
    selection = true,
    fn = function(vim)
      utils.sendKeys({}, 'delete')
      vim:exit()
    end
  }
end)

return operators
