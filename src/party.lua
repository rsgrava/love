Party = {
    members = {},
    gold = 0,
}

function Party.addMember(member)
    Party.members[#Party.members + 1] = member
end

function Party.addGold(num)
    party.gold = party.gold + num
end

function Party.subtractGold(num)
    if party.gold - num < 0 then
        return false
    end
    party.gold = party.gold - num
    return true
end
