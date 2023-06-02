Gamestate = require("libs/gamestate")
require("src/constants")
require("src/states/exploration")
require("src/selection_box")
require("src/menu_manager")

mainMenuState = {}

function mainMenuState:init()
end

function mainMenuState:enter()
    local menu = selectionBox:init({
            x = 0,
            y = 0,
            rows = 3,
            cols = 1,
            window_tex = assets.graphics.menu,
            pointer_tex = assets.graphics.hand_pointer,
            move_sound = assets.audio.move_cursor,
            confirm_sound = assets.audio.confirm,
            cancel_sound = assets.audio.cancel,
            disabled_sound = assets.audio.disabled,
            items = {
                {
                    name = "Start Game",
                    onConfirm = function() Gamestate.switch(exploration) end,
                    enabled = true
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

    self.bg = assets.graphics.castle
end

function mainMenuState:leave()
    MenuManager.clear()
end

function mainMenuState:resume()
end

function mainMenuState:update(dt)
    if Input:pressed("confirm") then
        MenuManager.confirm()
    elseif Input:pressed("cancel") then
        MenuManager.cancel()
    elseif Input:pressed("up") then
        MenuManager.up()
    elseif Input:pressed("down") then
        MenuManager.down()
    elseif Input:pressed("left") then
        MenuManager.left()
    elseif Input:pressed("right") then
        MenuManager.onRight()
    end
end

function mainMenuState:draw()
    love.graphics.draw(self.bg, 0, 0, 0, TILE_SCALE_X, TILE_SCALE_Y)
    MenuManager.draw()
    local font = love.graphics.getFont()
end
