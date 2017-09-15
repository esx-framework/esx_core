description 'ESX Whitelist'

version '1.0.0'

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  '@es_extended/locale.lua',
  'Config.lua',
  'locales/fr.lua',
  'server/main.lua',
  'server/commands.lua',
}
