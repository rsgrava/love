Class = require("libs/class")

Character = Class{}

function Character:init(defs)
    self.name = defs.name
    self.portrait = defs.portrait
    self.portrait.quads = generateQuads(self.portrait.image, PORTRAIT_W, PORTRAIT_H)

    self.class = database.classes[defs.class]
    self.level = defs.level
    self.stats = calcStartingStats(self.class, self.level)
    self.hp = self.stats.maxHp
    self.mp = self.stats.maxMp
    self.xp = xpToLevel(self.level)

    if defs.equipment == nil then
        self.equipment = {
            weapon = nil,
            secondary = nil,
            helmet = nil,
            armor = nil,
            accessory = nil,
        }
    else
        self.equipment = defs.equipment
    end
end

-- General

function Character:drawPortrait(x, y)
    love.graphics.draw(self.portrait.image, self.portrait.quads[self.portrait.quad], x, y)
end

-- Stats & Levelling
function Character:getModStat(stat)

end

function Character:levelUp()
    self.level = self.level + 1
    for statId, stat in pairs(self.stats) do
        self.stats[statId] = stat + self.class.statGrowth[statId]
    end
end

function xpToLevel(level)
    if level > MAX_LEVEL then
        return nil
    end

    return math.floor(1000 * (level ^ 1.5))
end

function calcStartingStats(class, level)
    local stats = class.startingStats
    for statId, growth in pairs(class.statGrowth) do
        stats[statId] = stats[statId] + level * growth
    end
    return stats
end
