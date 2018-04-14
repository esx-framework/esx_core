description 'esx_drugs'

version '1.0.0'

server_scripts {

  '@es_extended/locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/sv.lua',
  'server/esx_drugs_sv.lua',
  'config.lua'

}

client_scripts {

  '@es_extended/locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/sv.lua',
  'config.lua',
  'client/esx_drugs_cl.lua'

}
