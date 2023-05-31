Timer = require("libs/timer")
require "src/constants"
require "src/utils"
require "src/entities/actor_manager"

Map = {}

function Map.load(map)
    Map.tilesets = {}
    Map.tileset_quads = {}
    Map.bg_layers = {}
    Map.fg_layers = {}
    Map.tileset_ids = {}
    Map.collision = {}
    Map.animations = {}
    Map.fg_animation_instances = {}
    Map.bg_animation_instances = {}
    Map.animations_enabled = true
    Map.width = map.width
    Map.height = map.height

    for tileset_id, tileset in ipairs(map.tilesets) do
        tileset = require("assets/tilesets/"..tileset.name)
        Map.tilesets[tileset_id] = assets.graphics[tileset.name]
        Map.tileset_quads[tileset_id] = generateQuads(Map.tilesets[tileset_id], TILE_W, TILE_H)
        Map.animations[tileset_id] = {}
        for tile_id, tile in pairs(tileset.tiles) do
            local animation = {}
            animation.frames = {}
            animation.timings = {}
            for frame_id, frame in pairs(tile.animation) do
                animation.frames[frame_id] = frame.tileid
                animation.timings[frame_id] = frame.duration / 1000
            end
            Map.animations[tileset_id][tile.id] = animation
        end
    end

    for _, layer in ipairs(map.layers) do
        if layer.type == "tilelayer" then
            if layer.name == "collision" then
                for tile_id, tile in ipairs(layer.data) do
                    if tile == 0 then
                        Map.collision[tile_id] = 0
                    else
                        Map.collision[tile_id] = 1
                    end
                end
            elseif layer.name:sub(1, #"fg_") == "fg_" then
                Map.fg_layers[layer.id] = {}
                Map.tileset_ids[layer.id] = {}
                for tile_id, tile in ipairs(layer.data) do
                    for tileset_id, tileset in ipairs(map.tilesets) do
                        if tile == 0 then
                            Map.fg_layers[layer.id][tile_id] = 0
                            Map.tileset_ids[layer.id][tile_id] = 0
                            break
                        elseif tile < tileset.firstgid then
                            Map.fg_layers[layer.id][tile_id] = tile - map.tilesets[tileset_id - 1].firstgid
                            Map.tileset_ids[layer.id][tile_id] = tileset_id - 1
                            break
                        elseif tileset_id == #map.tilesets then
                            Map.fg_layers[layer.id][tile_id] = tile - map.tilesets[tileset_id].firstgid
                            Map.tileset_ids[layer.id][tile_id] = tileset_id
                            break
                        end
                    end
                end
            else
                Map.bg_layers[layer.id] = {}
                Map.bg_animation_instances[layer.id] = {}
                Map.tileset_ids[layer.id] = {}
                for tile_id, tile in ipairs(layer.data) do
                    for tileset_id, tileset in ipairs(map.tilesets) do
                        if tile == 0 then
                            Map.bg_layers[layer.id][tile_id] = 0
                            Map.tileset_ids[layer.id][tile_id] = 0
                            break
                        elseif tile < tileset.firstgid then
                            Map.bg_layers[layer.id][tile_id] = tile - map.tilesets[tileset_id - 1].firstgid
                            Map.tileset_ids[layer.id][tile_id] = tileset_id - 1
                            break
                        elseif tileset_id == #map.tilesets then
                            Map.bg_layers[layer.id][tile_id] = tile - map.tilesets[tileset_id].firstgid
                            Map.tileset_ids[layer.id][tile_id] = tileset_id
                            break
                        end
                    end
                    local tileset_id = Map.tileset_ids[layer.id][tile_id]
                    local tile = Map.bg_layers[layer.id][tile_id]
                    if tileset_id ~= 0 then
                        for anim_id, anim in pairs(Map.animations[tileset_id]) do
                            if anim_id == tile then
                                Map.bg_animation_instances[layer.id][tile_id] = {
                                    frame = 1,
                                    tileset_id = tileset_id,
                                    anim_id = anim_id,
                                    timer = 0,
                                }
                            end
                        end
                    end
                end
            end
        elseif layer.type == "objectgroup" then
            for object_id, object in pairs(layer.objects) do
                local actor = assets.actors[object.name]
                local props = object.properties
                local tile_x = math.floor(object.x / TILE_W)
                local tile_y = math.floor(object.y / TILE_H) - 1
                ActorManager.add(Actor(actor, props, tile_x, tile_y))
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
    if Map.animations_enabled then
        for layer_id, layer in pairs(Map.bg_animation_instances) do
            for tile_id, instance in pairs(Map.bg_animation_instances[layer_id]) do
                instance.timer = instance.timer + dt
                local animation = Map.animations[instance.tileset_id][instance.anim_id]
                local timing = animation.timings[instance.frame]
                if instance.timer > timing then
                    instance.timer = 0
                    instance.frame = instance.frame + 1
                    if instance.frame > #animation.frames then
                        instance.frame = 1
                    end
                    Map.bg_layers[layer_id][tile_id] = animation.frames[instance.frame]
                end
            end
        end
    end
end

function Map.drawLower()
    for layer_id, layer in pairs(Map.bg_layers) do
        Map.drawLayer(layer_id, layer)
    end
end

function Map.drawUpper()
    for layer_id, layer in pairs(Map.fg_layers) do
        Map.drawLayer(layer_id, layer)
    end
end

function Map.drawLayer(layer_id, layer)
    for tile_id, tile in ipairs(layer) do
        if tile ~= 0 then
            local tileset_id = Map.tileset_ids[layer_id][tile_id]
            local texture = Map.tilesets[tileset_id]
            local quad = Map.tileset_quads[tileset_id][tile]
            local x = (tile_id - 1) % Map.width
            local y = math.floor((tile_id - 1) / Map.width)
            love.graphics.draw(
                texture,
                quad,
                x * TILE_W,
                y * TILE_H
            )
        end
    end
end
