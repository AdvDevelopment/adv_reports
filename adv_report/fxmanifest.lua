fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'adv_report'
description 'Report With ox_lib'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    'server.lua',
}

client_scripts {
    'client.lua',
}

escrow_ignore {
    'config.lua',
  }