Class = require("libs/class")
require("src/constants")
require("src/sprite")
require("src/map")

Actor = Class{}

function Actor:init(actor, props, tile_x, tile_y)
    -- General definitions
    self.name = actor.name
    self.trigger = actor.trigger or nil
    self.script = actor.script or nil
    self.condition = actor.condition or nil
    self.props = props
    self.active = false
    self.routine = nil
    self.state = "idle"

    -- Sprite definitions
    self.direction = actor.direction or "down"
    if actor.texture ~= nil then
        self.sprite = Sprite({
                texture = actor.texture,
                animation = actor.animation,
                firstAnim = self.state..'_'..self.direction,
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

function Actor:tryMoveUp()
    if self.state ~= "idle" then
        return
    end
    self.direction = "up"
    if not self:collides() then
        self.state = "move"
        self.tile_y = self.tile_y - 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {y = self.y - TILE_W}})
    end
end

function Actor:tryMoveDown()
    if self.state ~= "idle" then
        return
    end
    self.direction = "down"
    if not self:collides() then
        self.state = "move"
        self.tile_y = self.tile_y + 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {y = self.y + TILE_W}})
    end
end

function Actor:tryMoveLeft()
    if self.state ~= "idle" then
        return
    end
    self.direction = "left"
    if not self:collides() then
        self.state = "move"
        self.tile_x = self.tile_x - 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {x = self.x - TILE_W}})
    end
end

function Actor:tryMoveRight()
    if self.state ~= "idle" then
        return
    end
    self.direction = "right"
    if not self:collides() then
        self.state = "move"
        self.tile_x = self.tile_x + 1
        Timer.tween(CHARACTER_MOVE_DURATION, {[self] = {x = self.x + TILE_W}})
    end
end

function Actor:tryMoveForward()
    if self.direction == "up" then
        self:tryMoveUp()
    elseif self.direction == "down" then
        self:tryMoveDown()
    elseif self.direction == "left" then
        self:tryMoveLeft()
    elseif self.direction == "right" then
        self:tryMoveRight()
    end
end

function Actor:tryMoveBackward()
    if self.direction == "up" then
        self:tryMoveDown()
    elseif self.direction == "down" then
        self:tryMoveUp()
    elseif self.direction == "left" then
        self:tryMoveRight()
    elseif self.direction == "right" then
        self:tryMoveLeft()
    end
end

function Actor:tryMoveRandom()
    if self.state == "idle" then
        local rand = math.random(1, 4)
        if rand == 1 then
            self:tryMoveUp()
        elseif rand == 2 then
            self:tryMoveDown()
        elseif rand == 3 then
            self:tryMoveLeft()
        elseif rand == 4 then
            self:tryMoveRight()
        end
    end
end

function Actor:tryMoveToPlayer()
    -- TODO
end

function Actor:tryMoveAwayFromPlayer()
    -- TODO
end

function Actor:tryJump()
    -- TODO
end

function Actor:tryFaceUp()
    if self.state == "idle" and not self.directionFix then
        self.direction = "up"
    end
end

function Actor:tryFaceDown()
    if self.state == "idle" and not self.directionFix then
        self.direction = "down"
    end
end

function Actor:tryFaceLeft()
    if self.state == "idle" and not self.directionFix then
        self.direction = "left"
    end
end

function Actor:tryFaceRight()
    if self.state == "idle" and not self.directionFix then
        self.direction = "right"
    end
end

function Actor:tryTurn90Left()
    if self.state == "idle" and not self.directionFix then
        if self.direction == "up" then
            self.direction = "left"
        elseif self.direction == "down" then
            self.direction = "right"
        elseif self.direction == "left" then
            self.direction = "down"
        elseif self.direction == "right" then
            self.direction = "up"
        end
    end
end

function Actor:tryTurn90Right()
    if self.state == "idle" and not self.directionFix then
        if self.direction == "up" then
            self.direction = "right"
        elseif self.direction == "down" then
            self.direction = "left"
        elseif self.direction == "left" then
            self.direction = "up"
        elseif self.direction == "right" then
            self.direction = "down"
        end
    end
end

function Actor:tryTurn180()
    if self.state == "idle" and not self.directionFix then
        if self.direction == "up" then
            self.direction = "down"
        elseif self.direction == "down" then
            self.direction = "up"
        elseif self.direction == "left" then
            self.direction = "right"
        elseif self.direction == "right" then
            self.direction = "left"
        end
    end
end

function Actor:tryFaceRandom()
    if self.state == "idle" then
        local rand = math.random(1, 4)
        if rand == 1 then
            self:tryFaceUp()
        elseif rand == 2 then
            self:tryFaceDown()
        elseif rand == 3 then
            self:tryFaceLeft()
        elseif rand == 4 then
            self:tryFaceRight()
        end
    end
end

function Actor:tryFacePlayer()
    -- TODO
end

function Actor:tryFaceAwayFromPlayer()
    -- TODO
end


function Actor:collides()
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
       target_x > Map.width - 1 or target_y > Map.height
       or Map:collides(target_x, target_y) then
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
