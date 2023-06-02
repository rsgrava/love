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
        MenuManager.menus[#MenuManager.menus]:onConfirm()
    elseif Input:pressed("cancel") then
        MenuManager.menus[#MenuManager.menus]:onCancel()
    elseif Input:pressed("up") then
        MenuManager.menus[#MenuManager.menus]:onUp()
    elseif Input:pressed("down") then
        MenuManager.menus[#MenuManager.menus]:onDown()
    elseif Input:pressed("left") then
        MenuManager.menus[#MenuManager.menus]:onLeft()
    elseif Input:pressed("right") then
        MenuManager.menus[#MenuManager.menus]:onRight()
    end
end

function MenuManager.draw()
    for menuId, menu in ipairs(MenuManager.menus) do
        menu:draw()
    end
end
