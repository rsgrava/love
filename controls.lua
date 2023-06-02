return {
    controls = {
        up = {"sc:up","button:dpup", "axis:lefty-",},
        down = {"sc:down","button:dpdown", "axis:lefty+",},
        left = {"sc:left","button:dpleft", "axis:leftx-",},
        right = {"sc:right","button:dpright", "axis:leftx+",},
        run = {"sc:lshift","button:a"},
        action = {"sc:z","button:b","button:leftshoulder"},
        menu = {"sc:x","button:a","button:start",},
        confirm = {"sc:z","sc:return","button:b",},
        cancel = {"sc:x","sc:escape","button:y",},
    },
    joystick = love.joystick.getJoysticks()[1],
    deadzone = 0.2
}
