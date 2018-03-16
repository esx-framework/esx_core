resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

description 'ES Extended'

version '1.0.13'

server_scripts {
  '@async/async.lua',
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'locale.lua',
  'locales/de.lua',
  'locales/br.lua',
  'locales/fr.lua',
  'locales/en.lua',
  'locales/sv.lua',
  'config.weapons.lua',
  'server/common.lua',
  'server/classes/player.lua',
  'server/functions.lua',
  'server/paycheck.lua',
  'server/main.lua',
  'server/commands.lua'
}

client_scripts {
  'config.lua',
  'locale.lua',
  'locales/de.lua',
  'locales/br.lua',
  'locales/fr.lua',
  'locales/en.lua',
  'locales/sv.lua',
  'config.weapons.lua',
  'client/common.lua',
  'client/entityiter.lua',
  'client/functions.lua',
  'client/wrapper.lua',
  'client/main.lua'
}

ui_page {
  'html/ui.html'
}

files {
  'html/ui.html',

  'html/css/app.css',

  'html/js/mustache.min.js',
  'html/js/wrapper.js',
  'html/js/app.js',

  'html/fonts/pdown.ttf',
  'html/fonts/bankgothic.ttf',

  'html/img/cursor.png',
  'html/img/keys/enter.png',
  'html/img/keys/return.png',

  'html/img/accounts/bank.png',
  'html/img/accounts/black_money.png'
}

exports {
  'getSharedObject'
}

server_exports {
  'getSharedObject'
}

dependencies {
  'essentialmode'
}
