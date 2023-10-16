fx_version 'adamant'

game 'gta5'

shared_scripts {
    '@fvm-core/import.lua',
	'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/deliveries.lua',
    'client/cornerselling.lua',
}

server_scripts {
    'server/main.lua',
    'server/deliveries.lua',
    'server/cornerselling.lua',
}

server_exports {
    'GetDealers'
}