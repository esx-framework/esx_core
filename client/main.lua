Keys = {
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

ESX    = nil
isInShopMenu = false
local spawnedVehicles = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData() == nil do
		print('playerdata nil!! (boat)')
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

function OpenBoatShop(shop)

	isInShopMenu = true

	local playerPed = PlayerPedId()
	local elements  = {}

	for i=1, #Config.Vehicles, 1 do

		table.insert(elements, {
			label = (string.format ('%s - <span style="color: green;">$%i</span>', Config.Vehicles[i].label, Config.Vehicles[i].price)),
			name  = Config.Vehicles[i].label,
			model = Config.Vehicles[i].model,
			price = Config.Vehicles[i].price,
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boat_shop',
	{
		title    = _U('boat_shop'),
		align    = 'top-left',
		elements = elements
	}, function (data, menu)

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boat_shop_confirm',
		{
			title    = _U('boat_shop_confirm', data.current.name, data.current.price),
			align    = 'top-left',
			elements = {
				{ label = _U('confirm_no'), value = 'no' },
				{ label = _U('confirm_yes'), value = 'yes' }
			}
		}, function (data2, menu2)

			if data2.current.value == 'yes' then

				local plate   = exports['esx_vehicleshop']:GeneratePlate()
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				local props   = ESX.Game.GetVehicleProperties(vehicle)
				props.plate   = plate
				print(props.model)

				ESX.TriggerServerCallback('esx_boat:buyBoat', function (bought)

					if bought then
						ESX.ShowNotification(_U('boat_shop_bought', data.current.model, data.current.price))

						DeleteSpawnedVehicles()
						ESX.UI.Menu.CloseAll()

						CurrentAction     = 'boat_shop'
						CurrentActionMsg  = _U('boat_shop_open')
				
						FreezeEntityPosition(playerPed, false)
						SetEntityVisible(playerPed, true)
						SetEntityCoords(playerPed, shop.Outside.x, shop.Outside.y, shop.Outside.z)
					else
						ESX.ShowNotification(_U('boat_shop_nomoney'))
						menu2.close()
					end
					
				end, props, data.current.model)

			else
				menu2.close()
			end

		end, function (data2, menu2)
			menu2.close()
		end)



	end, function (data, menu)
		-- exit menu
		menu.close()

		DeleteSpawnedVehicles()

		CurrentAction     = 'boat_shop'
		CurrentActionMsg  = _U('boat_shop_open')

		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)
		SetEntityCoords(playerPed, shop.Outside.x, shop.Outside.y, shop.Outside.z)

	end, function (data, menu)
		DeleteSpawnedVehicles()
		
		ESX.Game.SpawnLocalVehicle(data.current.model, shop.Inside, shop.Heading, function (vehicle)
			table.insert(spawnedVehicles, vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
		end)
	end, function (data, menu)

	end)

	-- spawn first vehicle
	DeleteSpawnedVehicles()
	ESX.Game.SpawnLocalVehicle(Config.Vehicles[1].model, shop.Inside, shop.Heading, function (vehicle)
		table.insert(spawnedVehicles, vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
	end)
end

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if isInShopMenu then
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function DeleteSpawnedVehicles()

	while #spawnedVehicles > 0 do

		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)

	end
end



AddEventHandler('onResourceStop', function(resource)
	--if resource == GetCurrentResourceName() and ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'boat_shop') then
		ESX.UI.Menu.CloseAll()
--	end
end)
