fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Spain Rol Team'
description 'Tablet Policial y Sanitaria MDT - Estilo Origin'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_ems.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua'
}

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js'
}
