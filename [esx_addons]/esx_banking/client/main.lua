-- internal variables
local hasAlreadyEnteredMarker, isInbankingMarker, menuIsShowed = false, false, false

RegisterNetEvent('esx_banking:closebanking')
AddEventHandler('esx_banking:closebanking', function()
	SetNuiFocus(false)
	menuIsShowed = false
	SendNUIMessage({
		hideAll = true
	})
end)

RegisterNUICallback('escape', function(data, cb)
	TriggerEvent('esx_banking:closebanking')
	cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('esx_banking:deposit', data.amount)
	getTransactionHistory()
	cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
	TriggerServerEvent('esx_banking:withdraw', data.amount)
	getTransactionHistory()
	cb('ok')
end)

-- Create blips
CreateThread(function()
	if not Config.Blips.Enabled then return end

	for _, bankingLocation in pairs(Config.bankingLocations) do
		bankingLocation.blip = AddBlipForCoord(bankingLocation.x, bankingLocation.y, bankingLocation.z - Config.ZDiff)
		SetBlipSprite(bankingLocation.blip, Config.Blips.Sprite)
		SetBlipDisplay(bankingLocation.blip, 4)
		SetBlipScale(bankingLocation.blip, Config.Blips.Scale)
		SetBlipColour(bankingLocation.blip, Config.Blips.Color)
		SetBlipAsShortRange(bankingLocation.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('banking_blip'))
		EndTextCommandSetBlipName(bankingLocation.blip)
	end
end)

-- Activate menu when player is inside marker
CreateThread(function()
	while true do
		local coords = GetEntityCoords(PlayerPedId())
		local Sleep = 1500
		isInbankingMarker = false

		for k,v in pairs(Config.bankingLocations) do
			local Pos = vector3(v.x,v.y,v.z)
			if #(coords - Pos) < 2.0 then
				Sleep = 0
				isInbankingMarker, canSleep = true, false
				ESX.TextUI(_U('press_e_banking'))
				DrawMarker(20, Pos.x, Pos.y, Pos.z,0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 187, 255, 0, 255, false, true, 2, nil, nil, false)
				break
			end
		end

		if isInbankingMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			canSleep = false
		end
	
		if not isInbankingMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			SetNuiFocus(false)
			menuIsShowed = false
			canSleep = false
			ESX.HideUI()

			SendNUIMessage({
				hideAll = true
			})
		end
	Wait(Sleep)
	end
end)

-- Menu interactions
CreateThread(function()
	while true do
		local Sleep = 1500
		if isInbankingMarker and not menuIsShowed then
			Sleep = 0
			if IsControlJustReleased(0, 38) and IsPedOnFoot(PlayerPedId()) then
				menuIsShowed = true
				getTransactionHistory()
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
	Wait(Sleep)
	end
end)

-- close the menu when script is stopping to avoid being stuck in NUI focus
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuIsShowed then
			TriggerEvent('esx_banking:closebanking')
		end
	end
end)

function getTransactionHistory() 
	ESX.TriggerServerCallback("esx_banking:BenzoFP", function(_history)
		SendNUIMessage({
			history = {json.encode(_history)}
		})
	end)
end
