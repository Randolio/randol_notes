local ox_inv = exports.ox_inventory

local function generateNotepadId()
    local characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local gen = ""

    for i = 1, 8 do
        local randomChar = math.random(1, #characters)
        gen = gen..string.sub(characters, randomChar, randomChar)
    end
    local result = MySQL.query.await('SELECT noteid FROM rnotes WHERE noteid = ?', {gen})
    return (result[1] and generateNotepadId()) or gen
end

exports('notepad', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local metadata = inventory.items[slot].metadata
        if metadata.noteid then
            TriggerClientEvent("randol_notes:client:useItem", inventory.id, metadata.noteid)
        end
    end
end)

lib.callback.register('randol_notes:server:getNotes', function(source, noteid)
    local src = source
    local player = GetPlayer(src)
    local notesData = {}
    local result = MySQL.query.await('SELECT notes FROM rnotes WHERE noteid = ?', {noteid})

    if result and result[1] then
        notesData = json.decode(result[1].notes)
        table.sort(notesData, function(a, b)
            return a.date > b.date
        end)
    end
    return notesData
end)

RegisterNetEvent('randol_notes:server:newNote', function(note, isSigned, noteid)
    local src = source
    local player = GetPlayer(src)
    local currentDate = os.date("%d-%m-%Y")
    local existingNotes = {}
    local result = MySQL.query.await('SELECT notes FROM rnotes WHERE noteid = ?', {noteid})

    if result and result[1] then
        existingNotes = json.decode(result[1].notes)

        local newNote = { id = #existingNotes + 1, text = note, signed = isSigned, date = currentDate }
        existingNotes[#existingNotes+1] = newNote 

        MySQL.update('UPDATE rnotes SET notes = ? WHERE noteid = ?', {json.encode(existingNotes), noteid})
        DoNotification(src, 'New note added with ID ' .. newNote.id .. ': ' .. note, 'success')
        Wait(500)
        TriggerClientEvent("randol_notes:client:useItem", src, noteid)
    end
end)

RegisterNetEvent('randol_notes:server:deleteNote', function(data, noteid)
    local src = source
    local player = GetPlayer(src)
    local noteId = tonumber(data.id)
    local result = MySQL.query.await('SELECT notes FROM rnotes WHERE noteid = ?', {noteid})
    local existingNotes = {}
    if result[1] then
        local removed = false
        existingNotes = json.decode(result[1].notes)

        for i, note in ipairs(existingNotes) do
            if note.id == noteId then
                table.remove(existingNotes, i)
                removed = true
                break
            end
        end
        if removed then
            MySQL.update('UPDATE rnotes SET notes = ? WHERE noteid = ?', {json.encode(existingNotes), noteid})
            DoNotification(src, 'Successfully deleted note with ID ' .. noteId, 'success')
            Wait(500)
            TriggerClientEvent("randol_notes:client:useItem", src, noteid)
        end
    end
end)

RegisterNetEvent('randol_notes:server:newTornNote', function(note, isSigned)
    local src = source
    local player = GetPlayer(src)
    local name = (isSigned and GetCharacterName(player)) or 'Unsigned'
    local message = note
    local currentDate = os.date("%d-%m-%Y")
    local date = currentDate
    local description = ('%s | %s\n\nNote: %s'):format(date, name, message)
    local metadata = { note = message, description = description, }
    ox_inv:AddItem(src, 'tornnote', 1, metadata)
end)

RegisterNetEvent('randol_notes:server:ripNote', function(data, noteid)
    local src = source
    local player = GetPlayer(src)
    local name = (data.signed and GetCharacterName(player)) or 'Unsigned'
    local message = data.text
    local date = data.date
    local description = ('%s | %s\n\nNote: %s'):format(date, name, message)
    local metadata = { note = message, description = description, }

    local result = MySQL.query.await('SELECT notes FROM rnotes WHERE noteid = ?', {noteid})
    local existingNotes = {}

    if result[1] then
        local removed = false
        existingNotes = json.decode(result[1].notes)

        for i, note in ipairs(existingNotes) do
            if note.id == data.id then
                table.remove(existingNotes, i)
                removed = true
                break
            end
        end
        if removed then
            MySQL.update('UPDATE rnotes SET notes = ? WHERE noteid = ?', {json.encode(existingNotes), noteid})
            DoNotification(src, "Note successfully ripped out.", "success")
            ox_inv:AddItem(src, 'tornnote', 1, metadata)
        end
    end
end)

local NOTEPAD_HOOK = ox_inv:registerHook('createItem', function(payload)
    local metadata = payload.metadata
    if metadata.unique then return metadata end

    local player = GetPlayer(payload.inventoryId)
    local cid = GetPlyIdentifier(player)
    local charname = GetCharacterName(player)

    metadata.noteid = generateNotepadId()
    metadata.unique = true
    metadata.description = ('Barcode: %s\n\nOwner: %s'):format(metadata.noteid, charname)
    MySQL.insert.await('INSERT INTO rnotes (citizenid, notes, noteid) VALUES (?, ?, ?)', {cid, json.encode({}), metadata.noteid})

    return metadata
end, {
    print = false,
    itemFilter = {
        notepad = true
    }
})

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    MySQL.query([=[
        CREATE TABLE IF NOT EXISTS `rnotes` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `noteid` varchar(50) NOT NULL DEFAULT '0',
        `citizenid` varchar(100) NOT NULL DEFAULT '0',
        `notes` longtext NOT NULL,
        PRIMARY KEY (`id`));
    ]=])
end)