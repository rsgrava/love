require "src/constants"

function generateQuads(tex, quadWidth, quadHeight)
    local width = tex:getWidth() / quadWidth
    local height = tex:getHeight() / quadHeight
    local counter = 0
    local quads = {}

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            quads[counter] = love.graphics.newQuad(
                x * quadWidth, y * quadHeight, quadWidth, quadHeight, tex:getDimensions()
            )
            counter = counter + 1
        end
    end

    return quads
end
