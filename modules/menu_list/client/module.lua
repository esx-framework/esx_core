ESX.Modules['menu_list'] = {};
local self = ESX.Modules['menu_list']

self.MenuType    = 'list'
self.OpenedMenus = {}

self.openMenu = function(namespace, name, data)

	self.OpenedMenus[namespace .. '_' .. name] = true

	ESX.SendFrameMessage('menu_list', {
		action    = 'openMenu',
		namespace = namespace,
		name      = name,
		data      = data
	})

	ESX.SetTimeout(200, function()
		ESX.FocusFrame('menu_list', true, true)
	end)

end

self.closeMenu = function(namespace, name)

	self.OpenedMenus[namespace .. '_' .. name] = nil
	local OpenedMenuCount = 0

	ESX.SendFrameMessage('menu_list', {
		action    = 'closeMenu',
		namespace = namespace,
		name      = name,
		data      = data
	})

	for k,v in pairs(self.OpenedMenus) do
		if v == true then
			OpenedMenuCount = OpenedMenuCount + 1
		end
	end

	if OpenedMenuCount == 0 then
		SetNuiFocus(false)
	end

end

