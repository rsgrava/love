require("libs/class")

PartyMember = Class{}

function PartyMember:init(defs)
    self.name = defs.name
    self.portrait = {
        image = defs.image,
        quad = defs.quad,
        quads = generateQuads(defs.image, PORTRAIT_W, PORTRAIT_H)
    }

    self.class = defs.class
    self.level = defs.level
    self.hp = defs.maxHp
    self.mp = defs.maxMp
    self.maxHp = defs.maxHp
    self.maxMp = defs.maxMp
end

function PartyMember:draw(x, y)
    love.graphics.draw(self.portrait.image, self.portrait.quads[self.portrait.quad], x, y)
end
