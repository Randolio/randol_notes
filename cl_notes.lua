
local function CloseNotepad()
    ToggleAnimation(false)
    lib.hideContext()
end

local function ManageNote(data, noteid)
    local manageNotes = "manage_notes"
    local notes_manage = {
        id = manageNotes,
        canClose = false,
        title = "Manage Notes",
        options = {
            {
                title = "Delete Note",
                description = "Delete note #"..data.id,
                icon = "fa-solid fa-trash",
                onSelect = function()
                    TriggerServerEvent('randol_notes:server:deleteNote', data, noteid)
                    CloseNotepad()
                end,
            },
            {
                title = "Rip Out Note",
                description = "Rip out note #"..data.id.." and give to someone.",
                icon = "fa-solid fa-trash",
                onSelect = function()
                    TriggerServerEvent('randol_notes:server:ripNote', data, noteid)
                    CloseNotepad()
                end,
            },
            {
                title = "Close",
                icon = "fa-solid fa-xmark",
                onSelect = function()
                    CloseNotepad()
                end,
            },
        }
    }
    lib.registerContext(notes_manage)
    lib.showContext(manageNotes)
end

local function NotepadTask(task, noteid)
    if task == 'view' then
        local data = lib.callback.await('randol_notes:server:getNotes', false, noteid)
        if data then
            local viewNotes = {}
            for i=1, #data do
                local v = data[i]
                local test = v.text
                if string.len(v.text) > 10 then test = string.sub(v.text, 1, 10) .. ".." end
                local signed = (v.signed and 'Signed') or 'Unsigned'
                viewNotes[#viewNotes+1] = {
                    title = test,
                    description = ""..v.date.." ["..signed.."]",
                    icon = "fa-solid fa-note-sticky",
                    onSelect = function()
                        ManageNote(v, noteid)
                    end,
                    metadata = {
                        {label = 'Note', value = v.text},
                    },
                }
            end
            viewNotes[#viewNotes+1] = {
                title = "Close",
                icon = "fa-solid fa-xmark",
                onSelect = function()
                    CloseNotepad()
                end,
            }
            lib.registerContext({ id = 'noteMenu2', title = "Saved Notes", canClose = false, options = viewNotes })
            lib.showContext('noteMenu2')
        else
            CloseNotepad()
            QBCore.Functions.Notify('You don\'t have any notes saved.', 'error')
            return
        end
    elseif task == 'new' then
        local input = lib.inputDialog("New Note", {
            {
                type = "textarea",
                label = "Write your message below.",
                required = true,
                placeholder = "Met up with all the homies today and kissed them at the park. Spicy."
            },
            {type = 'checkbox', label = 'Sign the note?'},
        })
        if not input then ToggleAnimation(false) return end
        local message = input[1]
        local signed = input[2]
        TriggerServerEvent('randol_notes:server:newNote', message, signed, noteid)
        ToggleAnimation(false)
    elseif task == 'newtorn' then
        local input = lib.inputDialog("Create Torn Note", {
            {
                type = "textarea",
                label = "Write your message below.",
                required = true,
                placeholder = "Met up with all the homies today and kissed them at the park. Spicy."
            },
            {type = 'checkbox', label = 'Sign the note?'},
        })
        if not input then ToggleAnimation(false) return end
        local message = input[1]
        local signed = input[2]
        TriggerServerEvent('randol_notes:server:newTornNote', message, signed)
        ToggleAnimation(false)
    end
end

local function OpenNotepad(noteid)
    ToggleAnimation(true)
    local some_id = "notepadinit"
    local notepadMenu = {
        id = some_id,
        canClose = false,
        title = "Notebook",
        options = {
            {
                title = "My Notes",
                description = "View my notes.",
                icon = "fa-solid fa-note-sticky",
                onSelect = function()
                    NotepadTask('view', noteid)
                end,
            },
            {
                title = "New Note",
                description = "Write a new note to save.",
                icon = "fa-solid fa-pencil",
                onSelect = function()
                    NotepadTask('new', noteid)
                end,
            },
            {
                title = "New Note (Torn)",
                description = "Write a new note to tear out straight away",
                icon = "fa-solid fa-pencil",
                onSelect = function()
                    NotepadTask('newtorn')
                end,
            },
            {
                title = "Close",
                icon = "fa-solid fa-xmark",
                onSelect = function()
                    CloseNotepad()
                end,
            },
        }
    }
    lib.registerContext(notepadMenu)
    lib.showContext(some_id)
end

RegisterNetEvent("randol_notes:client:useItem", function(noteid)
    if GetInvokingResource() then return end
    OpenNotepad(noteid)
end)