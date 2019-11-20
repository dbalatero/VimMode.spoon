-- Dims the screen a la Flux to indicate we've shifted modes

local ScreenDimmer = {}

function ScreenDimmer.dimScreen()
  -- Stole these shifts from flux-like plugin
  -- https://github.com/calvinwyoung/.dotfiles/blob/master/darwin/hammerspoon/flux.lua
  local whiteShift = {
    alpha = 1.0,
    red = 1.0,
    green = 0.95201559,
    blue = 0.90658983,
  }

  local blackShift = {
    alpha = 1.0,
    red = 0,
    green = 0,
    blue = 0,
  }

  hs.screen.primaryScreen():setGamma(whiteShift, blackShift)
end

function ScreenDimmer.restoreScreen()
  hs.screen.restoreGamma()
end

return ScreenDimmer
