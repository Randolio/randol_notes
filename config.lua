Config = {}

function ToggleAnimation(bool)
    if bool then
        exports.scully_emotemenu:playEmoteByCommand('notepad') -- You'll have to change to whatever emote resource you use. 
    else
        exports.scully_emotemenu:cancelEmote()
    end
end

QBCore = exports['qb-core']:GetCoreObject()
