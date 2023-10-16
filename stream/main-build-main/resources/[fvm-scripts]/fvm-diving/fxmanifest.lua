fx_version 'adamant'

game 'gta5'

shared_scripts {
    '@fvm-core/import.lua',
	'config.lua',
}

server_scripts {
	'server/main.lua',
    'server/diving.lua',
}

client_scripts {
    'client/main.lua',
    'client/boatshop.lua',
    'client/diving.lua',
    'client/garage.lua',
    'client/gui.lua',
    'client/shop.lua'
}