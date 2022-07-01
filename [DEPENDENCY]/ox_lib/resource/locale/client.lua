local default = { 'en', 'fr', 'de', 'it', 'es', 'pt-BR', 'pl', 'ru', 'ko', 'zh-TW', 'ja', 'es-MX', 'zh-CN' }
local userLocale = GetResourceKvpString('locale') or default[GetCurrentLanguage() + 1]

local function loadLocale(locale, cb)
	if cb then cb(1) end
	local JSON = LoadResourceFile('ox_lib', ('locales/%s.json'):format(locale)) or LoadResourceFile('ox_lib', ('locales/en.json'):format(locale))

	SendNUIMessage({
		action = 'setLocale',
		data = json.decode(JSON)
	})

	SetResourceKvp('locale', locale)
	TriggerEvent('ox_lib:setLocale', locale)
end

RegisterNUICallback('getLocale', loadLocale)

RegisterNUICallback('closeSettings', function(_, cb)
	cb(1)
	SetNuiFocus(false, false)
end)

RegisterNUICallback('init', function(_, cb)
	cb(1)

	SendNUIMessage({
		action = 'loadLocales',
		data = GlobalState.locales
	})

	loadLocale(userLocale)
end)

RegisterCommand('ox_lib', function()
	SendNUIMessage({
		action = 'openSettings',
		data = GetResourceKvpString('locale') -- Sets the value for language select
	})
	SetNuiFocus(true, true)
end)

RegisterCommand('setlocale', function(_, args, _)
	if args?[1] then
		loadLocale(args[1])
	end
end, false)
