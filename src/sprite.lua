Class = require("libs/class")
require("src/utils")
require("src/animation")

Sprite = Class{}

function Sprite:init(defs)
    self.texture = defs.texture
    self.animation = Animation(defs.animation, defs.firstAnim)
    self.quads = generateQuads(defs.texture, defs.width, defs.height)
end

function Sprite:setAnimation(anim)
    self.animation:setAnimation(anim)
end

function Sprite:pause()
    self.animation:pause()
end

function Sprite:resume()
    self.animation:resume()
end

function Sprite:update(dt)
    self.animation:update(dt)
end

function Sprite:draw(x, y)
    love.graphics.draw(
        self.texture,
        self.quads[self.animation:getFrame()],
        math.floor(x),
        math.floor(y)
    )
end
