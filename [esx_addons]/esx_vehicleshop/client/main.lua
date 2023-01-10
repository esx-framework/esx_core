local HasAlreadyEnteredMarker, IsInShopMenu = false, false
local CurrentAction, CurrentActionMsg, LastZone, currentDisplayVehicle, CurrentVehicleData
local CurrentActionData, Vehicles, Categories = {}, {}, {}

function getVehicleFromModel(model)
	for i = 1, #Vehicles do
		local vehicle = Vehicles[i]
		if vehicle.model == model then
			return vehicle
		end
	end
end

function getVehicles()
	ESX.TriggerServerCallback('esx_vehicleshop:getCategories', function(categories)
		Categories = categories
	end)

	ESX.TriggerServerCallback('esx_vehicleshop:getVehicles', function(vehicles)
		Vehicles = vehicles
	end)
end

AddEventHandler("onResourceStart", getVehicles)

function PlayerManagement()
	if Config.EnablePlayerManagement then
		if ESX.PlayerData.job.name == 'cardealer' then
			Config.Zones.ShopEntering.Type = 1

			if ESX.PlayerData.job.grade_name == 'boss' then
				Config.Zones.BossActions.Type = 1
			end

		else
			Config.Zones.ShopEntering.Type = -1
			Config.Zones.BossActions.Type  = -1
			Config.Zones.ResellVehicle.Type = -1
		end
	end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer

	PlayerManagement()
	getVehicles()
end)

RegisterNetEvent('esx_vehicleshop:sendCategories')
AddEventHandler('esx_vehicleshop:sendCategories', function(categories)
	Categories = categories
end)

RegisterNetEvent('esx_vehicleshop:sendVehicles')
AddEventHandler('esx_vehicleshop:sendVehicles', function(vehicles)
	Vehicles = vehicles
end)


RegisterNetEvent('esx:setJob') AddEventHandler('esx:setJob', PlayerManagement)

