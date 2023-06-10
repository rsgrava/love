function wait(self, dt, time)
    self.timer = 0
    ::wait::
    coroutine.yield()
    self.timer = self.timer + dt
    if self.timer < time then
        goto wait
    end
end

function teleportPlayer(self, dt, mapName, x, y, dir)
    disableControls()
        ScreenEffects.fadeOut(0.2)
            wait(self, dt, 0.3)
            local mapName = self.props.map
            if Map.name ~= MapName then
                Map.load(database.maps[mapName])
            end
            local player = ActorManager.getPlayer()
            player:setPosition(x, y, dir)
        ScreenEffects.fadeIn(0.2)
    enableControls()
end
