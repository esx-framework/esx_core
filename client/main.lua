local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
  }

-- internal variables
local GUI = {}
local hasAlreadyEnteredMarker = false
local isInATMMarker = false
local menuIsShowed = false
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
	if not Config.EnableBlips then return end

	for i=1, #Config.ATMS, 1 do
		local blip = AddBlipForCoord(Config.ATMS[i].x, Config.ATMS[i].y, Config.ATMS[i].z - Config.ZDiff)
		SetBlipSprite (blip, Config.BlipSprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 0.9)
		SetBlipColour (blip, 2)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('atm'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Render markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
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
		Citizen.Wait(1)
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
		Citizen.Wait(1)
		if menuIsShowed then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
		else
			if IsControlJustReleased(0, Keys['E']) and isInATMMarker then
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
				-- Open UI and display Native Cursor
				SetNuiFocus(true, true)
			end
		end
	end
end)

-- close the menu when script is restarting to avoid being stuck in NUI focus
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuIsShowed then
			TriggerEvent('esx_atm:closeATM')
		end
	end
end)