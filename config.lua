Config = {}

function ToggleAnimation(bool)
    if bool then
        exports.scully_emotemenu:PlayByCommand('notepad') -- You'll have to change to whatever emote resource you use. 
    else
        exports.scully_emotemenu:CancelAnimation()
    end
end

QBCore = exports['qb-core']:GetCoreObject()