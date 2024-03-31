if not lib.checkDependency('ND_Core', '2.0.0') then return end

local NDCore = exports['ND_Core']

function DoNotification(text, nType)
    lib.notify({ title = 'Notification', description = text, type = nType, })
end