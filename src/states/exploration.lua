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
                    ActorManager.tryTouchMid(self.player.tileX, self.player.tileY - 1)
                end
            elseif direction == "down" then
                if self.player:tryMoveDown() == "collides" then
                    ActorManager.tryTouchMid(self.player.tileX, self.player.tileY + 1)
                end
            elseif direction == "left" then
                if self.player:tryMoveLeft() == "collides" then
                    ActorManager.tryTouchMid(self.player.tileX - 1, self.player.tileY)
                end
            elseif direction == "right" then
                if self.player:tryMoveRight() == "collides" then
                    ActorManager.tryTouchMid(self.player.tileX + 1, self.player.tileY)
                end
            elseif Input:pressed("action") then
                if self.player.state == "idle" then
                    if self.player.direction == "up" then
                        ActorManager.tryAction(self.player.direction, self.player.tileX, self.player.tileY - 1)
                    elseif self.player.direction == "down" then
                        ActorManager.tryAction(self.player.direction, self.player.tileX, self.player.tileY + 1)
                    elseif self.player.direction == "left" then
                        ActorManager.tryAction(self.player.direction, self.player.tileX - 1, self.player.tileY)
                    elseif self.player.direction == "right" then
                        ActorManager.tryAction(self.player.direction, self.player.tileX + 1, self.player.tileY)
                    end
                end
            elseif Input:pressed("menu") then
                MenuManager.push(SelectionBox:init({
                    x = 0,
                    y = 0,
                    rows = 8,
                    cols = 1,
                    width = 7,
                    moveSound = assets.audio.move_cursor,
                    confirmSound = assets.audio.confirm,
                    cancelSound = assets.audio.cancel,
                    disabledSound = assets.audio.disabled,
                    items = {
                        {
                            name = "Item",
                            enabled = false
                        },
                        {
                            name = "Skill",
                            enabled = false
                        },
                        {
                            name = "Equip",
                            enabled = false
                        },
                        {
                            name = "Status",
                            enabled = false
                        },
                        {
                            name = "Formation",
                            enabled = false
                        },
                        {
                            name = "Options",
                            enabled = false
                        },
                        {
                            name = "Save",
                            enabled = false
                        },
                        {
                            name = "Quit",
                            onConfirm = love.event.quit,
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
    local dirX = "none"
    local dirY = "none"

    local heldUp = Input:down("up")
    local heldDown = Input:down("down")
    local heldLeft = Input:down("left")
    local heldRight = Input:down("right")

    if heldUp and not heldDown then
        dirY = "up"
    elseif heldDown and not heldUp then
        dirY = "down"
    end

    if heldLeft and not heldRight then
        dirX = "left"
    elseif heldRight and not heldLeft then
        dirX = "right"
    end

    if dirX ~= "none" and dirY ~= "none" then
        if self.player.direction == "up" or self.player.direction == "down" then -- turning (y axis)
            if self.ignoredDir ~= "none" then
                if dirX == self.ignoredDir then
                    dir = dirY
                else
                    dir = dirX
                end
            else
                self.ignoredDir = dirY
                dir = dirX
            end
        elseif self.player.direction == "left" or self.player.direction == "right" then -- turning (x axis)
            if self.ignoredDir ~= "none" then
                if dirY == self.ignoredDir then
                    dir = dirX
                else
                    dir = dirY
                end
            else
                self.ignoredDir = dirX
                dir = dirY
            end
        end
    elseif dirX == "none" and dirY ~= "none" then -- straight line (y axis)
        dir = dirY
    elseif dirX ~= "none" and dirY == "none" then -- straight line (x axis)
        dir = dirX
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
    local camX = self.player.x + (TILE_W - GAME_W) / 2
    local camY = self.player.y + (TILE_H - GAME_H) / 2
    local mapWidth = Map.width * TILE_W
    local mapHeight = Map.height * TILE_W

    if camX < 0 then
        camX = 0
    end
    if camX + GAME_W > mapWidth then
        if mapWidth < GAME_W then
            camX = (mapWidth - GAME_W) / 2
        else
            camX = mapWidth - GAME_W
        end
    end

    if camY < 0 then
        camY = 0
    end
    if camY + GAME_H > mapHeight then
        if mapHeight < GAME_H then
            camY = (mapHeight - GAME_H) / 2
        else
            camY = mapHeight - GAME_H
        end
    end

    self.camera:lookAt(math.floor(camX + love.graphics.getWidth() / 2), math.floor(camY + love.graphics.getHeight() / 2))
end
