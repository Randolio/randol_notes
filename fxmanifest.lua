fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Write notes script with metadata.'

shared_scripts { '@ox_lib/init.lua', 'shared.lua'}

client_scripts {'cl_notes.lua'}

server_scripts {'@oxmysql/lib/MySQL.lua', 'sv_notes.lua'}

lua54 'yes'
