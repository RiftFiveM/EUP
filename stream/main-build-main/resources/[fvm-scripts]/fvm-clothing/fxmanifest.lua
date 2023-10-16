fx_version 'adamant'

game 'gta5'

ui_page "html/index.html"

shared_scripts {
    '@fvm-core/import.lua',
	'config.lua',
}

server_scripts {
	"server/main.lua",
}

client_scripts {
	"client/main.lua",
}

files {
	'html/index.html',
	'html/style.css',
	'html/reset.css',
	'html/script.js',
}