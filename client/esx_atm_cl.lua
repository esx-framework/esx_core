local GUI          			  = {}
local hasAlreadyEnteredMarker = false
local isInATMMarker 			  = false
local menuIsShowed   		  = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

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
    for i=1, #Config.ATMS, 1 do    	
    	local blip = AddBlipForCoord(Config.ATMS[i].x, Config.ATMS[i].y, Config.ATMS[i].z - Config.ZDiff)      
		SetBlipSprite (blip, Config.BlipSprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.9)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("ATM")
		EndTextCommandSetBlipName(blip)
    end
end)

-- Render markers
Citizen.CreateThread(function()
	while true do		
		Wait(0)		
		local coords = GetEntityCoords(GetPlayerPed(-1))		
		for i=1, #Config.ATMS, 1 do
			if(GetDistanceBetweenCoords(coords, Config.ATMS[i].x, Config.ATMS[i].y, Config.ATMS[i].z, true) < Config.DrawDistance) then
				DrawMarker(Config.MarkerType, Config.ATMS[i].x, Config.ATMS[i].y, Config.ATMS[i].z - Config.ZDiff, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do		
		Wait(0)		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		isInATMMarker = false
		for i=1, #Config.ATMS, 1 do
			if(GetDistanceBetweenCoords(coords, Config.ATMS[i].x, Config.ATMS[i].y, Config.ATMS[i].z, true) < Config.ZoneSize.x / 2) then
				isInATMMarker = true
				SetTextComponentFormat('STRING')
				AddTextComponentString(_U('press_e_atm'))
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)
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
	end
end)

-- Menu interactions
Citizen.CreateThread(function()
	while true do
	  	Wait(0)
	    if menuIsShowed then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
				SendNUIMessage({
					click = true
				})
			end
	    else
		  	if IsControlJustReleased(0, 38) and isInATMMarker then
		  		menuIsShowed = true
				ESX.TriggerServerCallback('esx:getPlayerData', function(data)				    
				    SendNUIMessage({
						showMenu = true,
						player   = {
							money = data.money,
							accounts = data.accounts
						}
					})
				end)
				SetNuiFocus(true)
			end
	    end
	end
end)