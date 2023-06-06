require "src/constants"

function deepCopy(table)
    local newTable = {}
    for k, v in pairs(table) do
        if type(v) == "table" then
            newTable[k] = deepCopy(v);
        else
            newTable[k] = v
        end
    end
    return newTable
end

function generateQuads(tex, quadWidth, quadHeight, ox, oy)
    local ox = ox or 0
    local oy = oy or 0
    local width = (tex:getWidth() - ox) / quadWidth
    local height = (tex:getHeight() - oy) / quadHeight
    local counter = 0
    local quads = {}

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            quads[counter] = love.graphics.newQuad(
                x * quadWidth + ox, y * quadHeight + oy, quadWidth, quadHeight, tex:getDimensions()
            )
            counter = counter + 1
        end
    end

    return quads
end

function getCharacterAnimation(quad)
    local animSet = deepCopy(assets.animations.character)
    for animId, anim in pairs(animSet) do
        for frameId, frame in pairs(anim.frames) do
            local offsetX = (quad % 4) * CHARACTER_FRAMES
            local offsetY = math.floor(quad / 4) * CHARACTER_FRAMES * CHARACTERS_PER_COL
            anim.frames[frameId] = frame + offsetX + offsetY
        end
    end
    return animSet
end

controlsEnabled = true

function enableControls()
    controlsEnabled = true
end

function disableControls()
    controlsEnabled = false
end
