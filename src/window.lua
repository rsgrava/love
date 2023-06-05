require("src/utils")

Window = Class{}

function Window:init(defs)
    self.x = defs.x
    self.y = defs.y
    self.width = defs.width
    self.height = defs.height
    self.quads = generateQuads(windowTex, TILE_W / 2, TILE_H / 2)
end

function Window:setPos(x, y)
    self.x = x
    self.y = y
end

function Window:draw()
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            -- middle
            local cornerQuad = nil
            if x == 0 and y == 0 then
                -- top left
                cornerQuad = 4
            elseif x == self.width - 1 and y == 0 then
                -- top right
                cornerQuad = 7
            elseif y == 0 then
                -- top middle
                cornerQuad = 5
            elseif y == self.height - 1 and x == 0 then
                -- bottom left
                cornerQuad = 28
            elseif y == self.height - 1 and x == self.width - 1 then
                -- bottom right
                cornerQuad = 31
            elseif x == 0 then
                -- left middle
                cornerQuad = 12
            elseif x == self.width - 1 then
                -- right middle
                cornerQuad = 15
            elseif y == self.height - 1 then
                -- bottom middle
                cornerQuad = 29
            end
            
            love.graphics.draw(windowTex, self.quads[0], self.x + x * TILE_W, self.y + y * TILE_H, 0, 2, 2)
            if cornerQuad ~= nil then
                love.graphics.draw(windowTex, self.quads[cornerQuad], self.x + x * TILE_W, self.y + y * TILE_H, 0, 2, 2)
            end
        end
    end
end
