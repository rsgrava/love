Camera = require("libs/camera")
Timer = require("libs/timer")
require("src/actor")
require("src/actor_manager")
require("src/map")

exploration = {}

function exploration:enter()
    self.player = Actor(assets.actors.player, {}, 0, 0)
    ActorManager.add(self.player)
    Map.load(assets.maps.test)
    self.camera = Camera()
    self.ignoredDir = "none"
end

function exploration:update(dt)
    local direction = self:getDirInput()
    if direction == "up" then
        self.player:tryMoveUp()
    elseif direction == "down" then
        self.player:tryMoveDown()
    elseif direction == "left" then
        self.player:tryMoveLeft()
    elseif direction == "right" then
        self.player:tryMoveRight()
    end

    if love.keyboard.isPressed("z") then
        if self.player.state == "idle" then
            if self.player.direction == "up" then
                ActorManager.tryAction(self.player.direction, self.player.tile_x, self.player.tile_y - 1)
            elseif self.player.direction == "down" then
                ActorManager.tryAction(self.player.direction, self.player.tile_x, self.player.tile_y + 1)
            elseif self.player.direction == "left" then
                ActorManager.tryAction(self.player.direction, self.player.tile_x - 1, self.player.tile_y)
            elseif self.player.direction == "right" then
                ActorManager.tryAction(self.player.direction, self.player.tile_x + 1, self.player.tile_y)
            end
        end
    end

    Timer.update(dt)
    Map:update(dt)
    ActorManager.update(dt)
    self:centerCamera()
end

function exploration:draw()
    self.camera:attach()
        Map:drawLower()
        ActorManager.draw()
        Map:drawUpper()
    self.camera:detach()
end

function exploration:getDirInput()
    local dir = "none"
    local dir_x = "none"
    local dir_y = "none"

    local held_up = love.keyboard.isDown("up")
    local held_down = love.keyboard.isDown("down")
    local held_left = love.keyboard.isDown("left")
    local held_right = love.keyboard.isDown("right")

    if held_up and not held_down then
        dir_y = "up"
    elseif held_down and not held_up then
        dir_y = "down"
    end

    if held_left and not held_right then
        dir_x = "left"
    elseif held_right and not held_left then
        dir_x = "right"
    end

    if dir_x ~= "none" and dir_y ~= "none" then
        if self.player.direction == "up" or self.player.direction == "down" then -- turning (y axis)
            if self.ignoredDir ~= "none" then
                if dir_x == self.ignoredDir then
                    dir = dir_y
                else
                    dir = dir_x
                end
            else
                self.ignoredDir = dir_y
                dir = dir_x
            end
        elseif self.player.direction == "left" or self.player.direction == "right" then -- turning (x axis)
            if self.ignoredDir ~= "none" then
                if dir_y == self.ignoredDir then
                    dir = dir_x
                else
                    dir = dir_y
                end
            else
                self.ignoredDir = dir_x
                dir = dir_y
            end
        end
    elseif dir_x == "none" and dir_y ~= "none" then -- straight line (y axis)
        dir = dir_y
    elseif dir_x ~= "none" and dir_y == "none" then -- straight line (x axis)
        dir = dir_x
    end

    if self.ignoredDir == "up" and love.keyboard.isReleased("up") then
        self.ignoredDir = "none"
    elseif self.ignoredDir == "down" and love.keyboard.isReleased("down") then
        self.ignoredDir = "none"
    elseif self.ignoredDir == "left" and love.keyboard.isReleased("left") then
        self.ignoredDir = "none"
    elseif self.ignoredDir == "right" and love.keyboard.isReleased("right") then
        self.ignoredDir = "none"
    end


    return dir
end

function exploration:centerCamera()
    local cam_x = self.player.x + (CHARACTER_W - GAME_W) / 2
    local cam_y = self.player.y + (CHARACTER_H - GAME_H) / 2
    local map_width = Map.width * TILE_W
    local map_height = Map.height * TILE_W

    if cam_x < 0 then
        cam_x = 0
    end
    if cam_x + GAME_W > map_width then
        if map_width < GAME_W then
            cam_x = (map_width - GAME_W) / 2
        else
            cam_x = map_width - GAME_W
        end
    end

    if cam_y < 0 then
        cam_y = 0
    end
    if cam_y + GAME_H > map_height then
        if map_height < GAME_H then
            cam_y = (map_height - GAME_H) / 2
        else
            cam_y = map_height - GAME_H
        end
    end

    self.camera:lookAt(cam_x + love.graphics.getWidth() / 2, cam_y + love.graphics.getHeight() / 2)
end
