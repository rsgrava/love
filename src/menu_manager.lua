MenuManager = {
    menus = {}
}

function MenuManager.push(menu)
    MenuManager.menus[#MenuManager.menus + 1] = menu
end

function MenuManager.pop()
    MenuManager.menus[#MenuManager.menus] = nil
end

function MenuManager.clear()
    MenuManager.menus = {}
end

function MenuManager.isEmpty()
    return #MenuManager.menus == 0
end

function MenuManager.update(dt)
    if Input:pressed("confirm") then
        if MenuManager.menus[#MenuManager.menus].onConfirm ~= nil then
            MenuManager.menus[#MenuManager.menus]:onConfirm(dt)
        end
    elseif Input:pressed("cancel") then
        if MenuManager.menus[#MenuManager.menus].onCancel ~= nil then
            MenuManager.menus[#MenuManager.menus]:onCancel(dt)
        end
    elseif Input:pressed("up") then
        if MenuManager.menus[#MenuManager.menus].onUp ~= nil then
            MenuManager.menus[#MenuManager.menus]:onUp(dt)
        end
    elseif Input:pressed("down") then
        if MenuManager.menus[#MenuManager.menus].onDown ~= nil then
            MenuManager.menus[#MenuManager.menus]:onDown(dt)
        end
    elseif Input:pressed("left") then
        if MenuManager.menus[#MenuManager.menus].onLeft ~= nil then
            MenuManager.menus[#MenuManager.menus]:onLeft(dt)
        end
    elseif Input:pressed("right") then
        if MenuManager.menus[#MenuManager.menus].onRight ~= nil then
            MenuManager.menus[#MenuManager.menus]:onRight(dt)
        end
    else
        if MenuManager.menus[#MenuManager.menus].update ~= nil then
            MenuManager.menus[#MenuManager.menus]:update(dt)
        end
    end
end

function MenuManager.draw()
    for menuId, menu in ipairs(MenuManager.menus) do
        menu:draw()
    end
end
