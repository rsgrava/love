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

function MenuManager.up()
    MenuManager.menus[#MenuManager.menus]:onUp()
end

function MenuManager.down()
    MenuManager.menus[#MenuManager.menus]:onDown()
end

function MenuManager.left()
    MenuManager.menus[#MenuManager.menus]:onLeft()
end

function MenuManager.right()
    MenuManager.menus[#MenuManager.menus]:onRight()
end

function MenuManager.confirm()
    MenuManager.menus[#MenuManager.menus]:onConfirm()
end

function MenuManager.cancel()
    MenuManager.menus[#MenuManager.menus]:onCancel()
end

function MenuManager.update(dt)
    MenuManager.menus[#MenuManager.menus]:update(dt)
end

function MenuManager.draw()
    for menuId, menu in ipairs(MenuManager.menus) do
        menu:draw()
    end
end
