Party = {
    members = {},
    items = {},
    gold = 0,
}

function Party.addMember(member)
    Party.members[#Party.members + 1] = member
end

function Party.addItem(itemName)
    if items[itemName] == nil then
        items[itemName] = 1
    else
        items[itemName] = items[itemName] + 1
    end
end

function Party.removeItem(itemName)
    if items[itemName] ~= nil then
        items[itemName] = items[itemName] - 1
        if items[itemName] == 0 then
            items[itemName] = nil
        end
    end
end

function Party.removeItemAll(itemName)
    items[itemName] = nil
end

function Party.hasItem(itemName)
    return items[itemName] ~= nil
end

function Party.getItemsList()
    items = {}
    for itemName, item in pairs(Party.items) do
        local enabled = false
        if database.items[itemName].usable == nil then
            enabled = true
        else
            enabled = database.items[itemName].usable()
        end
        table.insert(
            items,
            {
                name = itemName,
                enabled = enabled,
                onConfirm = nil,
            }
        )
    end
    return items
end

function Party.addGold(num)
    Party.gold = Party.gold + num
end

function Party.subtractGold(num)
    if Party.gold - num < 0 then
        return false
    end
    Party.gold = Party.gold - num
    return true
end
