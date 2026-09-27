fx_version 'cerulean'
game 'gta5'

author 'Antigravity - Spain Rol'
description 'The Diamond Casino & Resort - Ruleta Diaria 24h, Podio al Garaje, Cajero Fichas & VIP 50k, Ruleta Normal (10k) y Premium (100k), Tragaperras Jackpot'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/cl_main.lua',
    'client/cl_wheel.lua',
    'client/cl_cashier.lua',
    'client/cl_roulette.lua',
    'client/cl_slots.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_wheel.lua',
    'server/sv_roulette.lua',
    'server/sv_slots.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}