function DeleteDisplayVehicleInsideShop()
	local attempt = 0

	if currentDisplayVehicle and DoesEntityExist(currentDisplayVehicle) then
		while DoesEntityExist(currentDisplayVehicle) and not NetworkHasControlOfEntity(currentDisplayVehicle) and attempt < 100 do
			Wait(100)
			NetworkRequestControlOfEntity(currentDisplayVehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(currentDisplayVehicle) and NetworkHasControlOfEntity(currentDisplayVehicle) then
			ESX.Game.DeleteVehicle(currentDisplayVehicle)
		end
	end
end

function ReturnVehicleProvider()
	ESX.TriggerServerCallback('esx_vehicleshop:getCommercialVehicles', function(vehicles)
		local elements = {}

		for k,v in ipairs(vehicles) do
			local returnPrice = ESX.Math.Round(v.price * 0.75)
			local vehicleLabel = getVehicleFromModel(v.vehicle).label

			table.insert(elements, {
				label = ('%s [<span style="color:orange;">%s</span>]'):format(vehicleLabel, TranslateCap('generic_shopitem', ESX.Math.GroupDigits(returnPrice))),
				value = v.vehicle
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_provider_menu', {
			title    = TranslateCap('return_provider_menu'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_vehicleshop:returnProvider', data.current.value)

			Wait(300)
			menu.close()
			ReturnVehicleProvider()
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function StartShopRestriction()
	CreateThread(function()
		while IsInShopMenu do
			Wait(0)

			DisableControlAction(0, 75,  true) -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		end
	end)
end

function OpenShopMenu()
	if #Vehicles == 0 then
		print('[^3ERROR^7] Vehicleshop has ^50^7 vehicles, please add some!')
		return
	end

	IsInShopMenu = true

	StartShopRestriction()
	ESX.UI.Menu.CloseAll()

	local playerPed = PlayerPedId()

	FreezeEntityPosition(playerPed, true)
	SetEntityVisible(playerPed, false)
	SetEntityCoords(playerPed, Config.Zones.ShopInside.Pos)

	local vehiclesByCategory = {}
	local elements           = {}
	local firstVehicleData   = nil

	for i=1, #Categories, 1 do
		vehiclesByCategory[Categories[i].name] = {}
	end

	for i=1, #Vehicles, 1 do
		if IsModelInCdimage(joaat(Vehicles[i].model)) then
			table.insert(vehiclesByCategory[Vehicles[i].category], Vehicles[i])
		else
			print(('[^3WARNING^7] Ignoring vehicle ^5%s^7 due to invalid Model'):format(Vehicles[i].model))
		end
	end

	for k,v in pairs(vehiclesByCategory) do
		table.sort(v, function(a, b)
			return a.name < b.name
		end)
	end

	for i=1, #Categories, 1 do
		local category         = Categories[i]
		local categoryVehicles = vehiclesByCategory[category.name]
		local options          = {}

		for j=1, #categoryVehicles, 1 do
			local vehicle = categoryVehicles[j]

			if i == 1 and j == 1 then
				firstVehicleData = vehicle
			end

			table.insert(options, ('%s <span style="color:green;">%s</span>'):format(vehicle.name, TranslateCap('generic_shopitem', ESX.Math.GroupDigits(vehicle.price))))
		end

		table.sort(options)

		table.insert(elements, {
			name    = category.name,
			label   = category.label,
			value   = 0,
			type    = 'slider',
			max     = #Categories[i],
			options = options
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
		title    = TranslateCap('car_dealer'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title = TranslateCap('buy_vehicle_shop', vehicleData.name, ESX.Math.GroupDigits(vehicleData.price)),
			align = 'top-left',
			elements = {
				{label = TranslateCap('no'),  value = 'no'},
				{label = TranslateCap('yes'), value = 'yes'}
		}}, function(data2, menu2)
			if data2.current.value == 'yes' then
				if Config.EnablePlayerManagement then
					ESX.TriggerServerCallback('esx_vehicleshop:buyCarDealerVehicle', function(success)
						if success then
							IsInShopMenu = false
							DeleteDisplayVehicleInsideShop()

							CurrentAction     = 'shop_menu'
							CurrentActionMsg  = TranslateCap('shop_menu')
							CurrentActionData = {}

							local playerPed = PlayerPedId()
							FreezeEntityPosition(playerPed, false)
							SetEntityVisible(playerPed, true)
							SetEntityCoords(playerPed, Config.Zones.ShopEntering.Pos)

							menu2.close()
							menu.close()
							ESX.ShowNotification(TranslateCap('vehicle_purchased'))
						else
							ESX.ShowNotification(TranslateCap('broke_company'))
						end
					end, vehicleData.model)
				else
					local generatedPlate = GeneratePlate()

					ESX.TriggerServerCallback('esx_vehicleshop:buyVehicle', function(success)
						if success then
							IsInShopMenu = false
							menu2.close()
							menu.close()
							DeleteDisplayVehicleInsideShop()
							FreezeEntityPosition(playerPed, false)
							SetEntityVisible(playerPed, true)
						else
							ESX.ShowNotification(TranslateCap('not_enough_money'))
						end
					end, vehicleData.model, generatedPlate)
				end
			else
				menu2.close()
			end
		end, function(data2, menu2)
			menu2.close()
		end)
	end, function(data, menu)
		menu.close()
		DeleteDisplayVehicleInsideShop()
		local playerPed = PlayerPedId()

		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = TranslateCap('shop_menu')
		CurrentActionData = {}

		FreezeEntityPosition(playerPed, false)
		SetEntityVisible(playerPed, true)
		SetEntityCoords(playerPed, Config.Zones.ShopEntering.Pos)

		IsInShopMenu = false
	end, function(data, menu)
		local vehicleData = vehiclesByCategory[data.current.name][data.current.value + 1]
		local playerPed   = PlayerPedId()

		DeleteDisplayVehicleInsideShop()
		WaitForVehicleToLoad(vehicleData.model)

		ESX.Game.SpawnLocalVehicle(vehicleData.model, Config.Zones.ShopInside.Pos, Config.Zones.ShopInside.Heading, function(vehicle)
			currentDisplayVehicle = vehicle
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
			FreezeEntityPosition(vehicle, true)
			SetModelAsNoLongerNeeded(vehicleData.model)
		end)
	end)

	DeleteDisplayVehicleInsideShop()
	WaitForVehicleToLoad(firstVehicleData.model)

	ESX.Game.SpawnLocalVehicle(firstVehicleData.model, Config.Zones.ShopInside.Pos, Config.Zones.ShopInside.Heading, function(vehicle)
		currentDisplayVehicle = vehicle
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		FreezeEntityPosition(vehicle, true)
		SetModelAsNoLongerNeeded(firstVehicleData.model)
	end)
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or joaat(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('shop_awaiting_model'))
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Wait(0)
			DisableAllControlActions(0)
		end

		BusyspinnerOff()
	end
end

function OpenResellerMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'reseller', {
		title    = TranslateCap('car_dealer'),
		align    = 'top-left',
		elements = {
			{label = TranslateCap('buy_vehicle'),                    value = 'buy_vehicle'},
			{label = TranslateCap('pop_vehicle'),                    value = 'pop_vehicle'},
			{label = TranslateCap('depop_vehicle'),                  value = 'depop_vehicle'},
			{label = TranslateCap('return_provider'),                value = 'return_provider'},
			{label = TranslateCap('create_bill'),                    value = 'create_bill'},
			{label = TranslateCap('get_rented_vehicles'),            value = 'get_rented_vehicles'},
			{label = TranslateCap('set_vehicle_owner_sell'),         value = 'set_vehicle_owner_sell'},
			{label = TranslateCap('set_vehicle_owner_rent'),         value = 'set_vehicle_owner_rent'},
			{label = TranslateCap('deposit_stock'),                  value = 'put_stock'},
			{label = TranslateCap('take_stock'),                     value = 'get_stock'}
	}}, function(data, menu)
		local action = data.current.value

		if Config.OxInventory and (action == 'put_stock' or action == 'get_stock') then
			exports.ox_inventory:openInventory('stash', 'society_cardealer')
		elseif action == 'buy_vehicle' then
			OpenShopMenu()
		elseif action == 'put_stock' then
			OpenPutStocksMenu()
		elseif action == 'get_stock' then
			OpenGetStocksMenu()
		elseif action == 'pop_vehicle' then
			OpenPopVehicleMenu()
		elseif action == 'depop_vehicle' then
			if currentDisplayVehicle then
				DeleteDisplayVehicleInsideShop()
			else
				ESX.ShowNotification(TranslateCap('no_current_vehicle'))
			end
		elseif action == 'return_provider' then
			ReturnVehicleProvider()
		elseif action == 'create_bill' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if closestPlayer ~= -1 and closestDistance < 3 then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'set_vehicle_owner_sell_amount', {
					title = TranslateCap('invoice_amount')
				}, function(data2, menu2)
					local amount = tonumber(data2.value)

					if amount == nil then
						ESX.ShowNotification(TranslateCap('invalid_amount'))
					else
						menu2.close()
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification(TranslateCap('no_players'))
						else
							TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_cardealer', TranslateCap('car_dealer'), tonumber(data2.value))
						end
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			else
				ESX.ShowNotification(TranslateCap('no_players'))
			end
		elseif action == 'get_rented_vehicles' then
			OpenRentedVehiclesMenu()
		elseif action == 'set_vehicle_owner_sell' then
			if currentDisplayVehicle then
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if closestPlayer ~= -1 and closestDistance < 3 then
					local newPlate = GeneratePlate()
					local vehicleProps = ESX.Game.GetVehicleProperties(currentDisplayVehicle)
					vehicleProps.plate = newPlate
					SetVehicleNumberPlateText(currentDisplayVehicle, newPlate)
					TriggerServerEvent('esx_vehicleshop:setVehicleOwnedPlayerId', GetPlayerServerId(closestPlayer), vehicleProps, CurrentVehicleData.model, CurrentVehicleData.name)
					currentDisplayVehicle = nil
				else
					ESX.ShowNotification(TranslateCap('no_players'))
				end
			else
				ESX.ShowNotification(TranslateCap('no_current_vehicle'))
			end
		elseif action == 'set_vehicle_owner_rent' then
			if currentDisplayVehicle then
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if closestPlayer ~= -1 and closestDistance < 3 then
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'set_vehicle_owner_rent_amount', {
						title = TranslateCap('rental_amount')
					}, function(data2, menu2)
						local amount = tonumber(data2.value)

						if not amount then
							ESX.ShowNotification(TranslateCap('invalid_amount'))
						else
							menu2.close()
							local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

							if closestPlayer ~= -1 and closestDistance < 3 then
								local newPlate = 'RENT' .. string.upper(ESX.GetRandomString(4))
								local model = CurrentVehicleData.model
								SetVehicleNumberPlateText(currentDisplayVehicle, newPlate)
								TriggerServerEvent('esx_vehicleshop:rentVehicle', model, newPlate, amount, GetPlayerServerId(closestPlayer))
								currentDisplayVehicle = nil
							else
								ESX.ShowNotification(TranslateCap('no_players'))
							end
						end
					end, function(data2, menu2)
						menu2.close()
					end)
				else
					ESX.ShowNotification(TranslateCap('no_players'))
				end
			else
				ESX.ShowNotification(TranslateCap('no_current_vehicle'))
			end
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'reseller_menu'
		CurrentActionMsg  = TranslateCap('shop_menu')
		CurrentActionData = {}
	end)
end

function OpenPopVehicleMenu()
	ESX.TriggerServerCallback('esx_vehicleshop:getCommercialVehicles', function(vehicles)
		local elements = {}

		for k,v in ipairs(vehicles) do
			local vehicleLabel = getVehicleFromModel(v.vehicle).label

			table.insert(elements, {
				label = ('%s [MSRP <span style="color:green;">%s</span>]'):format(vehicleLabel, TranslateCap('generic_shopitem', ESX.Math.GroupDigits(v.price))),
				value = v.vehicle
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'commercial_vehicles', {
			title    = TranslateCap('vehicle_dealer'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local model = data.current.value
			DeleteDisplayVehicleInsideShop()

			ESX.Game.SpawnVehicle(model, Config.Zones.ShopInside.Pos, Config.Zones.ShopInside.Heading, function(vehicle)
				currentDisplayVehicle = vehicle

				for i=1, #Vehicles, 1 do
					if model == Vehicles[i].model then
						CurrentVehicleData = Vehicles[i]
						break
					end
				end
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenRentedVehiclesMenu()
	ESX.TriggerServerCallback('esx_vehicleshop:getRentedVehicles', function(vehicles)
		local elements = {}

		for k,v in ipairs(vehicles) do
			local vehicleLabel = getVehicleFromModel(v.name).label

			table.insert(elements, {
				label = ('%s: %s - <span style="color:orange;">%s</span>'):format(v.playerName, vehicleLabel, v.plate),
				value = v.name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rented_vehicles', {
			title    = TranslateCap('rent_vehicle'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenBossActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'reseller',{
		title    = TranslateCap('dealer_boss'),
		align    = 'top-left',
		elements = {
			{label = TranslateCap('boss_actions'), value = 'boss_actions'},
			{label = TranslateCap('boss_sold'), value = 'sold_vehicles'}
	}}, function(data, menu)
		if data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'cardealer', function(data2, menu2)
				menu2.close()
			end)
		elseif data.current.value == 'sold_vehicles' then

			ESX.TriggerServerCallback('esx_vehicleshop:getSoldVehicles', function(customers)
				local elements = {
					head = { TranslateCap('customer_client'), TranslateCap('customer_model'), TranslateCap('customer_plate'), TranslateCap('customer_soldby'), TranslateCap('customer_date') },
					rows = {}
				}

				for i=1, #customers, 1 do
					table.insert(elements.rows, {
						data = customers[i],
						cols = {
							customers[i].client,
							customers[i].model,
							customers[i].plate,
							customers[i].soldby,
							customers[i].date
						}
					})
				end

				ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'sold_vehicles', elements, function(data2, menu2)

				end, function(data2, menu2)
					menu2.close()
				end)
			end)
		end

	end, function(data, menu)
		menu.close()

		CurrentAction     = 'boss_actions_menu'
		CurrentActionMsg  = TranslateCap('shop_menu')
		CurrentActionData = {}
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_vehicleshop:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			if items[i].count > 0 then
				table.insert(elements, {
					label = 'x' .. items[i].count .. ' ' .. items[i].label,
					value = items[i].name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = TranslateCap('dealership_stock'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = TranslateCap('amount')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(TranslateCap('quantity_invalid'))
				else
					TriggerServerEvent('esx_vehicleshop:getStockItem', itemName, count)
					menu2.close()
					menu.close()
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_vehicleshop:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = TranslateCap('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = TranslateCap('amount')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(TranslateCap('quantity_invalid'))
				else
					TriggerServerEvent('esx_vehicleshop:putStockItems', itemName, count)
					menu2.close()
					menu.close()
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

AddEventHandler('esx_vehicleshop:hasEnteredMarker', function(zone)
	if zone == 'ShopEntering' then

		if Config.EnablePlayerManagement then
			if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'cardealer' then
				CurrentAction     = 'reseller_menu'
				CurrentActionMsg  = TranslateCap('shop_menu')
				CurrentActionData = {}
			end
		else
			CurrentAction     = 'shop_menu'
			CurrentActionMsg  = TranslateCap('shop_menu')
			CurrentActionData = {}
		end

	elseif zone == 'GiveBackVehicle' and Config.EnablePlayerManagement then
		local playerPed = PlayerPedId()

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)

			CurrentAction     = 'give_back_vehicle'
			CurrentActionMsg  = TranslateCap('vehicle_menu')
			CurrentActionData = {vehicle = vehicle}
		end
	elseif zone == 'ResellVehicle' then
		local playerPed = PlayerPedId()

		if IsPedSittingInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			local vehicleData, model, resellPrice, plate

			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				for i=1, #Vehicles, 1 do
					if joaat(Vehicles[i].model) == GetEntityModel(vehicle) then
						vehicleData = Vehicles[i]
						break
					end
				end

				if vehicleData then
					resellPrice = ESX.Math.Round(vehicleData.price / 100 * Config.ResellPercentage)
					model = GetEntityModel(vehicle)
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

					CurrentAction     = 'resell_vehicle'
					CurrentActionMsg  = TranslateCap('sell_menu', vehicleData.name, ESX.Math.GroupDigits(resellPrice))

					CurrentActionData = {
						vehicle = vehicle,
						label = vehicleData.name,
						price = resellPrice,
						model = model,
						plate = plate
					}
				else
					ESX.ShowNotification(TranslateCap('invalid_vehicle'))
				end
			end
		end

	elseif zone == 'BossActions' and Config.EnablePlayerManagement and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'cardealer' and ESX.PlayerData.job.grade_name == 'boss' then
		CurrentAction     = 'boss_actions_menu'
		CurrentActionMsg  = TranslateCap('shop_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_vehicleshop:hasExitedMarker', function(zone)
	if not IsInShopMenu then
		ESX.UI.Menu.CloseAll()
	end
	ESX.HideUI()
	CurrentAction = nil
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if IsInShopMenu then
			ESX.UI.Menu.CloseAll()

			local playerPed = PlayerPedId()

			FreezeEntityPosition(playerPed, false)
			SetEntityVisible(playerPed, true)
			SetEntityCoords(playerPed, Config.Zones.ShopEntering.Pos)
		end

		DeleteDisplayVehicleInsideShop()
	end
end)

if Config.EnablePlayerManagement then
	RegisterNetEvent('esx_phone:loaded')
	AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
		local specialContact = {
			name       = TranslateCap('dealership'),
			number     = 'cardealer',
			base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMAUExURQAAADMzMzszM0M0M0w0M1Q1M101M2U2M242M3Y3M383Moc4MpA4Mpg5MqE5Mqk6MrI6Mro7Mrw8Mr89M71DML5EO8I+NMU/NcBMLshANctBNs5CN8RULMddKsheKs9YLtBCONZEOdlFOtxGO99HPNhMNsplKM1nKM1uJtRhLddiLt5kMNJwJ9B2JNR/IeNIPeVJPehKPuRQOuhSO+lZOOlhNuloM+p3Lep/KupwMMFORsVYUcplXc1waNJ7delUSepgVexrYe12bdeHH9iIH9qQHd2YG+udH+OEJeuGJ+uOJeuVIuChGeSpF+aqGOykHOysGeeyFeuzFuyzFuq6E+27FO+Cee3CEdaGgdqTjvCNhfKYkvOkngAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJezdycAAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGHRFWHRTb2Z0d2FyZQBwYWludC5uZXQgNC4xLjb9TgnoAAAQGElEQVR4Xt2d+WMUtxXHbS6bEGMPMcQQ04aEUnqYo9xJWvC6kAKmQLM2rdn//9+g0uir2Tl0PElPszP7+cnH7Fj6rPTeG2lmvfKld2azk8lk/36L/cnkZDbDIT3Sp4DZ8QS9dTI57tNDTwJOOu+4j/0TvDQz+QXMSG+7mUn+sZBZQELnNROcKhMZBXx+gS4k8+IzTpmBXAJOnqPxTDzPFRKyCODuvSKPgwwC2EZ+lxf4E4xwCzhBU7PBPQx4BWR88+fwDgNGAbMsM9/Ec8bygE3A5966L3nOlhiZBGSf+l2YggGLgBna1DMsE4FBQH9zvw1HLEgX0Evkt5GeEVIFMFztpJF6rZQm4DNasVDSEkKSgIVN/ibP0ZwoEgQsfPTPSZgH8QIG8vYr4gdBrIABvf2K2EEQKWBQb78ichBECRhE8O8SlQ5iBAQvcffFPhoYQoSAAQ5/TcQ0CBYw0OGvCZ4GoQIGF/3bhGaDQAELvfKhERgIwgQMePrPCQsEQQLwFwYPmksiQMCC1n1iCFgooQtYwLJfPPQFQ7KAUfU/wABVwMj6TzdAFDDY6tcOMR3SBIyw/1QDJAGj7D/RAEXA6Oa/hhIHCAJG23+SAb+AEfefYsArYET1nwlvTegVgBONFnTDik8ATjNi0BEbHgGjuP5147k6dgsYaQHQxF0OOAUMfv2LhnOVzCVg4OufdFwrpS4BePkSgA6ZcAhYggCocQRCu4ClCIAaeyC0CliaAKCwhgGrALxwaUC3OtgELFEAUNjCgEXAklQAdSzVgEUAXrRUoGstzAKWbgJIzJPAKGAJJ4DEOAmMAvCCpQPda2ASsJQTQGKa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',
		}

		TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
	end)
end

-- Create Blips
CreateThread(function()
	if Config.Blip.show then
		local blip = AddBlipForCoord(Config.Zones.ShopEntering.Pos)

		SetBlipSprite (blip, Config.Blip.Sprite)
		SetBlipDisplay(blip, Config.Blip.Display)
		SetBlipScale  (blip, Config.Blip.Scale)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('car_dealer'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Enter / Exit marker events & Draw Markers
CreateThread(function()
	while true do
		Wait(0)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local isInMarker, letSleep, currentZone = false, true

		for k,v in pairs(Config.Zones) do
			local distance = #(playerCoords - v.Pos)

			if distance < Config.DrawDistance then
				letSleep = false

				if v.Type ~= -1 then
					DrawMarker(v.Type, v.Pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
				end

				if distance < v.Size.x then
					isInMarker, currentZone = true, k
				end
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker, LastZone = true, currentZone
			LastZone = currentZone
			TriggerEvent('esx_vehicleshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_vehicleshop:hasExitedMarker', LastZone)
		end

		if letSleep then
			Wait(500)
		end
	end
end)

-- Key controls
CreateThread(function()
	while true do
		Wait(0)

		if CurrentAction then
			ESX.TextUI(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'shop_menu' then
					if Config.LicenseEnable then
						ESX.TriggerServerCallback('esx_license:checkLicense', function(hasDriversLicense)
							if hasDriversLicense then
								OpenShopMenu()
							else
								ESX.ShowNotification(TranslateCap('license_missing'))
							end
						end, GetPlayerServerId(PlayerId()), 'drive')
					else
						OpenShopMenu()
					end
				elseif CurrentAction == 'reseller_menu' then
					OpenResellerMenu()
				elseif CurrentAction == 'give_back_vehicle' then
					ESX.TriggerServerCallback('esx_vehicleshop:giveBackVehicle', function(isRentedVehicle)
						if isRentedVehicle then
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
							ESX.ShowNotification(TranslateCap('delivered'))
						else
							ESX.ShowNotification(TranslateCap('not_rental'))
						end
					end, ESX.Math.Trim(GetVehicleNumberPlateText(CurrentActionData.vehicle)))
				elseif CurrentAction == 'resell_vehicle' then
					ESX.TriggerServerCallback('esx_vehicleshop:resellVehicle', function(vehicleSold)
						if vehicleSold then
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
							ESX.ShowNotification(TranslateCap('vehicle_sold_for', CurrentActionData.label, ESX.Math.GroupDigits(CurrentActionData.price)))
						else
							ESX.ShowNotification(TranslateCap('not_yours'))
						end
					end, CurrentActionData.plate, CurrentActionData.model)
				elseif CurrentAction == 'boss_actions_menu' then
					OpenBossActionsMenu()
				end
				ESX.HideUI()
				CurrentAction = nil
			end
		else
			Wait(500)
		end
	end
end)

CreateThread(function()
	RequestIpl('shr_int') -- Load walls and floor

	local interiorID = 7170
	PinInteriorInMemory(interiorID)
	ActivateInteriorEntitySet(interiorID, 'csr_beforeMission') -- Load large window
	RefreshInterior(interiorID)
end)

if ESX.PlayerLoaded then PlayerManagement() end