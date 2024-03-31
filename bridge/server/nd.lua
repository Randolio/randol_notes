if not lib.checkDependency('ND_Core', '2.0.0') then return end

local NDCore = exports['ND_Core']

function GetPlayer(id)
    return NDCore:getPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('ox_lib:notify', src, { type = nType, description = text })
end

function GetPlyIdentifier(player)
    return player?.id
end

function GetCharacterName(player)
    return player?.fullname
end