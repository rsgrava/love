Class = require("libs/class")
require("src/constants")
require("src/window")

SelectionBox = Class{}

function SelectionBox:init(defs)
    self.x = defs.x
    self.y = defs.y
    self.cols = math.min(defs.cols, #defs.items)
    self.rows = defs.rows
    self.selection_x = defs.selection_x or 0
    self.selection_y = defs.selection_y or 0
    self.move_sound = defs.move_sound or nil
    self.confirm_sound = defs.confirm_sound or nil
    self.cancel_sound = defs.cancel_sound or nil
    self.disabled_sound = defs.disabled_sound or nil
    self.onClose = defs.onClose or MenuManager.pop
    self.items = defs.items or {}

    self.itemWidth = 0
    self.itemHeight = 0
    for k, v in pairs(defs.items) do
        local len = math.ceil(love.graphics.getFont():getWidth(v.name) / TILE_W)
        if len > self.itemWidth then
            self.itemWidth = len
        end
    end
    self.width = defs.width or self.cols * self.itemWidth + 1 + self.cols
    self.height = self.rows + 2
    self.total_rows = math.floor(#self.items / self.cols)
    if #self.items % self.cols > 0 then
        self.total_rows = self.total_rows + 1
    end
    self.top_row = 0
    self.window_tex = defs.window_tex
    self.window = Window({
        x = defs.x,
        y = defs.y,
        width = self.width,
        height = self.height,
        tex = self.window_tex,
    })
    self.pointerQuad = generateQuads(defs.window_tex, TILE_W / 2, TILE_H / 2, 0, TILE_H / 4)[14]

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
    return self.top_row * self.cols + self.selection_y * self.cols + self.selection_x
end

function SelectionBox:clampSelection()
    if self:getCurrentItem() >= #self.items then
        self.selection_y = math.floor(#self.items / self.cols) - self.top_row
        self.selection_x = #self.items % self.cols - 1
    end
end

function SelectionBox:onConfirm()
    local item = self.items[self:getCurrentItem() + 1]
    if item.enabled then
        local func = self.items[self:getCurrentItem() + 1].onConfirm
        if func ~= nil then
            func()
        end
        if self.confirm_sound ~= nil then
            love.audio.play(self.confirm_sound)
        end
    else
        if self.disabled_sound ~= nil then
            love.audio.play(self.disabled_sound)
        end
    end
end

function SelectionBox:onCancel()
    if self.onClose ~= nil then
        self.onClose()
    end
    if self.cancel_sound ~= nil then
        love.audio.play(self.cancel_sound)
    end
end

function SelectionBox:onUp()
    self.selection_y = self.selection_y - 1
    if self.selection_y < 0 then
        self.selection_y = 0
        self.top_row = math.max(self.top_row - 1, 0)
    elseif self.move_sound ~= nil then
        love.audio.play(self.move_sound)
    end
    self:clampSelection()
end

function SelectionBox:onDown()
    self.selection_y = self.selection_y + 1
    if self.selection_y > self.rows - 1 then
        self.selection_y = self.rows - 1
        self.top_row = self.top_row + 1
        if self.top_row > self.total_rows - self.rows then
            self.top_row = self.total_rows - self.rows
        end
    elseif self.move_sound ~= nil then
        love.audio.play(self.move_sound)
    end
    self:clampSelection()
end

function SelectionBox:onLeft()
    self.selection_x = self.selection_x - 1
    if self.selection_x < 0 then
        self.selection_x = 0
    elseif self.move_sound ~= nil then
        love.audio.play(self.move_sound)
    end
    self:clampSelection()
end

function SelectionBox:onRight()
    self.selection_x = self.selection_x + 1
    if self.selection_x > self.cols - 1 then
        self.selection_x = self.cols - 1
    elseif self.move_sound ~= nil then
        love.audio.play(self.move_sound)
    end
    self:clampSelection()
end

function SelectionBox:draw()
    self.window:draw()

    -- draw menu items
    local top_left_item = self.top_row * self.cols
    local bottom_right_item = self.rows * self.cols + top_left_item
    bottom_right_item = math.min(#self.items, bottom_right_item)
    local visible_items = bottom_right_item - top_left_item
    for i = 1, visible_items do
        item = self.items[top_left_item + i]
        key = i - 1
        local x = key % self.cols
        local y = math.floor(key / self.cols)
        if not item.enabled then
            love.graphics.setColor(love.math.colorFromBytes(128, 128, 128))
        end
        love.graphics.print(item.name, self.x + x * TILE_W * (self.itemWidth + 1) + TILE_W, self.y + (y + 0.8) * TILE_H)
        love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    end

    -- draw selection pointer
    love.graphics.draw(self.window_tex, self.pointerQuad, self.x + self.selection_x * TILE_W * (self.itemWidth + 1) + TILE_W / 3, self.y + self.selection_y * TILE_H + TILE_H * 1.25)
end
