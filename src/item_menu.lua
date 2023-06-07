require("libs/class")
require("src/selection_box")
require("src/text_box")

ItemMenu = Class{}
local itemSelection = {}

function ItemMenu:init()
    self.state = "class"
    self.classSelection = SelectionBox({
        x = 0,
        y = 0,
        rows = 4,
        cols = 1,
        width = 7,
        items = {
            {
                name = "Items",
                enabled = #Party.getItemsClass("item") > 0,
                onConfirm = openItemList,
            },
            {
                name = "Weapons",
                enabled = #Party.getItemsClass("weapon") > 0,
                onConfirm = openItemList,
            },
            {
                name = "Armor",
                enabled = #Party.getItemsClass("armor") > 0,
                onConfirm = openItemList,
            },
            {
                name = "Key Items",
                enabled = #Party.getItemsClass("armor") > 0,
                onConfirm = openItemList,
            }
        }
    })
    self.classSelection.active = true

    self.descriptionBox = TextBox({
        text = "",
        x = 7 * TILE_W,
        y = 0,
        width = 10,
        height = 6
    })

    items = Party.getItemsClass("item")
    itemSelection = SelectionBox({
        x = 0,
        y = 6 * TILE_H,
        rows = 5,
        cols = 2,
        width = 17,
        items = items,
    })
end

function ItemMenu:updateItemSelection()
    itemSelection = SelectionBox({
        x = 0,
        y = 6 * TILE_H,
        rows = 5,
        cols = 2,
        width = 17,
        items = Party.getItemsClass("item"),
    })
end

function openItemList()
    MenuManager.push(itemSelection)
end

function ItemMenu:onConfirm()
    self.classSelection:onConfirm()
end

function ItemMenu:onCancel()
    MenuManager.pop()
end

function ItemMenu:onUp()
    self.classSelection:onUp()
end

function ItemMenu:onDown()
    self.classSelection:onDown()
end

function ItemMenu:onLeft()
    self.classSelection:onLeft()
end

function ItemMenu:onRight()
    self.classSelection:onRight()
end

function ItemMenu:update(dt)
    self.classSelection:update(dt)
    if self.active then
        self.descriptionBox.text = ""
    else
        self.descriptionBox.text = database.items[itemSelection:getSelectedName()].description
    end
end

function ItemMenu:draw()
    self.classSelection:draw()
    self.descriptionBox:draw()
    itemSelection:draw()
end
