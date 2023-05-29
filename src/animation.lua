Class = require("libs/class")

Animation = Class{}

function Animation:init(animationSet, firstAnim)
    self.animationSet = animationSet
    self.anim = firstAnim
    self.frame = 1
    self.timer = 0
end

function Animation:getFrame()
    return self.animationSet[self.anim].frames[self.frame]
end

function Animation:setAnimation(anim)
    if anim ~= self.anim then
        self.anim = anim
        self.frame = 1
        self.timer = 0
    end
end

function Animation:update(dt)
    self.timer = self.timer + dt
    if self.timer > self.animationSet[self.anim].timings[self.frame] then
        self.timer = 0
        self.frame = self.frame + 1
        if self.frame > #self.animationSet[self.anim].frames then
            self.frame = 1
        end
    end
end
