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

function getCharacterAnimation(quad)
    local animSet = assets.animations.character
    for animId, anim in pairs(animSet) do
        for frameId, frame in pairs(anim.frames) do
            local offsetX = (quad % 4) * CHARACTER_FRAMES
            local offsetY = math.floor(quad / 4) * CHARACTER_FRAMES * CHARACTERS_PER_COL
            anim.frames[frameId] = frame + offsetX + offsetY
        end
    end
    return animSet
end
