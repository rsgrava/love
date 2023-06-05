Gamestate = require("libs/gamestate")
require("src/constants")
require("src/states/exploration")
require("src/selection_box")
require("src/menu_manager")

mainMenuState = {}

function mainMenuState:init()
end

function mainMenuState:enter()
    local menu = SelectionBox:init({
            x = 0,
            y = 0,
            rows = 4,
            cols = 1,
            moveSound = assets.audio.move_cursor,
            confirmSound = assets.audio.confirm,
            cancelSound = assets.audio.cancel,
            disabledSound = assets.audio.disabled,
            onClose = function() end,
            items = {
                {
                    name = "New Game",
                    onConfirm = function() Gamestate.switch(exploration) end,
                    enabled = true
                },
                {
                    name = "Load Game",
                    enabled = false
                },
                {
                    name = "Options",
                    enabled = false
                },
                {
                    name = "Quit",
                    onConfirm = function() love.event.quit() end,
                    enabled = true
                },
            }
        })
    menu:setPos((GAME_W - menu:getWidth()) / 8, (GAME_H - menu:getHeight()) / 2)
    MenuManager.push(menu)

    self.bg = assets.graphics.titles1.Castle_b2
end

function mainMenuState:leave()
    MenuManager.clear()
end

function mainMenuState:resume()
end

function mainMenuState:update(dt)
    MenuManager.update(dt)
end

function mainMenuState:draw()
    love.graphics.draw(self.bg, 0, 0, 0)
    MenuManager.draw()
end
