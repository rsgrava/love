ActorManager = {
    actors = {}
}

function ActorManager.add(actor)
    table.insert(ActorManager.actors, actor)
end

function ActorManager.checkCollision(tile_x, tile_y)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.priority == "same" and not actor.through and
           actor.tile_x == tile_x and actor.tile_y == tile_y then
            return true
        end
    end
    return false
end

function ActorManager.tryAction(tile_x, tile_y)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.trigger == "action" and actor.tile_x == tile_x and actor.tile_y == tile_y then
            actor:tryActivate()
            break
        end
    end
end

function ActorManager.tryTouch(tile_x, tile_y)
    for actorId, actor in pairs(ActorManager.actors) do
        if actor.trigger == "player_touch" and actor.tile_x == tile_x and actor.tile_y == tile_y then
            actor:tryActivate()
            break
        end
    end
end

function ActorManager.update(dt)
    for actor_id, actor in pairs(ActorManager.actors) do
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


