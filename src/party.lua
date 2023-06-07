Party = {
    members = {},
    items = {},
    gold = 0,
}

function Party.addMember(member)
    Party.members[#Party.members + 1] = member
end

function Party.addItem(itemName)
    if Party.items[itemName] == nil then
        Party.items[itemName] = 1
    else
        Party.items[itemName] = Party.items[itemName] + 1
    end
end

function Party.removeItem(itemName)
    if Party.items[itemName] ~= nil then
        Party.items[itemName] = Party.items[itemName] - 1
        if Party.items[itemName] == 0 then
            Party.items[itemName] = nil
        end
    end
end

function Party.removeItemAll(itemName)
    Party.items[itemName] = nil
end

function Party.hasItem(itemName)
    return Party.items[itemName] ~= nil
end

function Party.getItemsClass(class)
    items = {}
    for itemName, itemCount in pairs(Party.items) do
        local item = database.items[itemName]
        if item.class == class then
            -- either bool, nil (defaults to false) or function that rets bool
            local enabled = item.usable
            if enabled == nil then
                enabled = false
            elseif type(enabled) == "function" then
                enabled = item.usable()
            end
            local name = itemName
            if itemCount > 1 and itemCount < 10 then
                name = name.."(x0"..itemCount..')'
            elseif itemCount > 10 then
                name = name.."(x"..itemCount..')'
            end
            table.insert(
                items,
                {
                    name = name,
                    enabled = enabled,
                    onConfirm = nil,
                }
            )
        end
    end
    table.sort(items, function(a, b) return a.name < b.name end)
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
