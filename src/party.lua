Party = {
    members = {},
    gold = 0,
}

function Party.addMember(member)
    Party.members[#Party.members + 1] = member
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
