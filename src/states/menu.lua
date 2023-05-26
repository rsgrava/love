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
            rows = 1,
            cols = 3,
            frame_tex = assets.graphics.menu,
            pointer_tex = assets.graphics.hand_pointer,
            items = {"Dummy1", "Dummy2", "Dummy3", "Dummy4", "Dummy5", "Dummy6", "Dummy7"}
        })
end

function menuState:leave()
end

function menuState:resume()
end

function menuState:update(dt)
    self.menu:update(dt)
end

function menuState:draw()
    self.menu:draw()
end

--[[
function menu:update(dt)
    if love.keyboard.isPressed("up") then
        self.selection = self.selection - 1
        if self.selection < 0 then
            self.selection = 1
        end
    elseif love.keyboard.isPressed("down") then
        self.selection = (self.selection + 1) % 2
    elseif love.keyboard.isPressed("z") then
        if self.selection == 0 then
            Gamestate.switch(exploration)
        elseif self.selection == 1 then
            love.event.quit()
        end
    end
end

function menu:draw()
    font = love.graphics.getFont()
    love.graphics.print("LOVE", (GAME_W - font:getWidth("LOVE")) / 2, (GAME_H / 4))
    love.graphics.print("Start Game", 50, TILE_H * 10)
    love.graphics.print("Quit", 50, TILE_H * 11)
    if self.selection == 0 then
        love.graphics.print(">", 45, TILE_H * 10)
    elseif self.selection == 1 then
        love.graphics.print(">", 45, TILE_H * 11)
    end
end
--]]
