fx_version 'cerulean'
game 'gta5'

author 'Antigravity - Spain Rol System'
description 'Sistema de 3 Compra-Ventas con Jerarquia Empresarial, Tablet NUI Glassmorphism, Banco y Garajes'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/cl_main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

lua54 'yes'
