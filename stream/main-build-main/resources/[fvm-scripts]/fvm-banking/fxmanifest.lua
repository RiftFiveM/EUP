fx_version 'adamant'

game 'gta5'

ui_page 'html/ui.html'
files {
	'html/ui.html',
	'html/pricedown.ttf',
	'html/bank-icon.png',
	'html/logo.png',
	'html/cursor.png',
	'html/styles.css',
	'html/scripts.js',
	'html/debounce.min.js'
}

shared_scripts {
    '@fvm-core/import.lua',
}

client_script "client.lua"
server_script "server.lua"
