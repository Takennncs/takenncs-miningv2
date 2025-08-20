fx_version 'cerulean'
game 'gta5'

author 'takenncs'
description 'Mining V2'
version '2.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', 
    'server.lua'
}

dependencies {
    'ox_inventory',
    'ox_target',
    'ox_lib'
}
