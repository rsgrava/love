require("libs/class")
require("src/menu_manager")
require("src/party")
require("src/window")

PauseMenu = Class{}

function PauseMenu:init()
    self.selection = SelectionBox:init({
        x = 0,
        y = 0,
        rows = 8,
        cols = 1,
        width = 7,
        moveSound = assets.audio.move_cursor,
        confirmSound = assets.audio.confirm,
        cancelSound = assets.audio.cancel,
        disabledSound = assets.audio.disabled,
        items = {
            {
                name = "Item",
                enabled = false
            },
            {
                name = "Skill",
                enabled = false
            },
            {
                name = "Equip",
                enabled = false
            },
            {
                name = "Status",
                enabled = false
            },
            {
                name = "Formation",
                enabled = false
            },
            {
                name = "Options",
                enabled = false
            },
            {
                name = "Save",
                enabled = false
            },
            {
                name = "Quit",
                onConfirm = love.event.quit,
                enabled = true
            },
        }
    })

    self.statsWindow = Window({
        x = 7 * TILE_W,
        y = 0,
        width = GAME_W / TILE_W - 7,
        height = GAME_H / TILE_H,
    })
end

function PauseMenu:onConfirm()
    self.selection:onConfirm()
end

function PauseMenu:onCancel()
    self.selection:onCancel()
end

function PauseMenu:onUp()
    self.selection:onUp()
end

function PauseMenu:onDown()
    self.selection:onDown()
end

function PauseMenu:onLeft()
    self.selection:onLeft()
end

function PauseMenu:onRight()
    self.selection:onRight()
end

function PauseMenu:update(dt)
    
end

function PauseMenu:draw()
    self.selection:draw()
    self.statsWindow:draw()
    for memberId, member in ipairs(Party.members) do
        member:draw(7.5 * TILE_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825)
        love.graphics.print(member.name, 7.5 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825)

        love.graphics.print("HP", 7.5 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H)
        love.graphics.print("MP", 7.5 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H * 1.75)
        love.graphics.print(member.hp..'/'..member.maxHp, 9 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H)
        love.graphics.print(member.mp..'/'..member.maxMp, 9 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H * 1.75)
    end
end
