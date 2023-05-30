Camera = require("libs/camera")
Timer = require("libs/timer")
require("src/entities/character")
require("src/entities/map")

exploration = {}

function exploration:enter()
    self.player = Character(
        {
            texture = assets.graphics.player,
            animation = assets.animations.player,
            tile_x = 0,
            tile_y = 0
        }
    )
    self.map = Map(assets.maps.big)
    self.camera = Camera()
    self.ignoredDir = "none"
end

function exploration:update(dt)
    local direction = self:getDirInput()
    if direction == "up" then
        self.player:tryMoveUp(self.map)
    elseif direction == "down" then
        self.player:tryMoveDown(self.map)
    elseif direction == "left" then
        self.player:tryMoveLeft(self.map)
    elseif direction == "right" then
        self.player:tryMoveRight(self.map)
    end
    Timer.update(dt)
    self.map:update(dt)
    self.player:update(dt)
    self:centerCamera()
end

function exploration:draw()
    self.camera:attach()
        self.map:drawLower()
        self.player:draw()
        self.map:drawUpper()
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
    local map_width = self.map.width * TILE_W
    local map_height = self.map.height * TILE_W

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

    self.camera:lookAt(cam_x + CAMERA_OFFSET_X, cam_y + CAMERA_OFFSET_Y)
end
