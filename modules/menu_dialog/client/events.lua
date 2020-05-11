local self = ESX.Modules['menu_dialog']

AddEventHandler('esx:nui_ready', function()
  ESX.CreateFrame('menu_dialog', 'nui://' .. GetCurrentResourceName() .. '/modules/menu_dialog/data/html/ui.html')
end)

AddEventHandler('menu_dialog:message:menu_submit', function(data)

	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)
	local cancel = false

	if menu.submit then
		-- is the submitted data a number?
		if tonumber(data.value) then
			data.value = ESX.Math.Round(tonumber(data.value))

			-- check for negative value
			if tonumber(data.value) <= 0 then
				cancel = true
			end
		end

		data.value = ESX.Math.Trim(data.value)

		-- don't submit if the value is negative or if it's 0
		if cancel then
			ESX.ShowNotification('That input is not allowed!')
		else
			menu.submit(data, menu)
		end
	end
end)

AddEventHandler('menu_dialog:message:menu_cancel', function(data)
	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)

	if menu.cancel ~= nil then
		menu.cancel(data, menu)
	end
end)

AddEventHandler('menu_dialog:message:menu_change', function(data)
	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)

	if menu.change ~= nil then
		menu.change(data, menu)
	end
end)