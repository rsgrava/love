push = require("push")
require "src/constants"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local window_w, window_h = love.window.getDesktopDimensions()
    push:setupScreen(GAME_W, GAME_H, window_w, window_h,
                     {fullscreen = true, resizable = true, vsync = true})
    love.window.setTitle("love")
    math.randomseed(os.time())
end

function love.update(dt)

end

function love.draw()
    push:start()
    push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end
