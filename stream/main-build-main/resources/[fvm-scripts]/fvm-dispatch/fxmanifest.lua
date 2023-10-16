fx_version 'adamant'

game 'gta5'

files {
    'html/index.html',
    'html/js/app.js',
    'html/css/app.css',
}

shared_scripts {
    '@fvm-core/import.lua',
}

client_script 'cl_dispatch.lua'
server_script 'sv_dispatch.lua'

ui_page 'html/index.html'