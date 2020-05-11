local self = ESX.Modules['menu_list']

AddEventHandler('esx:nui_ready', function()
	ESX.CreateFrame('menu_list', 'nui://' .. GetCurrentResourceName() .. '/modules/menu_list/data/html/ui.html')
end)

RegisterNUICallback('menu_list:menu_submit', function(data, cb)
	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)

	if menu.submit ~= nil then
		menu.submit(data, menu)
	end

	cb('OK')
end)

RegisterNUICallback('menu_list:menu_cancel', function(data, cb)
	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)

	if menu.cancel ~= nil then
		menu.cancel(data, menu)
	end

	cb('OK')
end)
