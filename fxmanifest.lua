fx_version 'cerulean'
game 'gta5'

name 'ravage_hud_3d'
author 'Glades'
description 'RAVAGE 3D Loot HUD'

ui_page 'html/ui.html'

files {
  'html/ui.html',
  'html/ui.css',
  'html/ui.js'
}

client_scripts {
  'config.lua',
  'client.lua'
}

escrow_ignore {
	'config.lua',
  'html/ui.css',
  'hrs_loot_adapter/*.lua',
	'hrs_loot_adapter/opensource/*.lua'
}