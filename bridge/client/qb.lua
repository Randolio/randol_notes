if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function DoNotification(text, nType)
    QBCore.Functions.Notify(text, nType)
end
