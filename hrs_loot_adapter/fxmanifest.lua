fx_version 'cerulean'

lua54 'yes'

game 'gta5'

description 'update 30/03/2023 better targets'

version '1.0'

client_scripts {
	'config.lua',
	'opensource/ESX_client.lua',
	'opensource/QB_client.lua',
	'opensource/client.lua',
	'opensource/im_adapter_client.lua',
	'escrow/client.lua'
}

server_scripts {
	'config.lua',
	'discordLogs/logs.lua',
	'opensource/ESX_server.lua',
	'opensource/QB_server.lua',
	'opensource/server.lua',
	'opensource/im_adapter_server.lua',
	'escrow/server.lua'
}

escrow_ignore {
	'config.lua',
	'discordLogs/logs.lua',
	'opensource/ESX_server.lua',
	'opensource/QB_server.lua',
	'opensource/ESX_client.lua',
	'opensource/QB_client.lua',
	'opensource/client.lua',
	'opensource/server.lua'
}

dependency '/assetpacks'server_scripts { '@mysql-async/lib/MySQL.lua' }