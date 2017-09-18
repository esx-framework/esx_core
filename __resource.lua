description 'ESX Whitelist'

version '1.0.2'

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  '@es_extended/locale.lua',
  'config.lua',
  'locales/en.lua',
  'locales/fr.lua',
  'server/main.lua',
  'server/commands.lua',
}
