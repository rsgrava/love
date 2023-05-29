Class = require("libs/class")
require "src/constants"
require "src/utils"

Menu = Class{}

function Menu:init(defs)
    self.x = defs.x
    self.y = defs.y
    self.cols = math.min(defs.cols, #defs.items)
    self.rows = defs.rows
    self.frame_tex = defs.frame_tex
    self.quads = generateQuads(defs.frame_tex, TILE_W, TILE_H)
    self.pointer_tex = defs.pointer_tex
    self.selection_x = defs.selection_x or 0
    self.selection_y = defs.selection_y or 0
    self.padding_y = defs.padding_y or 4
    self.move_sound = defs.move_sound or nil
    self.confirm_sound = defs.confirm_sound or nil
    self.cancel_sound = defs.cancel_sound or nil
    self.disabled_sound = defs.disabled_sound or nil
    self.items = defs.items or {}

    self.itemWidth = 0
    self.itemHeight = 0
    for k, v in pairs(defs.items) do
        local len = math.ceil(love.graphics.getFont():getWidth(v.name) / TILE_W)
        if len > self.itemWidth then
            self.itemWidth = len
        end
    end
    self.width = self.cols * self.itemWidth + 2 + self.cols - 1
    self.height = self.rows + 2
    self.total_rows = math.floor(#self.items / self.cols)
    if #self.items % self.cols > 0 then
        self.total_rows = self.total_rows + 1
    end
    self.top_row = 0

    return self
end

function Menu:getWidth()
    return self.width * TILE_W
end

function Menu:getHeight()
    return self.height * TILE_H
end

function Menu:setPos(x, y)
    self.x = x
    self.y = y
end

function Menu:getCurrentItem()
    return self.top_row * self.cols + self.selection_y * self.cols + self.selection_x
end

function Menu:clampSelection()
    if self:getCurrentItem() >= #self.items then
        self.selection_y = math.floor(#self.items / self.cols) - self.top_row
        self.selection_x = #self.items % self.cols - 1
    end
end

function Menu:onConfirm()
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

function Menu:onCancel()
    local func = self.items[self:getCurrentItem() + 1].onCancel
    if func ~= nil then
        func()
    end
    if self.cancel_sound ~= nil then
        love.audio.play(self.cancel_sound)
    end
end

function Menu:onUp()
    self.selection_y = self.selection_y - 1
    if self.selection_y < 0 then
        self.selection_y = 0
        self.top_row = math.max(self.top_row - 1, 0)
    elseif self.move_sound ~= nil then
        love.audio.play(self.move_sound)
    end
    self:clampSelection()
end

function Menu:onDown()
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

function Menu:onLeft()
    self.selection_x = self.selection_x - 1
    if self.selection_x < 0 then
        self.selection_x = 0
    elseif self.move_sound ~= nil then
        love.audio.play(self.move_sound)
    end
    self:clampSelection()
end

function Menu:onRight()
    self.selection_x = self.selection_x + 1
    if self.selection_x > self.cols - 1 then
        self.selection_x = self.cols - 1
    elseif self.move_sound ~= nil then
        love.audio.play(self.move_sound)
    end
    self:clampSelection()
end

function Menu:draw()
    -- draw menu frame
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local quad = 4
            if x == 0 and y == 0 then
                quad = 0
            elseif x == self.width - 1 and y == 0 then
                quad = 2
            elseif y == 0 then
                quad = 1
            elseif y == self.height - 1 and x == 0 then
                quad = 6
            elseif y == self.height - 1 and x == self.width - 1 then
                quad = 8
            elseif x == 0 then
                quad = 3
            elseif x == self.width - 1 then
                quad = 5
            elseif y == self.height - 1 then
                quad = 7
            end
            love.graphics.draw(self.frame_tex, self.quads[quad], self.x + x * TILE_W, self.y + y * TILE_H)
        end
    end

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
        love.graphics.print(item.name, self.x + x * TILE_W * (self.itemWidth + 1) + TILE_W, self.y + (y + 1) * TILE_H + self.padding_y)
        love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
    end

    -- draw selection pointer
    love.graphics.draw(self.pointer_tex, self.x + self.selection_x * TILE_W * (self.itemWidth + 1), self.y + self.selection_y * TILE_H + TILE_H + self.padding_y)
end
