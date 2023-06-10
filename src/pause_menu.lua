require("libs/class")
require("src/item_menu")
require("src/menu_manager")
require("src/party")
require("src/status_menu")
require("src/window")

PauseMenu = Class{}

function PauseMenu:init()
    self.selection = SelectionBox({
        x = 0,
        y = 0,
        rows = 8,
        cols = 1,
        width = 7,
        items = {
            {
                name = "Item",
                enabled = true,
                onConfirm = openItemMenu,
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
                enabled = true,
                onConfirm = openStatusSelectionMenu
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
    self.selection.active = true

    self.statsWindow = Window({
        x = 7 * TILE_W,
        y = 0,
        width = GAME_W / TILE_W - 7,
        height = GAME_H / TILE_H,
    })

    self.goldWindow = Window({
        x = 0,
        y = self.selection:getHeight(),
        width = 7,
        height = 3,
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
    self.selection:update(dt)
end

function PauseMenu:draw()
    self.selection:draw()
    self.statsWindow:draw()
    self.goldWindow:draw()

    for memberId, member in ipairs(Party.members) do
        member:drawPortrait(7.5 * TILE_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825)
        love.graphics.print(member.name, 7.5 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825)

        love.graphics.print("HP", 7.5 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H)
        love.graphics.print("MP", 7.5 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H * 1.75)
        love.graphics.print(member.hp..'/'..member.stats.maxHp, 9 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H)
        love.graphics.print(member.mp..'/'..member.stats.maxMp, 9 * TILE_W + PORTRAIT_W, memberId * TILE_H * 0.5 + (memberId - 1) * PORTRAIT_H * 0.825 + TILE_H * 1.75)
    end
    love.graphics.print(Party.gold..'G', (self.selection:getWidth() - love.graphics.getFont():getWidth(Party.gold..'G')) / 2, self.selection:getHeight() + 0.75 * TILE_H)
end

function openItemMenu()
    MenuManager.push(ItemMenu())
end

function openStatusSelectionMenu()
    items = {}
    for i = 1, 4 do
        local character = Party.members[i]
        if character == nil then
            items[i] = {
                name = "----",
                enabled = false,
            }
        else
            items[i] = {
                name = character.name,
                enabled = true,
                onConfirm = function() MenuManager.push(StatusMenu(Party.members[i])) end,
            }
        end
    end

    MenuManager.push(SelectionBox({
        x = 0,
        y = 0,
        rows = 4,
        cols = 1,
        width = 7,
        items = items,
    }))
end

function openStatusMenu(charId)
    MenuManager.push(StatusMenu(Party.members[charId]))
end
