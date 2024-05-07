# Showcase:
- https://streamable.com/hksbds

# Requirements:
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [ox_lib](https://github.com/overextended/ox_lib)

# Items to add to ox inventory

```lua
["notepad"] = {
    label = "Notepad",
    weight = 0,
    stack = false,
    close = true,
    consume = 0,
    description = "Sometimes handy to remember something :)",
    server = {
        export = 'randol_notes.notepad',
    },
},

["tornnote"] = {
    label = "Torn Note",
    weight = 0,
    stack = false,
    close = false,
},
```

# 
Edit: The SQL is automatically inserted into your database on resource start to save you an extra step.

It will automatically assign an id to the notepad and insert a row into the database for it when it's created.

I DO NOT PROVIDE SUPPORT CAUSE IT'S A FREE SCRIPT AND I DON'T HAVE THE BRAIN CAPACITY TO DEAL WITH DUMB PEOPLE. IT WORKS ON MY MACHINE SO.

**IMPORTANT**: 
If renaming the notepad item to something else, make sure you also change it in the NOTEPAD_HOOK:

```lua
local NOTEPAD_HOOK = ox_inv:registerHook('createItem', function(payload)
    local metadata = payload.metadata
    if metadata.unique then
        return metadata
    end
    local Player = QBCore.Functions.GetPlayer(payload.inventoryId)
    local charname = Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
    metadata.noteid = GenerateNotepadId()
    metadata.unique = true
    metadata.description = ('Barcode: %s\n\nOwner: %s'):format(metadata.noteid, charname)
    MySQL.insert.await('INSERT INTO rnotes (citizenid, notes, noteid) VALUES (?, ?, ?)', {Player.PlayerData.citizenid, json.encode({}), metadata.noteid})
    return metadata
end, {
    print = false,
    itemFilter = {
        notepad = true -- if you rename your item to 'penis', it would have to be changed here to: penis = true
    }
})
```

**You have permission to use this in your server and edit for your personal needs but are not allowed to redistribute.**
