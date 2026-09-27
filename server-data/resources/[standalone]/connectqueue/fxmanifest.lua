fx_version 'cerulean'
game 'gta5'

shared_scripts {
    'server/sv_queue_config.lua'
}

server_scripts {
    'connectqueue.lua',
    'shared/sh_queue.lua'
}

client_scripts {
    'shared/sh_queue.lua'
}
