    Class = require("libs/class")
    require("src/constants")
    require("src/window")

    SelectionBox = Class{}

function SelectionBox:init(defs)
    self.x = defs.x
    self.y = defs.y
    self.cols = math.min(defs.cols, #defs.items)
    self.rows = defs.rows
    self.selectionX = defs.selectionX or 0
    self.selectionY = defs.selectionY or 0
    self.onClose = defs.onClose or MenuManager.pop
    self.items = defs.items or {}
    self.active = false

    if defs.itemWidth == nil then
        self.itemWidth = 0
        for k, v in pairs(defs.items) do
            local len = math.ceil(love.graphics.getFont():getWidth(v.name) / TILE_W)
            if len > self.itemWidth then
                self.itemWidth = len
            end
        end
    else
        self.itemWidth = defs.itemWidth
    end
    self.width = defs.width or self.cols * self.itemWidth + 1 + self.cols
    self.height = self.rows + 2
    self.totalRows = math.floor(#self.items / self.cols)
    if #self.items % self.cols > 0 then
        self.totalRows = self.totalRows + 1
    end
    self.topRow = 0
    self.window = Window({
        x = defs.x,
        y = defs.y,
        width = self.width,
        height = self.height,
    })
    self.pointerQuad = generateQuads(windowTex, TILE_W / 2, TILE_H / 2, 0, TILE_H / 4)[14]
    self.blinkingArrow = Sprite({
        texture = windowTex,
        animation = assets.animations.blinking_pointer,
        firstAnim = "pointer",
        width = TILE_W / 2,
        height = TILE_H / 2,
    })

    for itemId, item in ipairs(self.items) do
        if item.enabled == nil then
            item.enabled = true
        end
    end

    return self
end

function SelectionBox:getWidth()
    return self.width * TILE_W
end

function SelectionBox:getHeight()
    return self.height * TILE_H
end

function SelectionBox:setPos(x, y)
    self.x = x
    self.y = y
    self.window:setPos(x, y)
end

function SelectionBox:getCurrentItem()
    return self.topRow * self.cols + self.selectionY * self.cols + self.selectionX
end

function SelectionBox:clampSelection()
    if self:getCurrentItem() >= #self.items then
        self.selectionX = math.max(#self.items % self.cols - 1, 0)
        self.selectionY = math.floor(#self.items / self.cols) - (self.topRow)
        if #self.items <= self.cols then
            self.selectionY = self.selectionY - 1
        end
    end
end

function SelectionBox:getSelectedName()
    return self.items[self:getCurrentItem() + 1].name
end

function SelectionBox:onConfirm()
    if #self.items ~= 0 then
        local item = self.items[self:getCurrentItem() + 1]
        if item.enabled then
            local func = self.items[self:getCurrentItem() + 1].onConfirm
            if func ~= nil then
                func()
            end
            love.audio.play(assets.audio.confirm)
        else
            love.audio.play(assets.audio.disabled)
        end
    end
end

function SelectionBox:onCancel()
    if self.onClose ~= nil then
        self.onClose()
    end
end

function SelectionBox:onUp()
    self.selectionY = self.selectionY - 1
    if self.selectionY < 0 then
        self.selectionY = 0
        self.topRow = math.max(self.topRow - 1, 0)
    end
    love.audio.play(assets.audio.move_cursor)
    self:clampSelection()
end

function SelectionBox:onDown()
    self.selectionY = self.selectionY + 1
    if self.selectionY > self.rows - 1 then
        self.selectionY = self.rows - 1
        self.topRow = self.topRow + 1
        if self.topRow > self.totalRows - self.rows then
            self.topRow = self.totalRows - self.rows
        end
    end
    love.audio.play(assets.audio.move_cursor)
    self:clampSelection()
end

function SelectionBox:onLeft()
    self.selectionX = self.selectionX - 1
    if self.selectionX < 0 then
        self.selectionX = 0
    end
    love.audio.play(assets.audio.move_cursor)
    self:clampSelection()
end

function SelectionBox:onRight()
    self.selectionX = self.selectionX + 1
    if self.selectionX > self.cols - 1 then
        self.selectionX = self.cols - 1
    end
    love.audio.play(assets.audio.move_cursor)
    self:clampSelection()
end

function SelectionBox:update(dt)
    self.blinkingArrow:update(dt)
end

function SelectionBox:draw()
    self.window:draw()

    -- draw menu items
    local topLeftItem = self.topRow * self.cols
    local bottomRightItem = self.rows * self.cols + topLeftItem
    bottomRightItem = math.min(#self.items, bottomRightItem)
    local visibleItems = bottomRightItem - topLeftItem
    for i = 1, visibleItems do
        item = self.items[topLeftItem + i]
        key = i - 1
        local x = key % self.cols
        local y = math.floor(key / self.cols)
        if not item.enabled then
            love.graphics.setColor(love.math.colorFromBytes(128, 128, 128))
        end
        love.graphics.print(item.name, self.x + x * TILE_W * (self.itemWidth + 1) + TILE_W, self.y + (y + 0.8) * TILE_H)
        love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    end

    if self.active then
        -- draw selection pointer
        love.graphics.draw(windowTex, self.pointerQuad, self.x + self.selectionX * TILE_W * (self.itemWidth + 1) + TILE_W / 3, self.y + self.selectionY * TILE_H + TILE_H * 1.25)

        -- draw blinking arrow
        if self.topRow < self.totalRows - self.rows then
            self.blinkingArrow:draw(self.x + (self.width - 1.25) * TILE_W,self.y + (self.height - 1) * TILE_H)
        end
    end
end
