Camera = require("libs/camera")
Timer = require("libs/timer")
require("src/actor")
require("src/actor_manager")
require("src/map")
require("src/party_member")
require("src/pause_menu")
require("src/screen_effects")

exploration = {}

function exploration:enter()
    self.playerActor = Actor(assets.actors.player, {}, 0, 0)
    ActorManager.add(self.playerActor)
    Party.addMember(PartyMember({
        name = "Adrian",
        image = assets.graphics.faces.Fa_Actor1,
        quad = 0,
        class = "Knight",
        level = 3,
        maxHp = 500,
        maxMp = 35,
    }))
    Party.addMember(PartyMember({
        name = "Christina",
        image = assets.graphics.faces.Fa_Actor1,
        quad = 1,
        class = "Priestess",
        level = 3,
        maxHp = 300,
        maxMp = 300,
    }))
    Party.addMember(PartyMember({
        name = "Alex",
        image = assets.graphics.faces.Fa_Actor1,
        quad = 2,
        class = "Wizard",
        level = 3,
        maxHp = 2000,
        maxMp = 4000,
    }))
    Party.addMember(PartyMember({
        name = "Sophitia",
        image = assets.graphics.faces.Fa_Actor1,
        quad = 3,
        class = "Paladin",
        level = 2,
        maxHp = 400,
        maxMp = 150,
    }))
    Party.addGold(1000)
    Map.load(assets.maps.test)
    self.camera = Camera()
    self.ignoredDir = "none"
end

function exploration:leave()
    ActorManager.clear()
end

function exploration:update(dt)
    if MenuManager.isEmpty() then
        if not ActorManager.hasAutorun() then
            if controlsEnabled then
                if Input:down("run") then
                    self.playerActor.speed = 2
                else
                    self.playerActor.speed = 1
                end

                local direction = self:getDirInput()
                if direction == "up" then
                    if self.playerActor:tryMoveUp() == "collides" then
                        ActorManager.tryTouchMid(self.playerActor.tileX, self.playerActor.tileY - 1)
                    end
                elseif direction == "down" then
                    if self.playerActor:tryMoveDown() == "collides" then
                        ActorManager.tryTouchMid(self.playerActor.tileX, self.playerActor.tileY + 1)
                    end
                elseif direction == "left" then
                    if self.playerActor:tryMoveLeft() == "collides" then
                        ActorManager.tryTouchMid(self.playerActor.tileX - 1, self.playerActor.tileY)
                    end
                elseif direction == "right" then
                    if self.playerActor:tryMoveRight() == "collides" then
                        ActorManager.tryTouchMid(self.playerActor.tileX + 1, self.playerActor.tileY)
                    end
                elseif Input:pressed("action") then
                    if self.playerActor.state == "idle" then
                        if self.playerActor.direction == "up" then
                            ActorManager.tryAction(self.playerActor.direction, self.playerActor.tileX, self.playerActor.tileY - 1)
                        elseif self.playerActor.direction == "down" then
                            ActorManager.tryAction(self.playerActor.direction, self.playerActor.tileX, self.playerActor.tileY + 1)
                        elseif self.playerActor.direction == "left" then
                            ActorManager.tryAction(self.playerActor.direction, self.playerActor.tileX - 1, self.playerActor.tileY)
                        elseif self.playerActor.direction == "right" then
                            ActorManager.tryAction(self.playerActor.direction, self.playerActor.tileX + 1, self.playerActor.tileY)
                        end
                    end
                elseif Input:pressed("menu") then
                    MenuManager.push(PauseMenu())
                end
            end
            ActorManager.update(dt)
        end
    else
        MenuManager.update(dt)
    end

    Timer.update(dt)
    Map:update(dt)
    ScreenEffects.update(dt)
    self:centerCamera()
end

function exploration:draw()
    self.camera:attach()
        Map:drawLower()
        ActorManager.draw()
        Map:drawUpper()
    self.camera:detach()
    MenuManager.draw()
    ScreenEffects.draw()
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
        if self.playerActor.direction == "up" or self.playerActor.direction == "down" then -- turning (y axis)
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
        elseif self.playerActor.direction == "left" or self.playerActor.direction == "right" then -- turning (x axis)
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
    local camX = self.playerActor.x + (TILE_W - GAME_W) / 2
    local camY = self.playerActor.y + (TILE_H - GAME_H) / 2
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
