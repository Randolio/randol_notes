if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('esx:showNotification', src, text, nType)
end

function GetPlyIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end