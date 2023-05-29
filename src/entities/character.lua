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

function Character:tryMoveUp(map)
    if self.state ~= "idle" then
        return
    end
    self.direction = "up"
    if not self:collides(map) then
        self.state = "move"
        self.tile_y = self.tile_y - 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {y = self.y - TILE_W}})
    end
end

function Character:tryMoveDown(map)
    if self.state ~= "idle" then
        return
    end
    self.direction = "down"
    if not self:collides(map) then
        self.state = "move"
        self.tile_y = self.tile_y + 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {y = self.y + TILE_W}})
    end
end

function Character:tryMoveLeft(map)
    if self.state ~= "idle" then
        return
    end
    self.direction = "left"
    if not self:collides(map) then
        self.state = "move"
        self.tile_x = self.tile_x - 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {x = self.x - TILE_W}})
    end
end

function Character:tryMoveRight(map)
    if self.state ~= "idle" then
        return
    end
    self.direction = "right"
    if not self:collides(map) then
        self.state = "move"
        self.tile_x = self.tile_x + 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {x = self.x + TILE_W}})
    end
end

function Character:collides(map)
    local target_x = self.tile_x
    local target_y = self.tile_y
    
    if self.direction == "up" then
        target_y = self.tile_y - 1
    elseif self.direction == "down" then
        target_y = self.tile_y + 1
    elseif self.direction == "left" then
        target_x = self.tile_x - 1
    elseif self.direction == "right" then
        target_x = self.tile_x + 1
    end

    if target_x < 0 or target_y < 0 or
       target_x > map.width - 1 or target_y > map.height
       or map:collides(target_x, target_y) then
       return true
   end

   return false
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
