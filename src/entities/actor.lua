Class = require("libs/class")
require("src/constants")
require("src/sprite")

Actor = Class{}

function Actor:init(actor, props, tile_x, tile_y)
    -- General definitions
    self.name = actor.name
    self.trigger = actor.trigger
    self.script = actor.script or nil
    self.condition = actor.condition or nil
    self.props = props
    self.active = false
    self.routine = nil

    -- Sprite definitions
    if actor.texture ~= nil then
        self.sprite = Sprite({
                texture = actor.texture,
                animation = actor.animation,
                firstAnim = actor.firstAnim,
                width = actor.width,
                height = actor.height,
            })
    else
        self.sprite = nil
    end

    -- Options
    self.priority = actor.priority or "same"
    self.animated = actor.animated or "fixed"
    self.directionFix = actor.directionFix or false
    self.through = actor.through or false

    -- Movement
    self.movType = actor.movType or "fixed"
    self.speed = actor.speed or 3
    self.freq = actor.freq or 3
    
    -- Positioning
    self.state = "idle"
    self.direction = "down"
    self.tile_x = tile_x
    self.tile_y = tile_y
    self.x = self.tile_x * TILE_W - actor.width + TILE_W
    self.y = self.tile_y * TILE_H - actor.height + TILE_H
end

function Actor:checkCondition()
    if self.condition == nil then
        return true
    else
        return self.condition()
    end
end

function Actor:tryActivate()
    self.active = self:checkCondition()
end

function Actor:tryMoveUp(map)
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

function Actor:tryMoveDown(map)
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

function Actor:tryMoveLeft(map)
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

function Actor:tryMoveRight(map)
    if self.state ~= "idle" then
        return
    end
    self.direction = "right"
    if not self:collides(map) then
        print("PENIS")
        self.state = "move"
        self.tile_x = self.tile_x + 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {x = self.x + TILE_W}})
    end
end

function Actor:collides(map)
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

    return ActorManager.checkCollision(target_x, target_y)
end

function Actor:update(dt)
    self.sprite:setAnimation(self.state..'_'..self.direction)
    if self.tile_x * TILE_W == self.x and self.tile_y * TILE_H - CHARACTER_H + TILE_H == self.y then
        self.state = "idle"
    end
    self.sprite:update(dt)

    if self.active then
        if self.script ~= nil then
            if self.routine == nil then
                self.routine = coroutine.create(self.script)
            end
            coroutine.resume(self.routine, self)
            if coroutine.status(self.routine) == "dead" then
                self.active = false
                self.routine = nil
            end
        end
    end
end

function Actor:draw()
    if self.sprite ~= nil then
        self.sprite:draw(self.x, self.y)
    end
end
