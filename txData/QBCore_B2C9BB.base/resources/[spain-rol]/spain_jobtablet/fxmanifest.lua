fx_version 'cerulean'
game 'gta5'

author 'Spain Rol v2.0 - Antigravity'
description 'Tablet de Trabajo Universal y Facciones para todos los Empleos de Spain Rol'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

lua54 'yes'
