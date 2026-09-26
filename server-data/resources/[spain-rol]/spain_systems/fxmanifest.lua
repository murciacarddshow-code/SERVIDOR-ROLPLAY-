fx_version 'cerulean'
game 'gta5'

author 'Antigravity - Spain Rol System'
description 'Sistemas exclusivos de Spain Rol: Drogas, Mercado Negro, Blanqueo de Dinero, DNI Espanol y Herramientas Policiales CNP'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
    'config_jobs.lua'
}

client_scripts {
    'client/cl_drugs.lua',
    'client/cl_blackmarket.lua',
    'client/cl_moneylaundry.lua',
    'client/cl_police_tools.lua',
    'client/cl_dni.lua',
    'client/cl_nonpc.lua',
    'client/cl_safezones.lua',
    'client/cl_garages_blips.lua',
    'client/cl_admin_keybind.lua',
    'client/cl_interactive_npcs.lua',
    'client/cl_tuning.lua',
    'client/cl_mechanic_tablet.lua',
    'client/cl_yacht_heist.lua',
    'client/cl_drug_routes.lua',
    'client/cl_job_center.lua',
    'client/cl_jobs_engine.lua',
    'client/cl_pokemon.lua',
    'client/cl_chat_rp.lua',
    'client/cl_player_ids.lua',
    'client/cl_ipl_loader.lua',
    'client/cl_police_markers.lua',
    'client/cl_police_dni_npc.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua',
    'server/sv_job_center.lua',
    'server/sv_jobs_engine.lua',
    'server/sv_pokemon.lua',
    'server/sv_chat_rp.lua',
    'server/sv_police_dni.lua',
    'server/sv_police_markers.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js'
}

lua54 'yes'
