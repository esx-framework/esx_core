server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/esx_jobs_sv.lua'
}

client_scripts {
	'config.lua',
	'jobs/fisherman.lua',
	'jobs/fuel.lua',
	'jobs/lumberjack.lua',
	'jobs/miner.lua',
	'jobs/reporter.lua',
	'jobs/slaughterer.lua',
	'jobs/textil.lua',
	'client/esx_jobs_cl.lua'
}

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/bankgothic.ttf',
	'html/pdown.ttf',
	'html/css/app.css',
	'html/scripts/mustache.min.js',
	'html/scripts/app.js',
	'html/img/keys/enter.png',
	'html/img/keys/return.png'
}