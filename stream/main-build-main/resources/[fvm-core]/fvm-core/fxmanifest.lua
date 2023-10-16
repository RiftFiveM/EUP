fx_version 'adamant'

game 'gta5'

shared_scripts { 
	'import.lua',
	'config.lua',
	'shared.lua'
}

server_script {
	"server/main.lua",
	"server/functions.lua",
	"server/loops.lua",
	"server/player.lua",
	"server/events.lua",
	"server/commands.lua",
	"server/debug.lua",
}

client_script {
	"client/main.lua",
	"client/functions.lua",
	"client/loops.lua",
	"client/events.lua",
	"client/debug.lua",
	"client/modules/streaming.lua",
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/style.css',
	'html/*.js'
}

lua54 'yes'