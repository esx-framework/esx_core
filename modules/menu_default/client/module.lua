ESX.Modules['menu_default'] = {};
local self = ESX.Modules['menu_default']

self.GUI      = {}
self.GUI.Time = 0
self.MenuType = 'default'

self.OpenMenu = function(namespace, name, data)
	ESX.SendFrameMessage('menu_default', {
		action    = 'openMenu',
		namespace = namespace,
		name      = name,
		data      = data
	})
end

self.CloseMenu = function(namespace, name)
	ESX.SendFrameMessage('menu_default', {
		action = 'closeMenu',
		namespace = namespace,
		name = name,
		data = data
	})
end


