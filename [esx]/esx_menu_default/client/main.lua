local MenuType = 'default'

local function openMenu(namespace, name, data)
	SendNUIMessage({
		action = 'openMenu',
		namespace = namespace,
		name = name,
		data = data
	})
end

local function closeMenu(namespace, name)
	SendNUIMessage({
		action = 'closeMenu',
		namespace = namespace,
		name = name,
	})
end

ESX.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

RegisterNUICallback('menu_submit', function(data, cb)
	local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
	if menu.submit ~= nil then
		menu.submit(data, menu)
	end
	cb('OK')
end)

RegisterNUICallback('menu_cancel', function(data, cb)
	local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

	if menu.cancel ~= nil then
		menu.cancel(data, menu)
	end
	cb('OK')
end)

RegisterNUICallback('menu_change', function(data, cb)
	local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

	for i=1, #data.elements, 1 do
		menu.setElement(i, 'value', data.elements[i].value)

		if data.elements[i].selected then
			menu.setElement(i, 'selected', true)
		else
			menu.setElement(i, 'selected', false)
		end
	end

	if menu.change ~= nil then
		menu.change(data, menu)
	end
	cb('OK')
end)

RegisterCommand("ENTER", function()
    SendNUIMessage({action = "controlPressed", control = "ENTER"})
end)

RegisterKeyMapping("ENTER", "[ESX MENU DEFAULT] ENTER", "keyboard", "RETURN")

RegisterCommand("BACKSPACE", function()
    SendNUIMessage({action  = "controlPressed", control = "BACKSPACE"})
end)

RegisterKeyMapping("BACKSPACE", "[ESX MENU DEFAULT] BACKSPACE", "keyboard", "BACK")

RegisterCommand("TOP", function()
    SendNUIMessage({action  = "controlPressed", control = "TOP"})
end)

RegisterKeyMapping("TOP", "[ESX MENU DEFAULT] TOP", "keyboard", "UP")

RegisterCommand("DOWN", function()
    SendNUIMessage({action  = "controlPressed", control = "DOWN"})
end)

RegisterKeyMapping("DOWN", "[ESX MENU DEFAULT] DOWN", "keyboard", "DOWN")

RegisterCommand("LEFT", function()
    SendNUIMessage({action  = "controlPressed", control = "LEFT"})
end)

RegisterKeyMapping("LEFT", "[ESX MENU DEFAULT] LEFT", "keyboard", "LEFT")

RegisterCommand("RIGHT", function()
    SendNUIMessage({action  = "controlPressed", control = "RIGHT"})
end)

RegisterKeyMapping("RIGHT", "[ESX MENU DEFAULT] RIGHT", "keyboard", "RIGHT")
