ActorManager = {
    actors = {},
    autorun = false,
}

function ActorManager.add(actor)
    table.insert(ActorManager.actors, actor)
end

function ActorManager.delete(actor)
    local index = 0
    for actorId, searchActor in pairs(ActorManager.actors) do
        if actor == searchActor then
            index = actorId
        end
    end
    table.remove(ActorManager.actors, index)
end

function ActorManager.clear()
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.class ~= "player" then
            ActorManager.actors[actorId] = nil
        end
    end
    ActorManager.autorun = false
end

function ActorManager.checkCollision(layer, tileX, tileY)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.priority == layer and not actor.through and
           actor.tileX == tileX and actor.tileY == tileY then
            return true
        end
    end
    return false
end

function ActorManager.getPlayer()
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.class == "player" then
            return actor
        end
    end
end

function ActorManager.hasAutorun()
    return ActorManager.autorun
end

function ActorManager.setAutorun(state)
    ActorManager.autorun = state
end

function ActorManager.tryAction(playerDirection, tileX, tileY)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.class == "action" and actor.tileX == tileX and actor.tileY == tileY then
            if not actor.directionFix then
                if playerDirection == "up" then
                    actor.direction = "down"
                elseif playerDirection == "down" then
                    actor.direction = "up"
                elseif playerDirection == "left" then
                    actor.direction = "right"
                elseif playerDirection == "right" then
                    actor.direction = "left"
                end
            end
            actor:tryActivate()
            break
        end
    end
end

function ActorManager.tryTouchMid(tileX, tileY)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.class == "player_touch" and actor.priority == "mid" and
           actor.tileX == tileX and actor.tileY == tileY then
            actor:tryActivate()
            break
        end
    end
end

function ActorManager.tryTouchLowHigh(tileX, tileY)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.class == "player_touch" and 
           (actor.priority == "low" or actor.priority == "high") and
           actor.tileX == tileX and actor.tileY == tileY - 1 then
            actor:tryActivate()
            break
        end
    end
end

function ActorManager.tryEventTouch(actor, tileX, tileY)
    local player = ActorManager.getPlayer()
    if player.tileX == tileX and player.tileY == tileY then
        actor:tryActivate()
    end
end

function ActorManager.update(dt)
    for actorId, actor in pairs(ActorManager.actors) do
        actor:update(dt)
    end
end

function ActorManager.draw()
    table.sort(ActorManager.actors, function(a, b) return a.y < b.y end)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.priority == "low" then
            actor:draw()
        end
    end
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.priority == "mid" then
            actor:draw()
        end
    end
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.priority == "high" then
            actor:draw()
        end
    end
end


