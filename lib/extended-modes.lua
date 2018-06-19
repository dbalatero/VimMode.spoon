local utils = VimMode.requireFile('lib/utils')

replaceTap = nil

local modes = {}

modes.replace = function(vim)
  return function()
    replaceTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
      replaceTap:stop()

      utils.sendKeys({'shift'}, 'right')
      utils.sendKeys({}, hs.keycodes.map[event:getKeyCode()])

      vim:enter()
      return true
    end)

    vim:exit()
    replaceTap:start()
  end
end

return modes
