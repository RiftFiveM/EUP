fx_version 'adamant'
game 'gta5'

shared_scripts {
    '@fvm-core/import.lua',
}

client_scripts {
	'NativeUI.lua',
	'config.lua',
	'client/AnimationList.lua',
	'client/Emote.lua',
	'client/EmoteMenu.lua',
	'client/Ragdoll.lua',
	'client/Walk.lua',
}

server_scripts {
	'server/main.lua',
}