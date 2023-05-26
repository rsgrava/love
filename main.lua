push = require("libs/push")
setmetatable(_G, {
  __index = require("libs/cargo").init('/')
})
Gamestate = require("libs/gamestate")
require "src/constants"
require "src/states/menu"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local window_w, window_h = love.window.getDesktopDimensions()
    push:setupScreen(GAME_W, GAME_H, window_w, window_h,
                     {fullscreen = true, resizable = true, vsync = true})
    love.window.setTitle("love")
    love.graphics.setFont(assets.fonts.pixel_unicode(16))
    math.randomseed(os.time())

    love.keyboard.pressed = {}
    love.keyboard.released = {}

    Gamestate.switch(menu)
end

function love.update(dt)
    Gamestate.current():update(dt)
    love.keyboard.pressed = {}
    love.keyboard.pressed = {}
    love.keyboard.released = {}
end

function love.draw()
    push:start()
        Gamestate.current():draw(dt)
    push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.pressed[key] = true
end

function love.keyreleased(key)
    love.keyboard.released[key] = true
end

function love.keyboard.isPressed(key)
    return love.keyboard.pressed[key]
end

function love.keyboard.isReleased(key)
    return love.keyboard.released[key]
end
