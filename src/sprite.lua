Class = require("libs/class")
require("src/utils")

Sprite = Class{}

function Sprite:init(defs)
    self.texture = defs.texture
    self.quads = generateQuads(defs.texture, defs.width, defs.height)
    self.animationSet = defs.animation
    self.anim = defs.firstAnim
    self.frame = 1
    self.timer = 0
    self.paused = false
end

function Sprite:setAnimation(anim)
    if anim ~= self.anim then
        self.anim = anim
        self.frame = 1
        self.timer = 0
    end
end

function Sprite:pause()
    if not self.paused then
        self.paused = true
        self.frame = 1
        self.timer = 0
    end
end

function Sprite:resume()
    if self.paused then
        self.paused = false
        self.frame = 1
        self.timer = 0
    end
end

function Sprite:update(dt)
    if not self.paused then
        self.timer = self.timer + dt
        if self.timer > self.animationSet[self.anim].timings[self.frame] then
            self.timer = 0
            self.frame = self.frame + 1
            if self.frame > #self.animationSet[self.anim].frames then
                self.frame = 1
            end
        end
    end
end

function Sprite:draw(x, y)
    love.graphics.draw(
        self.texture,
        self.quads[self.animationSet[self.anim].frames[self.frame]],
        math.floor(x),
        math.floor(y)
    )
end
