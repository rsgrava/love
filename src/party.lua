Party = {
    members = {},
    items = {},
    gold = 0,
}

-- General

function Party.addMember(member)
    Party.members[#Party.members + 1] = member
end

-- Inventory

function Party.addItem(itemName, count)
    local count = count or 1
    if Party.items[itemName] == nil then
        Party.items[itemName] = math.min(count, 99)
        return true
    elseif
        Party.items[itemName] == 99 then
        return false
    else
        Party.items[itemName] = math.min(Party.items[itemName] + count, 99)
        return true
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
            while #name < 9 do
                name = name..' '
            end
            if itemCount > 1 and itemCount < 10 then
                name = name.."(x0"..itemCount..')'
            elseif itemCount >= 10 then
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

-- Gold

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

-- XP

function Party.addXp(charId, xp)
    -- add xp
    local character = Party.members[charId]
    character.xp = character.xp + xp

    -- keep levelling until xp is no longer enough
    repeat
        local xpToNext = xpToLevel(character.level + 1)

        -- if max level, cap xp and return
        if xpToNext == nil then
            character.xp = xpToLevel(character.level)
            return
        end

        -- check for level up
        if character.xp >= xpToNext then
            character:levelUp()
        end
    until character.xp < xpToNext
end
