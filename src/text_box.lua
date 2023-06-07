require("libs/class")

TextBox = Class{}

function TextBox:init(defs)
    self.text = defs.text
    self.window = Window({
        x = defs.x or 0,
        y = defs.y or 0,
        width = defs.width,
        height = defs.height,
    })
end

function TextBox:draw()
    self.window:draw()
    local _, wrappedText = love.graphics.getFont():getWrap(self.text, (self.window.width - 2) * TILE_W)
    for textId, text in ipairs(wrappedText) do
        love.graphics.print(text, self.window.x + TILE_W, self.window.y + 0.8 * TILE_H * textId)
    end
end
