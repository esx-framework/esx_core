
local self = ESX.Modules['menu_dialog']

ESX.UI.Menu.RegisterType(self.MenuType, self.openMenu, self.closeMenu)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if ESX.Table.SizeOf(self.OpenedMenus) > 0 then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 12, true) -- WeaponWheelUpDown
			DisableControlAction(0, 14, true) -- WeaponWheelNext
			DisableControlAction(0, 15, true) -- WeaponWheelPrev
			DisableControlAction(0, 16, true) -- SelectNextWeapon
			DisableControlAction(0, 17, true) -- SelectPrevWeapon
		else
			Citizen.Wait(500)
		end
	end
end)
