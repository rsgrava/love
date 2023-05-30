Gamestate = require("libs/gamestate")
require "src/constants"
require "src/states/exploration"
require "src/entities/menu"

menuState = {}

function menuState:init()
end

function menuState:enter()
    self.menu = Menu:init({
            x = 0,
            y = 0,
            rows = 3,
            cols = 1,
            frame_tex = assets.graphics.menu,
            pointer_tex = assets.graphics.hand_pointer,
            move_sound = assets.audio.move_cursor,
            confirm_sound = assets.audio.confirm,
            cancel_sound = assets.audio.cancel,
            disabled_sound = assets.audio.disabled,
            items = {
                {
                    name = "Start Game",
                    onConfirm = function() Gamestate.switch(exploration) end,
                    enabled = true
                },
                {
                    name = "Options",
                    enabled = false
                },
                {
                    name = "Quit",
                    onConfirm = function() love.event.quit() end,
                    enabled = true
                },
            }
        })
    self.menu:setPos((GAME_W - self.menu:getWidth()) / 2, (GAME_H - self.menu:getHeight()) / 2)
end

function menuState:leave()
end

function menuState:resume()
end

function menuState:update(dt)
    if love.keyboard.isPressed("z") then
        self.menu:onConfirm()
    elseif love.keyboard.isPressed("x") then
        self.menu:onCancel()
    elseif love.keyboard.isPressed("up") then
        self.menu:onUp()
    elseif love.keyboard.isPressed("down") then
        self.menu:onDown()
    elseif love.keyboard.isPressed("left") then
        self.menu:onLeft()
    elseif love.keyboard.isPressed("right") then
        self.menu:onRight()
    end
end

function menuState:draw()
    self.menu:draw()
    local font = love.graphics.getFont()
    love.graphics.print(GAME_TITLE, (GAME_W - font:getWidth(GAME_TITLE)) / 2, TILE_H * 3 - font:getHeight(GAME_TITLE) / 2)
end
