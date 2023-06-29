local Timeouts, OpenedMenus, MenuType = {}, {}, 'dialog'

local function openMenu(namespace, name, data)
	for i = 1, #Timeouts, 1 do
		ESX.ClearTimeout(Timeouts[i])
	end

	OpenedMenus[namespace .. '_' .. name] = true

	SendNUIMessage({
		action = 'openMenu',
		namespace = namespace,
		name = name,
		data = data
	})

	local timeoutId = ESX.SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)

	table.insert(Timeouts, timeoutId)
end

local function closeMenu(namespace, name)
	OpenedMenus[namespace .. '_' .. name] = nil

	SendNUIMessage({
		action = 'closeMenu',
		namespace = namespace,
		name = name,
	})

	if not next(OpenedMenus) then
		SetNuiFocus(false)
	end
end

ESX.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

AddEventHandler('esx_menu_dialog:message:menu_submit', function(data)
	local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
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

AddEventHandler('esx_menu_dialog:message:menu_cancel', function(data)
	local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

	if menu.cancel ~= nil then
		menu.cancel(data, menu)
	end
end)

AddEventHandler('esx_menu_dialog:message:menu_change', function(data)
	local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

	if menu.change ~= nil then
		menu.change(data, menu)
	end
end)
