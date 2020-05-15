ESX.Modules['menu_dialog'] = {};
local self = ESX.Modules['menu_dialog']
local Input = ESX.Modules['input']

self.Timeouts    = {}
self.OpenedMenus = {}
self.MenuType    = 'dialog'

self.RegisterControls = function()

  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.LOOK_LR)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.LOOK_UD)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.MELEE_ATTACK_ALTERNATE)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.VEH_MOUSE_CONTROL_OVERRIDE)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_UD)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_NEXT)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_PREV)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.SELECT_NEXT_WEAPON)
  Input.RegisterControl(Input.Groups.LOOK, Input.Controls.SELECT_PREV_WEAPON)

end

self.EnableControls = function()

  Input.EnableControl(Input.Groups.LOOK, Input.Controls.LOOK_LR)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.LOOK_UD)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.MELEE_ATTACK_ALTERNATE)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.VEH_MOUSE_CONTROL_OVERRIDE)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_UD)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_NEXT)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_PREV)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.SELECT_NEXT_WEAPON)
  Input.EnableControl(Input.Groups.LOOK, Input.Controls.SELECT_PREV_WEAPON)

end

self.DisableControls = function()

  Input.DisableControl(Input.Groups.LOOK, Input.Controls.LOOK_LR)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.LOOK_UD)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.MELEE_ATTACK_ALTERNATE)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.VEH_MOUSE_CONTROL_OVERRIDE)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_UD)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_NEXT)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.WEAPON_WHEEL_PREV)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.SELECT_NEXT_WEAPON)
  Input.DisableControl(Input.Groups.LOOK, Input.Controls.SELECT_PREV_WEAPON)

end

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

  self.DisableControls()

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
    self.EnableControls()
		SetNuiFocus(false)
	end

end

