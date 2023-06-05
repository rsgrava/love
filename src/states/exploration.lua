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

function exploration:leave()
    ActorManager.clear()
end

function exploration:update(dt)
    if not ActorManager.hasAutorun() then
        if MenuManager.isEmpty() then
            if Input:down("run") then
                self.player.speed = 2
            else
                self.player.speed = 1
            end

            local direction = self:getDirInput()
            if direction == "up" then
                if self.player:tryMoveUp() == "collides" then
                    ActorManager.tryTouchMid(self.player.tile_x, self.player.tile_y - 1)
                end
            elseif direction == "down" then
                if self.player:tryMoveDown() == "collides" then
                    ActorManager.tryTouchMid(self.player.tile_x, self.player.tile_y + 1)
                end
            elseif direction == "left" then
                if self.player:tryMoveLeft() == "collides" then
                    ActorManager.tryTouchMid(self.player.tile_x - 1, self.player.tile_y)
                end
            elseif direction == "right" then
                if self.player:tryMoveRight() == "collides" then
                    ActorManager.tryTouchMid(self.player.tile_x + 1, self.player.tile_y)
                end
            elseif Input:pressed("action") then
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
            elseif Input:pressed("menu") then
                MenuManager.push(SelectionBox:init({
                    x = 0,
                    y = 0,
                    rows = 3,
                    cols = 1,
                    window_tex = assets.graphics.system.window.window01,
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
                }))
            end
            ActorManager.update(dt)
        else
            MenuManager.update(dt)
        end
    end

    Timer.update(dt)
    Map:update(dt)
    self:centerCamera()
end

function exploration:draw()
    self.camera:attach()
        Map:drawLower()
        ActorManager.draw()
        Map:drawUpper()
    self.camera:detach()
    MenuManager.draw()
end

function exploration:getDirInput()
    local dir = "none"
    local dir_x = "none"
    local dir_y = "none"

    local held_up = Input:down("up")
    local held_down = Input:down("down")
    local held_left = Input:down("left")
    local held_right = Input:down("right")

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

    if self.ignoredDir == "up" and Input:released("up") then
        self.ignoredDir = "none"
    elseif self.ignoredDir == "down" and Input:released("down") then
        self.ignoredDir = "none"
    elseif self.ignoredDir == "left" and Input:released("left") then
        self.ignoredDir = "none"
    elseif self.ignoredDir == "right" and Input:released("right") then
        self.ignoredDir = "none"
    end

    return dir
end

function exploration:centerCamera()
    local cam_x = self.player.x + (TILE_W - GAME_W) / 2
    local cam_y = self.player.y + (TILE_H - GAME_H) / 2
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

    self.camera:lookAt(math.floor(cam_x + love.graphics.getWidth() / 2), math.floor(cam_y + love.graphics.getHeight() / 2))
end
