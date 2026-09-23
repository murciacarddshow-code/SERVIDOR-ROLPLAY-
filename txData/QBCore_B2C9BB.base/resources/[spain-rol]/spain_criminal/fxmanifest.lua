fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Antigravity - Spain Rol Official'
description 'Origin Tablet Criminal: Jerarquía de Organizaciones, Armería Clandestina, Laboratorio de Drogas y Garajes Privados'
version '2.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_garages.lua',
    'client/cl_npc.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}
