local PROP_NOTEPAD, PROP_PENCIL

local function toggleAnimation(bool)
    if bool then
        lib.requestAnimDict('missheistdockssetup1clipboard@base', 2000)
        local coords = GetEntityCoords(cache.ped)
        PROP_NOTEPAD = CreateObject(`prop_notepad_01`, coords, true, true, true)
        PROP_PENCIL = CreateObject(`prop_pencil_01`, coords, true, true, true)
        AttachEntityToEntity(PROP_NOTEPAD, cache.ped, GetPedBoneIndex(cache.ped, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true)
        AttachEntityToEntity(PROP_PENCIL, cache.ped, GetPedBoneIndex(cache.ped, 58866), 0.11, -0.02, 0.001, -120.0, 0.0, 0.0, true, true, false, true, 1, true)
        TaskPlayAnim(cache.ped, 'missheistdockssetup1clipboard@base', 'base', 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        RemoveAnimDict('missheistdockssetup1clipboard@base')
    else
        DetachEntity(PROP_NOTEPAD, true, true)
        DeleteEntity(PROP_NOTEPAD)
        DetachEntity(PROP_PENCIL, true, true)
        DeleteEntity(PROP_PENCIL)
        PROP_NOTEPAD, PROP_PENCIL = nil
        StopAnimTask(cache.ped, 'missheistdockssetup1clipboard@base', 'base', 5.0)
    end
end

local function closeNotepad()
    toggleAnimation(false)
    lib.hideContext()
end

local function manageNotes(data, noteid)
    local manageNotes = 'manage_notes'
    local notes_manage = {
        id = manageNotes,
        title = 'Manage Notes',
        onExit = function()
            closeNotepad()
        end,
        options = {
            {
                title = 'Delete Note',
                description = ('Delete note #%s'):format(data.id),
                icon = 'fa-solid fa-trash',
                onSelect = function()
                    TriggerServerEvent('randol_notes:server:deleteNote', data, noteid)
                    closeNotepad()
                end,
            },
            {
                title = 'Rip Out Note',
                description = ('Rip out note #%s and give to someone.'):format(data.id),
                icon = 'fa-solid fa-trash',
                onSelect = function()
                    TriggerServerEvent('randol_notes:server:ripNote', data, noteid)
                    closeNotepad()
                end,
            },
        }
    }
    lib.registerContext(notes_manage)
    lib.showContext(manageNotes)
end

local function notepadTask(task, noteid)
    if task == 'view' then
        local data = lib.callback.await('randol_notes:server:getNotes', false, noteid)
        local viewNotes = {}
        for i = 1, #data do
            local v = data[i]
            local test = v.text
            if string.len(v.text) > 10 then test = string.sub(v.text, 1, 10) .. '..' end
            local signed = (v.signed and 'Signed') or 'Unsigned'
            viewNotes[#viewNotes+1] = {
                title = test,
                description = ('%s [%s]'):format(v.date, signed),
                icon = 'fa-solid fa-note-sticky',
                onSelect = function()
                    manageNotes(v, noteid)
                end,
                metadata = {
                    {label = 'Note', value = v.text},
                },
            }
        end
        lib.registerContext({ id = 'noteMenu2', title = 'Saved Notes', onExit = function() closeNotepad() end, options = viewNotes })
        lib.showContext('noteMenu2')
    elseif task == 'new' then
        local input = lib.inputDialog('New Note', {
            {
                type = 'textarea',
                label = 'Write your message below.',
                required = true,
                placeholder = 'Met up with all the homies today and kissed them at the park. Spicy.'
            },
            {type = 'checkbox', label = 'Sign the note?'},
            {type = 'checkbox', label = 'Tear out?'},
        })
        toggleAnimation(false)
        if not input then return end
        local message, signed, tear = input[1], input[2], input[3]
        if tear then
            TriggerServerEvent('randol_notes:server:newTornNote', message, signed)
        else
            TriggerServerEvent('randol_notes:server:newNote', message, signed, noteid)
        end
    end
end

local function openNotepad(noteid)
    toggleAnimation(true)
    local some_id = 'notepadinit'
    local notepadMenu = {
        id = some_id,
        title = 'Notebook',
        onExit = function() closeNotepad() end,
        options = {
            {
                title = 'My Notes',
                description = 'View my notes.',
                icon = 'fa-solid fa-note-sticky',
                onSelect = function()
                    notepadTask('view', noteid)
                end,
            },
            {
                title = 'New Note',
                description = 'Write a new note to save.',
                icon = 'fa-solid fa-pencil',
                onSelect = function()
                    notepadTask('new', noteid)
                end,
            },
        }
    }
    lib.registerContext(notepadMenu)
    lib.showContext(some_id)
end

RegisterNetEvent('randol_notes:client:useItem', function(noteid)
    if GetInvokingResource() then return end
    openNotepad(noteid)
end)