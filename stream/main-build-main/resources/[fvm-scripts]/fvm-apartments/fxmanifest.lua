fx_version 'cerulean'
game 'gta5'

shared_scripts {
    '@fvm-core/import.lua',
	'config.lua',
}

server_scripts {
	"server/main.lua",
}

client_scripts {
	"client/main.lua",
	"client/gui.lua",
}

lua54 'yes'