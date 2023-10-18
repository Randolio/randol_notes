Config = {}

Config.PrivateNotes = true -- If set to true, only the player who created the note can see it. If set to false, everyone can see it.

function ToggleAnimation(bool)
    if bool then
        exports.scully_emotemenu:PlayByCommand('notepad') -- You'll have to change to whatever emote resource you use. 
    else
        exports.scully_emotemenu:CancelAnimation()
    end
end

QBCore = exports['qb-core']:GetCoreObject()