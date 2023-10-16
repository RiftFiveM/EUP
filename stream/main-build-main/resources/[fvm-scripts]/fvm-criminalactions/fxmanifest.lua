fx_version 'adamant'

game 'gta5'

shared_scripts {
    '@fvm-core/import.lua',
	'config_robberies.lua',
    'config_weapdealers.lua',
    '@fvm-houserobbery/config.lua',
}

client_scripts {
    'client/*',
}

server_scripts {
    'server/*',
}
