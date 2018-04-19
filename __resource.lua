-- https://wiki.fivem.net/wiki/Resource_manifest

resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Identity'

version '1.0.3'

client_script 'client/main.lua'

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"@es_extended/locale.lua",
	"server/main.lua"
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script.js',
	'html/style.css',
	'html/cursor.png'
}
