-- internal variables
local hasAlreadyEnteredMarker, isInATMMarker, menuIsShowed = false, false, false

RegisterNetEvent('esx_atm:closeATM')
AddEventHandler('esx_atm:closeATM', function()
	SetNuiFocus(false)
	menuIsShowed = false
	SendNUIMessage({
		hideAll = true
	})
end)

RegisterNUICallback('escape', function(data, cb)
	TriggerEvent('esx_atm:closeATM')
	cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('esx_atm:deposit', data.amount)
	cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
	TriggerServerEvent('esx_atm:withdraw', data.amount)
	cb('ok')
end)

-- Create blips
Citizen.CreateThread(function()
	if not Config.EnableBlips then return end

	for _, ATMLocation in pairs(Config.ATMLocations) do
		ATMLocation.blip = AddBlipForCoord(ATMLocation)
		SetBlipSprite(ATMLocation.blip, Config.BlipSprite)
		SetBlipDisplay(ATMLocation.blip, 4)
		SetBlipScale(ATMLocation.blip, 0.9)
		SetBlipColour(ATMLocation.blip, 2)
		SetBlipAsShortRange(ATMLocation.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('atm_blip'))
		EndTextCommandSetBlipName(ATMLocation.blip)
	end
end)

-- Activate menu when player is inside marker
CreateThread(function()
	while true do
		sleep = 500
		local coords = GetEntityCoords(PlayerPedId())
		isInATMMarker = false

		for k,v in pairs(Config.ATMLocations) do
			local dist = #(v - coords)
			if dist < 1.0 then sleep = 1
				isInATMMarker = true
					inAtmMark()
				break
			end
		end

		if isInATMMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
		end
	
		if not isInATMMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			SetNuiFocus(false)
			menuIsShowed = false

			SendNUIMessage({
				hideAll = true
			})
		end

		Wait(sleep)
	end
end)

-- Menu interactions
inAtmMark = function()
	CreateThread(function()
		while isInATMMarker and not menuIsShowed do
			Wait(0)

				ESX.ShowHelpNotification(_U('press_e_atm'))

				if IsControlJustReleased(0, 38) and IsPedOnFoot(PlayerPedId()) then
					menuIsShowed = true
					ESX.TriggerServerCallback('esx:getPlayerData', function(data)
						SendNUIMessage({
							showMenu = true,
							player = {
								money = data.money,
								accounts = data.accounts
							}
						})
					end)

					SetNuiFocus(true, true)
				end
		end
	end)
end
-- close the menu when script is stopping to avoid being stuck in NUI focus
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuIsShowed then
			TriggerEvent('esx_atm:closeATM')
		end
	end
end)
