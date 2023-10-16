fx_version 'adamant'

game 'gta5'

ui_page "html/index.html"

shared_scripts {
    '@fvm-core/import.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'server/main.lua',
}

files {
    'html/videos/*',
	'html/index.html',
	'html/style.css',
    'html/script.js',
}