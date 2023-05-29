Class = require("libs/class")
Timer = require("libs/timer")
require("src/constants")
require("src/sprite")
require("src/utils")

Character = Class{}

function Character:init(defs)
    self.state = defs.state or "idle"
    self.direction = defs.direction or "down"
    self.sprite = Sprite({
        texture = defs.texture,
        animation = defs.animation,
        firstAnim = self.state..'_'..self.direction,
        width = CHARACTER_W,
        height = CHARACTER_H
    })
    self.tile_x = defs.tile_x
    self.tile_y = defs.tile_y
    self.x = defs.tile_x * TILE_W 
    self.y = defs.tile_y * TILE_H - CHARACTER_H + TILE_H
end

function Character:tryMoveUp()
    if self.state == "idle" then
        self.state = "move"
        self.direction = "up"
        self.tile_y = self.tile_y - 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {y = self.y - TILE_W}})
    end
end

function Character:tryMoveDown()
    if self.state == "idle" then
        self.state = "move"
        self.direction = "down"
        self.tile_y = self.tile_y + 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {y = self.y + TILE_W}})
    end
end

function Character:tryMoveLeft()
    if self.state == "idle" then
        self.state = "move"
        self.direction = "left"
        self.tile_x = self.tile_x - 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {x = self.x - TILE_W}})
    end
end

function Character:tryMoveRight()
    if self.state == "idle" then
        self.state = "move"
        self.direction = "right"
        self.tile_x = self.tile_x + 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {x = self.x + TILE_W}})
    end
end

function Character:update(dt)
    self.sprite:setAnimation(self.state..'_'..self.direction)
    if self.tile_x * TILE_W == self.x and self.tile_y * TILE_H - CHARACTER_H + TILE_H == self.y then
        self.state = "idle"
    end
    self.sprite:update(dt)
end

function Character:draw()
    self.sprite:draw(self.x, self.y)
end
