local Alert = {}

function Alert:new()
  local alert = {
    uuid = nil
  }

  setmetatable(alert, self)
  self.__index = self

  return alert
end

function Alert:show(config)
  self.uuid =
    hs.alert.show(
      "$ vi",
      {
        atScreenEdge = 2,
        radius = 0,
        strokeWidth = 4,
        textFont = config.alert.font,
        textSize = 18,
        fadeInDuration = 0.25,
        fadeOutDuration = 0.25,
        fillColor = {
          red = 4 / 255,
          green = 135 / 255,
          blue = 250 / 255,
          alpha = 0.95,
        }
      },
      hs.screen.mainScreen(),
      "infinite"
    )

  return self
end

function Alert:hide()
  if not self.uuid then return end

  hs.alert.closeSpecific(self.uuid)
  self.uuid = nil

  return self
end

return Alert
