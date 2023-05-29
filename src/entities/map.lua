Class = require("libs/class")
require "src/constants"
require "src/utils"

Map = Class{}

function Map:init(map)
    self.tilesets = {}
    self.tileset_quads = {}
    self.layers = {}
    self.tileset_ids = {}
    self.collision = {}
    self.width = map.width
    self.height = map.height

    for k, tileset in ipairs(map.tilesets) do
        tileset = require("assets/tilesets/"..tileset.name)
        self.tilesets[k] = assets.graphics[tileset.name]
        self.tileset_quads[k] = generateQuads(self.tilesets[k], TILE_W, TILE_H)
    end

    for layer_id, layer in ipairs(map.layers) do
        if layer.type == "tilelayer" then
            if layer.name == "collision" then
                for tile_id, tile in ipairs(layer.data) do
                    if tile == 0 then
                        self.collision[tile_id] = 0
                    else
                        self.collision[tile_id] = 1
                    end
                end
            else
                self.layers[layer_id] = {}
                self.tileset_ids[layer_id] = {}
                for tile_id, tile in ipairs(layer.data) do
                    for tileset_id, tileset in ipairs(map.tilesets) do
                        if tile == 0 then
                            self.layers[layer_id][tile_id] = 0
                            self.tileset_ids[layer_id][tile_id] = 0
                            break
                        elseif tile < tileset.firstgid then
                            self.layers[layer_id][tile_id] = tile - map.tilesets[tileset_id - 1].firstgid
                            self.tileset_ids[layer_id][tile_id] = tileset_id - 1
                            break
                        elseif tileset_id == #map.tilesets then
                            self.layers[layer_id][tile_id] = tile - map.tilesets[tileset_id].firstgid
                            self.tileset_ids[layer_id][tile_id] = tileset_id
                            break
                        end
                    end
                end
            end
        elseif layer.type == "objects" then
        end
    end
end

function Map:collides(x, y)
    if self.collision[x + y * self.width + 1] ~= 0 then
        return true
    end
    return false
end

function Map:update(dt)
end

function Map:draw()
    for layer_id, layer in ipairs(self.layers) do
        for tile_id, tile in ipairs(layer) do
            if tile ~= 0 then
                local tileset_id = self.tileset_ids[layer_id][tile_id]
                local texture = self.tilesets[tileset_id]
                local quad = self.tileset_quads[tileset_id][tile]
                local x = (tile_id - 1) % self.width
                local y = math.floor((tile_id - 1) / self.width)
                love.graphics.draw(
                    texture,
                    quad,
                    x * TILE_W,
                    y * TILE_H
                )
            end
        end
    end
end
