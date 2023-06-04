require("src/utils")

Window = Class{}

function Window:init(defs)
    self.x = defs.x
    self.y = defs.y
    self.width = defs.width
    self.height = defs.height
    self.tex = defs.tex
    self.quads = generateQuads(self.tex, TILE_W / 2, TILE_H / 2)
end

function Window:setPos(x, y)
    self.x = x
    self.y = y
end

function Window:draw()
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            -- middle
            local corner_quad = nil
            if x == 0 and y == 0 then
                -- top left
                corner_quad = 4
            elseif x == self.width - 1 and y == 0 then
                -- top right
                corner_quad = 7
            elseif y == 0 then
                -- top middle
                corner_quad = 5
            elseif y == self.height - 1 and x == 0 then
                -- bottom left
                corner_quad = 28
            elseif y == self.height - 1 and x == self.width - 1 then
                -- bottom right
                corner_quad = 31
            elseif x == 0 then
                -- left middle
                corner_quad = 12
            elseif x == self.width - 1 then
                -- right middle
                corner_quad = 15
            elseif y == self.height - 1 then
                -- bottom middle
                corner_quad = 29
            end
            
            love.graphics.draw(self.tex, self.quads[0], self.x + x * TILE_W, self.y + y * TILE_H, 0, 2, 2)
            if corner_quad ~= nil then
                love.graphics.draw(self.tex, self.quads[corner_quad], self.x + x * TILE_W, self.y + y * TILE_H, 0, 2, 2)
            end
        end
    end
end
