fx_version 'adamant'

game 'gta5'

ui_page "html/index.html"

shared_scripts {
    '@fvm-core/import.lua',
}

server_scripts {
	"server/main.lua"
}

client_scripts {
	"client/main.lua"
}

files {
	"html/*"
}