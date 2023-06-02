push = require("libs/push")
setmetatable(_G, {
  __index = require("libs/cargo").init('/')
})
Gamestate = require("libs/gamestate")
local baton = require ("libs/baton")
require("libs/slam")
require("src/constants")
require("src/states/menu")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local window_w, window_h = love.window.getDesktopDimensions()
    push:setupScreen(GAME_W, GAME_H, window_w, window_h,
                     {fullscreen = true, resizable = true, vsync = true})
    love.window.setTitle("love")
    love.graphics.setFont(assets.fonts.public_pixel(8))
    math.randomseed(os.time())

    love.joystick.loadGamepadMappings("gamecontrollerdb.txt")
    Input = baton.new(controls)

    Gamestate.switch(menuState)
end

function love.update(dt)
    love.window.setTitle(GAME_TITLE.." - "..love.timer.getFPS().." fps")
    Input:update()
    Gamestate.current():update(dt)
end

function love.draw()
    push:start()
        Gamestate.current():draw(dt)
    push:finish()
end

function love.resize(w, h)
  push:resize(w, h)
end
