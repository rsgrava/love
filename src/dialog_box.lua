require("src/menu_manager")
require("src/window")

DialogBox = {
    messages = {},

    finished = false,
    timer = 0,
    subString = "",
    subStringIdx = 1,

    first = 0,
    last = -1,

    mainWindow = Window({
        x = 0,
        y = GAME_H - DIALOG_H * TILE_H,
        width = DIALOG_W,
        height = DIALOG_H,
        tex = windowTex,
    }),
    pointer = Sprite({
        texture = windowTex,
        animation = assets.animations.blinking_pointer,
        firstAnim = "pointer",
        width = TILE_W / 2,
        height = TILE_H / 2,
    })
}

function DialogBox.say(text, config)
    local message = {}
    message.text = text
    local config = config or {}
    message.title = config.title or nil
    message.portrait = config.portrait or nil
    if config.skippable == nil then
        message.skippable = true
    else
        message.skippable = config.skippable
    end

    if message.title ~= nil then
        local len = math.ceil(love.graphics.getFont():getWidth(message.title) / TILE_W)
        message.titleWindow = Window({
            x = 0,
            y = GAME_H - DIALOG_H * TILE_H - 2 * TILE_H,
            width = len + 2,
            height = 2,
            tex = windowTex,
        })
    end
    if message.portrait ~= nil then
        message.quads = generateQuads(message.portrait.image, PORTRAIT_W, PORTRAIT_H)
    end

    local speed = config.speed or 3
    if speed == 1 then
        message.threshold = 0.04
    elseif speed == 2 then
        message.threshold = 0.02
    elseif speed == 3 then
        message.threshold = 0.016
    elseif speed == 4 then
        message.threshold = 0.01
    elseif speed == 5 then 
        message.threshold = 0.005
    end

    message.onEnd = config.onEnd
    message.options = config.options

    DialogBox.push(message)
end

function DialogBox.push(message)
    if DialogBox.first > DialogBox.last then
        MenuManager.push(DialogBox)
    end
    local last = DialogBox.last + 1
    DialogBox.last = last
    DialogBox.messages[last] = message
end

function DialogBox.pop()
    local message = DialogBox.messages[DialogBox.first]
    if message.onEnd ~= nil then
        message.onEnd()
    end
    message = nil
    DialogBox.first = DialogBox.first + 1
    if DialogBox.first > DialogBox.last then
        MenuManager.pop()
    end
end

function DialogBox.onFinish()
    DialogBox.finished = true
    local message = DialogBox.messages[DialogBox.first]
    if message.options ~= nil then
        local selectionBox = SelectionBox({
            x = 0,
            y = 0,
            rows = #message.options,
            cols = 1,
            window_tex = windowTex,
            move_sound = assets.audio.move_cursor,
            confirm_sound = assets.audio.confirm,
            cancel_sound = assets.audio.cancel,
            disabled_sound = assets.audio.disabled,
            items = message.options
        })
        selectionBox:setPos(GAME_W - selectionBox:getWidth(), GAME_H - DIALOG_H * TILE_H - selectionBox:getHeight())
        MenuManager.push(selectionBox)
    end
end

function DialogBox:onConfirm(dt)
    local message = DialogBox.messages[DialogBox.first]
    if DialogBox.finished then
        DialogBox.pop()
        DialogBox.finished = false
        DialogBox.subStringIdx = 0
        DialogBox.subString = ""
    elseif message.skippable then
        DialogBox.subString = message.text
        DialogBox.onFinish()
    end
end

function DialogBox:update(dt)
    local message = DialogBox.messages[DialogBox.first]
    if DialogBox.finished then
        DialogBox.pointer:update(dt)
        if message.options ~= nil then
            DialogBox.pop()
            DialogBox.finished = false
            DialogBox.subStringIdx = 0
            DialogBox.subString = ""
        end
    else
        DialogBox.timer = DialogBox.timer + dt
        if DialogBox.timer > message.threshold then
            DialogBox.subString = string.sub(message.text, 1, DialogBox.subStringIdx)
            DialogBox.subStringIdx = DialogBox.subStringIdx + 1
            if DialogBox.subStringIdx > #message.text then
                DialogBox.onFinish()
            end
            DialogBox.timer = 0
        end
    end
end

function DialogBox:draw()
    local message = DialogBox.messages[DialogBox.first]

    if message.titleWindow ~= nil then
        message.titleWindow:draw()
        love.graphics.print(message.title, TILE_W, GAME_H - DIALOG_H * TILE_H - TILE_H * 1.75)
    end

    DialogBox.mainWindow:draw()

    local xPadding = 0
    if message.portrait ~= nil then
        love.graphics.draw(message.portrait.image, message.quads[message.portrait.quad], TILE_W * 0.75, GAME_H - DIALOG_H * TILE_H + TILE_H, 0, TILE_SCALE_X, TILE_SCALE_Y)
        xPadding = PORTRAIT_W
    end

    local _, wrappedText = love.graphics.getFont():getWrap(DialogBox.subString, (DIALOG_W - 2) * TILE_W - xPadding)
    for textId, text in ipairs(wrappedText) do
        love.graphics.print(text, TILE_W + xPadding, GAME_H - (DIALOG_H + 0.25) * TILE_H + textId * TILE_H)
    end

    if DialogBox.finished then
        DialogBox.pointer:draw(GAME_W - TILE_W * 2, GAME_H - TILE_H)
    end
end
