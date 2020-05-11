ESX.Modules['menu_dialog'] = {};
local self = ESX.Modules['menu_dialog']

self.Timeouts    = {}
self.OpenedMenus = {}
self.MenuType    = 'dialog'

self.openMenu = function(namespace, name, data)
	
	for i=1, #self.Timeouts, 1 do
		ESX.ClearTimeout(self.Timeouts[i])
	end

	self.OpenedMenus[namespace .. '_' .. name] = true

	ESX.SendFrameMessage('menu_dialog', {
		action = 'openMenu',
		namespace = namespace,
		name = name,
		data = data
	})

	local timeoutId = ESX.SetTimeout(200, function()
		ESX.FocusFrame('menu_dialog', true, true)
	end)

	table.insert(self.Timeouts, timeoutId)
end

self.closeMenu = function(namespace, name)
	
	self.OpenedMenus[namespace .. '_' .. name] = nil

	ESX.SendFrameMessage('menu_dialog', {
		action = 'closeMenu',
		namespace = namespace,
		name = name,
		data = data
	})

	if ESX.Table.SizeOf(self.OpenedMenus) == 0 then
		SetNuiFocus(false)
	end

end

