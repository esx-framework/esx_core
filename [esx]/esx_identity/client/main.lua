local loadingScreenFinished = false

RegisterNetEvent('esx_identity:alreadyRegistered')
AddEventHandler('esx_identity:alreadyRegistered', function()
	while not loadingScreenFinished do
		Wait(100)
	end

	TriggerEvent('esx_skin:playerRegistered')
end)

AddEventHandler('esx:loadingScreenOff', function()
	loadingScreenFinished = true
end)

if not Config.UseDeferrals then
	local guiEnabled, isDead = false, false

	AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)
	AddEventHandler('esx:onPlayerDeath', function(data) isDead = true end)

	function EnableGui(state)
		SetNuiFocus(state, state)
		guiEnabled = state
		if guiEnabled then
			guiEnabled()
		end

		SendNUIMessage({
			type = "enableui",
			enable = state
		})
	end

	RegisterNetEvent('esx_identity:showRegisterIdentity')
	AddEventHandler('esx_identity:showRegisterIdentity', function()
		TriggerEvent('esx_skin:resetFirstSpawn')

		if not isDead then
			EnableGui(true)
		end
	end)

	RegisterNUICallback('register', function(data, cb)
		ESX.TriggerServerCallback('esx_identity:registerIdentity', function(callback)
			if callback then
				ESX.ShowNotification(_U('thank_you_for_registering'))
				EnableGui(false)
				if not ESX.GetConfig().Multichar then TriggerEvent('esx_skin:playerRegistered') end
			else
				ESX.ShowNotification(_U('registration_error'))
			end
		end, data)
	end)

	guiEnabled = function()
		CreateThread(function()
			while guiEnabled do
				Wait(1)

				DisableControlAction(0, 1,   true) -- LookLeftRight
				DisableControlAction(0, 2,   true) -- LookUpDown
				DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
				DisableControlAction(0, 142, true) -- MeleeAttackAlternate
				DisableControlAction(0, 30,  true) -- MoveLeftRight
				DisableControlAction(0, 31,  true) -- MoveUpDown
				DisableControlAction(0, 21,  true) -- disable sprint
				DisableControlAction(0, 24,  true) -- disable attack
				DisableControlAction(0, 25,  true) -- disable aim
				DisableControlAction(0, 47,  true) -- disable weapon
				DisableControlAction(0, 58,  true) -- disable weapon
				DisableControlAction(0, 263, true) -- disable melee
				DisableControlAction(0, 264, true) -- disable melee
				DisableControlAction(0, 257, true) -- disable melee
				DisableControlAction(0, 140, true) -- disable melee
				DisableControlAction(0, 141, true) -- disable melee
				DisableControlAction(0, 143, true) -- disable melee
				DisableControlAction(0, 75,  true) -- disable exit vehicle
				DisableControlAction(27, 75, true) -- disable exit vehicle
			end
		end)
	end
end
