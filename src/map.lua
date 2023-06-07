Timer = require("libs/timer")
require "src/constants"
require "src/utils"
require "src/actor_manager"

Map = {}

function Map.load(map)
    Map.tilesets = {}
    Map.tilesetQuads = {}
    Map.bgLayers = {}
    Map.fgLayer = {}
    Map.tilesetIds = {}
    Map.collision = {}
    Map.animations = {}
    Map.fgAnimationInstances = {}
    Map.bgAnimationInstances = {}
    Map.animationsEnabled = true
    ActorManager.clear()
    Map.width = map.width
    Map.height = map.height

    for tilesetId, tileset in ipairs(map.tilesets) do
        tileset = require("assets/tilesets/"..tileset.name)
        Map.tilesets[tilesetId] = assets.graphics.tilesets[tileset.name]
        Map.tilesetQuads[tilesetId] = generateQuads(Map.tilesets[tilesetId], TILE_W, TILE_H)
        Map.animations[tilesetId] = {}
        for tileId, tile in pairs(tileset.tiles) do
            local animation = {}
            animation.frames = {}
            animation.timings = {}
            for frameId, frame in pairs(tile.animation) do
                animation.frames[frameId] = frame.tileid
                animation.timings[frameId] = frame.duration / 1000
            end
            Map.animations[tilesetId][tile.id] = animation
        end
    end

    for _, layer in ipairs(map.layers) do
        if layer.type == "tilelayer" then
            if layer.name == "collision" then
                for tileId, tile in ipairs(layer.data) do
                    if tile == 0 then
                        Map.collision[tileId] = 0
                    else
                        Map.collision[tileId] = 1
                    end
                end
            elseif layer.name:sub(1, #"fg_") == "fg_" then
                Map.fgLayer[layer.id] = {}
                Map.tilesetIds[layer.id] = {}
                for tileId, tile in ipairs(layer.data) do
                    for tilesetId, tileset in ipairs(map.tilesets) do
                        if tile == 0 then
                            Map.fgLayer[layer.id][tileId] = 0
                            Map.tilesetIds[layer.id][tileId] = 0
                            break
                        elseif tile < tileset.firstgid then
                            Map.fgLayer[layer.id][tileId] = tile - map.tilesets[tilesetId - 1].firstgid
                            Map.tilesetIds[layer.id][tileId] = tilesetId - 1
                            break
                        elseif tilesetId == #map.tilesets then
                            Map.fgLayer[layer.id][tileId] = tile - map.tilesets[tilesetId].firstgid
                            Map.tilesetIds[layer.id][tileId] = tilesetId
                            break
                        end
                    end
                end
            else
                Map.bgLayers[layer.id] = {}
                Map.bgAnimationInstances[layer.id] = {}
                Map.tilesetIds[layer.id] = {}
                for tileId, tile in ipairs(layer.data) do
                    for tilesetId, tileset in ipairs(map.tilesets) do
                        if tile == 0 then
                            Map.bgLayers[layer.id][tileId] = 0
                            Map.tilesetIds[layer.id][tileId] = 0
                            break
                        elseif tile < tileset.firstgid then
                            Map.bgLayers[layer.id][tileId] = tile - map.tilesets[tilesetId - 1].firstgid
                            Map.tilesetIds[layer.id][tileId] = tilesetId - 1
                            break
                        elseif tilesetId == #map.tilesets then
                            Map.bgLayers[layer.id][tileId] = tile - map.tilesets[tilesetId].firstgid
                            Map.tilesetIds[layer.id][tileId] = tilesetId
                            break
                        end
                    end
                    local tilesetId = Map.tilesetIds[layer.id][tileId]
                    local tile = Map.bgLayers[layer.id][tileId]
                    if tilesetId ~= 0 then
                        for animId, anim in pairs(Map.animations[tilesetId]) do
                            if animId == tile then
                                Map.bgAnimationInstances[layer.id][tileId] = {
                                    frame = 1,
                                    tilesetId = tilesetId,
                                    animId = animId,
                                    timer = 0,
                                }
                            end
                        end
                    end
                end
            end
        elseif layer.type == "objectgroup" then
            for objectId, object in pairs(layer.objects) do
                local actor = assets.actors[object.name]
                local props = object.properties
                local tileX = math.floor(object.x / TILE_W)
                local tileY = math.floor(object.y / TILE_H) - 1
                ActorManager.add(Actor(actor, props, tileX, tileY))
            end
        end
    end
end

function Map:collides(x, y)
    if Map.collision[x + y * Map.width + 1] ~= 0 then
        return true
    end
    return false
end

function Map:update(dt)
    if Map.animationsEnabled then
        for layerId, layer in pairs(Map.bgAnimationInstances) do
            for tileId, instance in pairs(Map.bgAnimationInstances[layerId]) do
                instance.timer = instance.timer + dt
                local animation = Map.animations[instance.tilesetId][instance.animId]
                local timing = animation.timings[instance.frame]
                if instance.timer > timing then
                    instance.timer = 0
                    instance.frame = instance.frame + 1
                    if instance.frame > #animation.frames then
                        instance.frame = 1
                    end
                    Map.bgLayers[layerId][tileId] = animation.frames[instance.frame]
                end
            end
        end
    end
end

function Map.drawLower()
    for layerId, layer in pairs(Map.bgLayers) do
        Map.drawLayer(layerId, layer)
    end
end

function Map.drawUpper()
    for layerId, layer in pairs(Map.fgLayer) do
        Map.drawLayer(layerId, layer)
    end
end

function Map.drawLayer(layerId, layer)
    for tileId, tile in ipairs(layer) do
        if tile ~= 0 then
            local tilesetId = Map.tilesetIds[layerId][tileId]
            local texture = Map.tilesets[tilesetId]
            local quad = Map.tilesetQuads[tilesetId][tile]
            local x = (tileId - 1) % Map.width
            local y = math.floor((tileId - 1) / Map.width)
            love.graphics.draw(
                texture,
                quad,
                x * TILE_W,
                y * TILE_H
            )
        end
    end
end
