
require("src/window")

DialogBox = Class{}

function DialogBox:init(defs)
    self.text = defs.text
    self.title = defs.title
    self.portrait = defs.portrait or nil
    if defs.skippable == nil then
        self.skippable = true
    else
        self.skippable = defs.skippable
    end

    self.width = DIALOG_W
    self.height = DIALOG_H

    if self.title ~= nil then
        local len = math.ceil(love.graphics.getFont():getWidth(self.title) / TILE_W)
        self.titleWindow = Window({
            x = 0,
            y = GAME_H - DIALOG_H * TILE_H - 2 * TILE_H,
            width = len + 2,
            height = 2,
            tex = assets.graphics.menu,
        })
    end
    if self.portrait ~= nil then
        self.quads = generateQuads(self.portrait.image, PORTRAIT_W, PORTRAIT_H)
    end
    self.mainWindow = Window({
        x = 0,
        y = GAME_H - DIALOG_H * TILE_H,
        width = DIALOG_W,
        height = DIALOG_H,
        tex = assets.graphics.system.window.window01,
    })

    local speed = defs.speed or 3
    if speed == 1 then
        self.threshold = 0.04
    elseif speed == 2 then
        self.threshold = 0.02
    elseif speed == 3 then
        self.threshold = 0.016
    elseif speed == 4 then
        self.threshold = 0.01
    elseif speed == 5 then 
        self.threshold = 0.005
    end

    self.finished = false
    self.timer = 0
    self.subString = ""
    self.subStringIdx = 1
    self.currentText = 1
end

function DialogBox:onConfirm(dt)
    if self.finished then
        self.currentText = self.currentText + 1
        self.finished = false
        self.subStringIdx = 0
        if self.currentText > #self.text then
            MenuManager.pop()
        end
    elseif self.skippable then
        self.subString = self.text[self.currentText]
        self.finished = true
    end
end

function DialogBox:update(dt)
    if not self.finished then
        self.timer = self.timer + dt
        if self.timer > self.threshold then
            self.subString = string.sub(self.text[self.currentText], 1, self.subStringIdx)
            self.subStringIdx = self.subStringIdx + 1
            if self.subStringIdx > #self.text[self.currentText] then
                self.finished = true
            end
            self.timer = 0
        end
    end
end

function DialogBox:draw()
    if self.titleWindow ~= nil then
        self.titleWindow:draw()
        love.graphics.print(self.title, TILE_W, GAME_H - DIALOG_H * TILE_H - TILE_H * 1.25)
    end
    self.mainWindow:draw()
    local xPadding = 0
    if self.portrait ~= nil then
        love.graphics.draw(self.portrait.image, self.quads[self.portrait.quad], TILE_W * 0.75, GAME_H - DIALOG_H * TILE_H + TILE_H, 0, TILE_SCALE_X, TILE_SCALE_Y)
        xPadding = PORTRAIT_W
    end
    local _, wrappedText = love.graphics.getFont():getWrap(self.subString, (self.width - 2) * TILE_W - xPadding)
    for textId, text in ipairs(wrappedText) do
        love.graphics.print(text, TILE_W + xPadding, GAME_H - (DIALOG_H + 0.25) * TILE_H + textId * TILE_H)
    end
end
