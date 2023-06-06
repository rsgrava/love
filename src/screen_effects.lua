require("libs/class")

ScreenEffects = {
    effects = {}
}

function ScreenEffects.fadeIn()
    if ScreenEffects.effects.fade == nil then
        return
    end
    ScreenEffects.effects.fade.type = "in"
end

function ScreenEffects.fadeOut(time, r, g, b)
    if ScreenEffects.effects.fade == nil then
        ScreenEffects.effects.fade = FadeEffect("out", time, r, g, b)
    end
end

function ScreenEffects.update(dt)
    for effectId, effect in pairs(ScreenEffects.effects) do
        effect:update(dt)
        if effect.finished then
            ScreenEffects.effects[effectId] = nil
        end
    end
end

function ScreenEffects.draw()
    for effectId, effect in pairs(ScreenEffects.effects) do
        effect:draw()
    end
end

FadeEffect = Class{}

function FadeEffect:init(type, time, r, g, b)
    self.type = type
    self.time = time or 0.1
    self.r = r or 0
    self.g = g or 0
    self.b = b or 0
    self.timer = 0
    self.alpha = 0
end

function FadeEffect:update(dt)
    if self.type == "out" then
        self.timer = self.timer + dt
    elseif self.type == "in" then
        self.timer = self.timer - dt
    end
    self.alpha = math.max(math.min(self.timer / self.time, 1), 0)
    if self.timer < 0 then
        self.finished = true
    end
end

function FadeEffect:draw()
    love.graphics.setColor(self.r, self.g, self.b, self.alpha)
    love.graphics.rectangle("fill", 0, 0, GAME_W, GAME_H)
    love.graphics.setColor(1, 1, 1, 0)
end
