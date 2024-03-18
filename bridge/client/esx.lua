if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function DoNotification(text, nType)
    ESX.ShowNotification(text, nType)
end
