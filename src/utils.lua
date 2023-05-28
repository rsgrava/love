require "src/constants"

function generateQuads(tex)
    local width = tex:getWidth() / TILE_W
    local height = tex:getHeight() / TILE_H
    local counter = 0
    local quads = {}

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            quads[counter] = love.graphics.newQuad(
                x * TILE_W, y * TILE_H, TILE_W, TILE_H, tex:getDimensions()
            )
            counter = counter + 1
        end
    end

    return quads
end
