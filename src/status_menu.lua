require("libs/class")

StatusMenu = Class{}

function StatusMenu:init(character)
    self.character = character
    self.quads = generateQuads(assets.graphics.system.IconSet, 32, 32)

    self.portraitWindow = Window({
        x = 0,
        y = 0,
        width = 9,
        height = 4,
    })

    self.statsWindow = Window({
        x = 9 * TILE_W,
        y = 0,
        width = 8,
        height = 13,
    })

    self.equipmentWindow = Window({
        x = 0,
        y = 4 * TILE_H,
        width = 9,
        height = 9,
    })
end

function StatusMenu:onCancel()
    MenuManager.pop()
end

function StatusMenu:draw()
    self.portraitWindow:draw()
    self.statsWindow:draw()
    self.equipmentWindow:draw()

    -- portrait window
    self.character:drawPortrait(TILE_W / 2, TILE_H / 2)
    love.graphics.print(self.character.name, TILE_W / 2 + PORTRAIT_W, TILE_H * 0.5)
    love.graphics.print(self.character.class.name, TILE_W / 2 + PORTRAIT_W, TILE_H * 1.3)
    love.graphics.print("Level: "..self.character.level, TILE_W / 2 + PORTRAIT_W, TILE_H * 2.1)

    -- stats window
    love.graphics.print("HP: "..self.character.hp..'/'..self.character.stats.maxHp, 9.7 * TILE_W, TILE_H * 0.5)
    love.graphics.print("MP: "..self.character.mp..'/'..self.character.stats.maxMp, 9.7 * TILE_W, TILE_H * 1.5)

    love.graphics.print("Str: "..self.character.stats.str, 9.7 * TILE_W, TILE_H * 3.5)
    love.graphics.print("Int: "..self.character.stats.int, 9.7 * TILE_W, TILE_H * 4.5)
    love.graphics.print("Res: "..self.character.stats.res, 9.7 * TILE_W, TILE_H * 5.5)
    love.graphics.print("Wil: "..self.character.stats.wil, 9.7 * TILE_W, TILE_H * 6.5)
    love.graphics.print("Spd: "..self.character.stats.spd, 9.7 * TILE_W, TILE_H * 7.5)

    local xpToNext = xpToLevel(self.character.level + 1)
    if xpToNext == nil then
        xpToNext = "--"
    end
    love.graphics.print("XP: "..self.character.xp, 9.7 * TILE_W, TILE_H * 9.5)
    love.graphics.print("Next: "..xpToNext, 9.7 * TILE_W, TILE_H * 10.5)

    -- equipment window
    love.graphics.draw(assets.graphics.system.IconSet, self.quads[97], TILE_W, 5 * TILE_H, 0, 1.5, 1.5)
    love.graphics.draw(assets.graphics.system.IconSet, self.quads[96], TILE_W, 6.5 * TILE_H, 0, 1.5, 1.5)
    love.graphics.draw(assets.graphics.system.IconSet, self.quads[137], TILE_W, 8 * TILE_H, 0, 1.5, 1.5)
    love.graphics.draw(assets.graphics.system.IconSet, self.quads[132], TILE_W, 9.5 * TILE_H, 0, 1.5, 1.5)
    love.graphics.draw(assets.graphics.system.IconSet, self.quads[145], TILE_W, 11 * TILE_H, 0, 1.5, 1.5)

    local weapon = self.character.equipment.weapon or '----'
    local secondary = self.character.equipment.secondary or '----'
    local armor = self.character.equipment.armor or '----'
    local helmet = self.character.equipment.helmet or '----'
    local accessory = self.character.equipment.accessory or '----'
    love.graphics.print(weapon, TILE_W * 2.5, 4.75 * TILE_H)
    love.graphics.print(secondary, TILE_W * 2.5, 6.25 * TILE_H)
    love.graphics.print(armor, TILE_W * 2.5, 7.75 * TILE_H)
    love.graphics.print(helmet, TILE_W * 2.5, 9.25 * TILE_H)
    love.graphics.print(accessory, TILE_W * 2.5, 10.75 * TILE_H)
end
