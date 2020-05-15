local self = ESX.Modules['menu_default']

AddEventHandler('esx:nui_ready', function()
  ESX.CreateFrame('menu_default', 'nui://' .. GetCurrentResourceName() .. '/modules/menu_default/data/html/ui.html')
end)

ESX.Modules['input'].On('pressed', 0, 18, function(lastTime)
	if (GetGameTimer() - lastTime) < 150 then return end
	ESX.SendFrameMessage('menu_default', {action = 'controlPressed', control = 'ENTER'})
end)

ESX.Modules['input'].On('pressed', 0, 177, function(lastTime)
	if (GetGameTimer() - lastTime) < 150 then return end
	ESX.SendFrameMessage('menu_default', {action  = 'controlPressed', control = 'BACKSPACE'})
end)

ESX.Modules['input'].On('pressed', 0, 27, function(lastTime)
	if (GetGameTimer() - lastTime) < 300 then return end
	ESX.SendFrameMessage('menu_default', {action  = 'controlPressed', control = 'TOP'})
end)

ESX.Modules['input'].On('pressed', 0, 173, function(lastTime)
	if (GetGameTimer() - lastTime) < 300 then return end
	ESX.SendFrameMessage('menu_default', {action  = 'controlPressed', control = 'DOWN'})
end)

ESX.Modules['input'].On('pressed', 0, 174, function(lastTime)
	if (GetGameTimer() - lastTime) < 300 then return end
	ESX.SendFrameMessage('menu_default', {action  = 'controlPressed', control = 'LEFT'})
end)

ESX.Modules['input'].On('pressed', 0, 175, function(lastTime)
	if (GetGameTimer() - lastTime) < 300 then return end
	ESX.SendFrameMessage('menu_default', {action  = 'controlPressed', control = 'RIGHT'})
end)


AddEventHandler('menu_default:message:menu_submit', function(data)
	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)

	if menu.submit ~= nil then
		menu.submit(data, menu)
	end
end)

AddEventHandler('menu_default:message:menu_cancel', function(data)

	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)

	if menu.cancel ~= nil then
		menu.cancel(data, menu)
	end
end)

AddEventHandler('menu_default:message:menu_change', function(data)
	local menu = ESX.UI.Menu.GetOpened(self.MenuType, data._namespace, data._name)

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
end)
