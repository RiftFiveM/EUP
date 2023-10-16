fx_version 'adamant'

game 'gta5'

ui_page "html/index.html"

shared_scripts {
    '@fvm-core/import.lua',
	'config.lua',
}

client_scripts {
    'client/fleeca.lua',
    'client/pacific.lua',
    'client/powerstation.lua',
    'client/doors.lua',
    'client/paleto.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'html/*',
}
