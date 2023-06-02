require("src/utils")

Window = Class{}

function Window:init(defs)
    self.x = defs.x
    self.y = defs.y
    self.width = defs.width
    self.height = defs.height
    self.tex = defs.tex
    self.quads = generateQuads(self.tex, TILE_W, TILE_H)
end

function Window:setPos(x, y)
    self.x = x
    self.y = y
end

function Window:draw()
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local quad = 4
            if x == 0 and y == 0 then
                quad = 0
            elseif x == self.width - 1 and y == 0 then
                quad = 2
            elseif y == 0 then
                quad = 1
            elseif y == self.height - 1 and x == 0 then
                quad = 6
            elseif y == self.height - 1 and x == self.width - 1 then
                quad = 8
            elseif x == 0 then
                quad = 3
            elseif x == self.width - 1 then
                quad = 5
            elseif y == self.height - 1 then
                quad = 7
            end
            love.graphics.draw(self.tex, self.quads[quad], self.x + x * TILE_W, self.y + y * TILE_H)
        end
    end
end
