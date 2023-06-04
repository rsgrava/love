Class = require("libs/class")
require("src/constants")
require("src/sprite")
require("src/map")

Actor = Class{}

function Actor:init(actor, props, tile_x, tile_y)
    -- General definitions
    self.name = actor.name
    self.class = actor.class or nil
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
    self.moveRoute = actor.moveRoute or {}
    self.repeatRoute = actor.repeatRoute or false
    self.routeStep = 1
    self.routeFinished = false
    self.speed = actor.speed or 1
    self.freq = actor.freq or 1
    self.moveTimer = 0
    
    -- Positioning
    self.tile_x = tile_x
    self.tile_y = tile_y
    self.x = self.tile_x * TILE_W - (actor.width or 0) + TILE_W
    self.y = self.tile_y * TILE_H - (actor.height or 0) + TILE_H
end

function Actor:checkCondition()
    if self.condition == nil then
        return true
    else
        return self.condition()
    end
end

function Actor:collides(target_x, target_y)
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

function Actor:isMoving()
    return self.state == "move"
end

function Actor:delete()
    ActorManager.delete(self)
end

function Actor:tryActivate()
    if not ActorManager.hasAutorun() and self.script ~= nil then
        self.active = self:checkCondition()
        if self.active and self.class == "autorun" then
            ActorManager.setAutorun(true)
        end
    end
end

