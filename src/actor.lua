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
    self.width = actor.width
    self.height = actor.height
    if actor.texture ~= nil then
        self.sprite = Sprite({
                texture = actor.texture,
                animation = actor.animation,
                firstAnim = self.direction,
                width = self.width,
                height = self.height,
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
    self.moveType = actor.moveType or "fixed"
    self.speed = actor.speed or 1
    self.freq = actor.freq or 1
    self.timer = 0
    
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
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "up"
        end
        if self:collides() then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" then
                self.sprite:resume()
            end
            self.tile_y = self.tile_y - 1
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {y = self.y - TILE_W}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveDown()
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "down"
        end
        if self:collides() then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" then
                self.sprite:resume()
            end
            self.tile_y = self.tile_y + 1
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {y = self.y + TILE_W}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveLeft()
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "left"
        end
        if self:collides() then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" then
                self.sprite:resume()
            end
            self.tile_x = self.tile_x - 1
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {x = self.x - TILE_W}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveRight()
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "right"
        end
        if self:collides() then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" then
                self.sprite:resume()
            end
            self.tile_x = self.tile_x + 1
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {x = self.x + TILE_W}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveForward()
    if self.direction == "up" then
        return self:tryMoveUp()
    elseif self.direction == "down" then
        return self:tryMoveDown()
    elseif self.direction == "left" then
        return self:tryMoveLeft()
    elseif self.direction == "right" then
        return self:tryMoveRight()
    end
end

function Actor:tryMoveBackward()
    if self.direction == "up" then
        return self:tryMoveDown()
    elseif self.direction == "down" then
        return self:tryMoveUp()
    elseif self.direction == "left" then
        return self:tryMoveRight()
    elseif self.direction == "right" then
        return self:tryMoveLeft()
    end
end

function Actor:tryMoveRandom()
    if self.state == "idle" then
        local rand = math.random(1, 4)
        if rand == 1 then
            return self:tryMoveUp()
        elseif rand == 2 then
            return self:tryMoveDown()
        elseif rand == 3 then
            return self:tryMoveLeft()
        elseif rand == 4 then
            return self:tryMoveRight()
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

    if self.through then
        return false
    end
    return ActorManager.checkCollision(self.priority, target_x, target_y)
end

function Actor:update(dt)
    self.sprite:setAnimation(self.direction)
    if self.animated ~= "always" and self.state == "idle" then
        self.sprite:pause()
    end
    self.sprite:update(dt)

    if self.tile_x * TILE_W == self.x and self.tile_y * TILE_H - self.height + TILE_H == self.y then
        self.state = "idle"
    end

    self.timer = self.timer + self.freq * dt
    if self.timer > ACTOR_MOVE_DELAY then
        local moved = false
        if self.moveType == "random" then
            moved = self:tryMoveRandom()
        elseif self.moveType == "approach" then
            moved = self:tryMoveToPlayer()
        elseif self.moveType == "custom" then
        end
        if moved ~= "busy" then
            self.timer = 0
        end
    end

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
