fx_version 'cerulean'
game 'gta5'

author 'Antigravity - Spain Rol System'
description 'Estudio de Grabacion Profesional A-Records: DAW NUI, Cabina Vocal, Mesa de Mezclas, Composicion, Prensado de Vinilos y Billboard'
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
    'html/js/app.js',
    'html/js/audio_engine.js',
    'html/js/visualizer.js'
}

lua54 'yes'