function Actor:tryMoveUp()
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "up"
        end
        local target_y = self.tile_y - 1
        if self:collides(self.tile_x, target_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_y = target_y
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
        local target_y = self.tile_y + 1
        if self:collides(self.tile_x, target_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_y = target_y
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
        local target_x = self.tile_x - 1
        if self:collides(target_x, self.tile_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_x = target_x
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
        local target_x = self.tile_x + 1
        if self:collides(target_x, self.tile_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_x = target_x
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {x = self.x + TILE_W}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveUpLeft()
    if self.state == "idle" then
        if not self.directionFix then
            if self.direction == "up" or self.direction == "down" then
                self.direction = "up"
            elseif self.direction == "left" or self.direction == "right" then
                self.direction = "left"
            end
        end
        local target_x = self.tile_x - 1
        local target_y = self.tile_y - 1
        if self:collides(target_x, target_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_x = target_x
            self.tile_y = target_y
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {x = self.x - TILE_W, y = self.y - TILE_H}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveUpRight()
    if self.state == "idle" then
        if not self.directionFix then
            if self.direction == "up" or self.direction == "down" then
                self.direction = "up"
            elseif self.direction == "left" or self.direction == "right" then
                self.direction = "right"
            end
        end
        local target_x = self.tile_x + 1
        local target_y = self.tile_y - 1
        if self:collides(target_x, target_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_x = target_x
            self.tile_y = target_y
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {x = self.x + TILE_W, y = self.y - TILE_H}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveDownLeft()
    if self.state == "idle" then
        if not self.directionFix then
            if self.direction == "up" or self.direction == "down" then
                self.direction = "down"
            elseif self.direction == "left" or self.direction == "right" then
                self.direction = "left"
            end
        end
        local target_x = self.tile_x - 1
        local target_y = self.tile_y + 1
        if self:collides(target_x, target_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_x = target_x
            self.tile_y = target_y
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {x = self.x - TILE_W, y = self.y + TILE_H}})
            return "moved"
        end
    end
    return "busy"
end

function Actor:tryMoveDownRight()
    if self.state == "idle" then
        if not self.directionFix then
            if self.direction == "up" or self.direction == "down" then
                self.direction = "down"
            elseif self.direction == "left" or self.direction == "right" then
                self.direction = "right"
            end
        end
        local target_x = self.tile_x + 1
        local target_y = self.tile_y + 1
        if self:collides(target_x, target_y) then
            return "collides"
        else
            self.state = "move"
            if self.animated ~= "fixed" and self.sprite ~= nil then
                self.sprite:resume()
            end
            self.tile_x = target_x
            self.tile_y = target_y
            Timer.tween(ACTOR_MOVE_DURATION / self.speed, {[self] = {x = self.x + TILE_W, y = self.y + TILE_H}})
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

function Actor:teleport(tile_x, tile_y)
    self.tile_x = tile_x
    self.tile_y = tile_y
    self.x = tile_x * TILE_W
    self.y = tile_y * TILE_H - CHARACTER_H + TILE_H
end

function Actor:tryFaceUp()
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "up"
        end
        return "moved"
    end
    return "busy"
end

function Actor:tryFaceDown()
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "down"
        end
        return "moved"
    end
    return "busy"
end

function Actor:tryFaceLeft()
    if self.state == "idle" then
        if not self.directionFix then
            self.direction = "left"
        end
        return "moved"
    end
    return "busy"
end

function Actor:tryFaceRight()
    if self.state == "idle" and not self.directionFix then
        if not self.directionFix then
            self.direction = "right"
        end
        return "moved"
    end
    return "busy"
end

function Actor:tryTurn90Left()
    if self.direction == "up" then
        return self:tryFaceLeft()
    elseif self.direction == "down" then
        return self:tryFaceRight()
    elseif self.direction == "left" then
        return self:tryFaceDown()
    elseif self.direction == "right" then
        return self:tryFaceUp()
    end
end

function Actor:tryTurn90Right()
    if self.direction == "up" then
        return self:tryFaceRight()
    elseif self.direction == "down" then
        return self:tryFaceLeft()
    elseif self.direction == "left" then
        return self:tryFaceUp()
    elseif self.direction == "right" then
        return self:tryFaceDown()
    end
end

function Actor:tryTurn180()
    if self.direction == "up" then
        return self:tryFaceDown()
    elseif self.direction == "down" then
        return self:tryFaceUp()
    elseif self.direction == "left" then
        return self:tryFaceRight()
    elseif self.direction == "right" then
        return self:tryFaceLeft()
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

function Actor:moveCustom()
    if self.routeFinished then
        return "moved"
    end

    local action = self.moveRoute[self.routeStep]
    local moved = ""
    
    if action == "up" then
        moved = self:tryMoveUp()
    elseif action == "down" then
        moved = self:tryMoveDown()
    elseif action == "left" then
        moved = self:tryMoveLeft()
    elseif action == "right" then
        moved = self:tryMoveRight()
    elseif action == "up_left" then
        moved = self:tryMoveUpLeft()
    elseif action == "up_right" then
        moved = self:tryMoveUpRight()
    elseif action == "down_left" then
        moved = self:tryMoveDownLeft()
    elseif action == "down_right" then
        moved = self:tryMoveDownRight()
    elseif action == "move_random" then
        moved = self:tryMoveRandom()
    elseif action == "move_to_player" then
        -- TODO
    elseif action == "move_away_from_player" then
        -- TODO
    elseif action == "forward" then
        moved = self:tryMoveForward()
    elseif action == "backward" then
        moved = self:tryMoveBackward()
    elseif action == "jump" then
        -- TODO
    elseif action == "wait" then
        moved = "moved"
    elseif action == "face_up" then
        moved = self:tryFaceUp()
    elseif action == "face_down" then
        moved = self:tryFaceDown()
    elseif action == "face_left" then
        moved = self:tryFaceLeft()
    elseif action == "face_right" then
        moved = self:tryFaceRight()
    elseif action == "turn90left" then
        moved = self:tryTurn90Left()
    elseif action == "turn90right" then
        moved = self:tryTurn90Right()
    elseif action == "turn180" then
        moved = self:tryTurn180()
    elseif action == "face_random" then
        moved = self:tryFaceRandom()
    elseif action == "face_player" then
        -- TODO
    elseif action == "face_away_from_player" then
        -- TODO
    elseif action == "change_speed" then
        self.routeStep = self.routeStep + 1
        self.speed = self.moveRoute[self.routeStep]
        moved = "moved"
    elseif action == "change_freq" then
        self.routeStep = self.routeStep + 1
        self.freq = self.moveRoute[self.routeStep]
        moved = "moved"
    elseif action == "set_animated" then
        self.routeStep = self.routeStep + 1
        self.animated = self.moveRoute[self.routeStep]
        moved = "moved"
    elseif action == "set_direction_fix" then
        self.routeStep = self.routeStep + 1
        self.directionFix = self.moveRoute[self.routeStep]
        moved = "moved"
    elseif action == "set_through" then
        self.routeStep = self.routeStep + 1
        self.through = self.moveRoute[self.routeStep]
        moved = "moved"
    end

    if moved == "moved" then
        self.routeStep = self.routeStep + 1
        if self.routeStep > #self.moveRoute then
            if self.repeatRoute then
                self.routeStep = 1
            else
                self.routeFinished = true
            end
        end
    end
    
    return moved
end

function Actor:update(dt)
    if self.sprite ~= nil then
        self.sprite:setAnimation(self.direction)
        if self.animated ~= "always" and self.state == "idle" then
            self.sprite:pause()
        end
        self.sprite:update(dt)
    end

    if self.state ~= "idle" and self.tile_x * TILE_W == self.x
       and self.tile_y * TILE_H - self.height + TILE_H == self.y then
        self.state = "idle"
        if self.class == "player" then
            ActorManager.tryTouchLowHigh(self.tile_x, self.tile_y)
        elseif self.class == "event_touch" and 
               (self.priority == "low" or self.priority == "high") then
            ActorManager.tryEventTouch(self, self.tile_x, self.tile_y)
        end
    end

    if not self.active then
        self.moveTimer = self.moveTimer + self.freq * dt
        if self.moveTimer > ACTOR_MOVE_DELAY then
            local moved = false
            if self.moveType == "random" then
                moved = self:tryMoveRandom()
            elseif self.moveType == "approach" then
                moved = self:tryMoveToPlayer()
            elseif self.moveType == "custom" then
                moved = self:moveCustom()
            end
            if moved ~= "busy" then
                self.moveTimer = 0
            end
            if moved == "collides" and self.class == "event_touch" then
                if self.direction == "up" then
                    ActorManager.tryEventTouch(self, self.tile_x, self.tile_y - 1)
                elseif self.direction == "down" then
                    ActorManager.tryEventTouch(self, self.tile_x, self.tile_y + 1)
                elseif self.direction == "left" then
                    ActorManager.tryEventTouch(self, self.tile_x - 1, self.tile_y)
                elseif self.direction == "right" then
                    ActorManager.tryEventTouch(self, self.tile_x + 1, self.tile_y)
                end
            end
        end

        if self.class == "autorun" then
            self:tryActivate()
        end

        if self.class == "parallel" then
            self:tryActivate()
        end
    end

    if self.active then
        if self.routine == nil then
            self.routine = coroutine.create(self.script)
        end
        local result, msg = coroutine.resume(self.routine, self, dt)
        -- debug: remove this later
        if not result then
            print(msg)
        end
        if coroutine.status(self.routine) == "dead" then
            self.active = false
            self.routine = nil
            if self.class == "autorun" then
                ActorManager.setAutorun(false)
            end
        end
    end
end

function Actor:draw()
    if self.sprite ~= nil then
        self.sprite:draw(self.x, self.y)
    end
end
