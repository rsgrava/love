push = require("push")
setmetatable(_G, {
  __index = require("libs/cargo").init('/')
})
require "src/constants"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local window_w, window_h = love.window.getDesktopDimensions()
    push:setupScreen(GAME_W, GAME_H, window_w, window_h,
                     {fullscreen = true, resizable = true, vsync = true})
    love.window.setTitle("love")
    love.graphics.setFont(assets.fonts.pixel_unicode(16))
    math.randomseed(os.time())
end

function love.update(dt)

end

function love.draw()
    push:start()
        love.graphics.print("Hello World", 50, 50)
    push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end
