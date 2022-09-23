local categories, vehicles = {}, {}

TriggerEvent('esx_phone:registerNumber', 'cardealer', _U('dealer_customers'), false, false)
TriggerEvent('esx_society:registerSociety', 'cardealer', _U('car_dealer'), 'society_cardealer', 'society_cardealer', 'society_cardealer', {type = 'private'})

CreateThread(function()
	local char = Config.PlateLetters
	char = char + Config.PlateNumbers
	if Config.PlateUseSpace then char = char + 1 end

	if char > 8 then
		print(('[^3WARNING^7] Character Limit Exceeded, ^5%s/8^7!'):format(char))
	end
end)

function RemoveOwnedVehicle(plate)
	MySQL.update('DELETE FROM owned_vehicles WHERE plate = ?', {plate})
end

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == GetCurrentResourceName() then
		SQLVehiclesAndCategories()
	end
end)

function SQLVehiclesAndCategories()
	categories = MySQL.query.await('SELECT * FROM vehicle_categories')
	vehicles = MySQL.query.await('SELECT * FROM vehicles')

	GetVehiclesAndCategories(categories, vehicles)
end

function GetVehiclesAndCategories(categories, vehicles)
	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		for j = 1, #categories do
			local category = categories[j]
			if category.name == vehicle.category then
				vehicle.categoryLabel = category.label
				break
			end
		end
	end

	-- send information after db has loaded, making sure everyone gets vehicle information
	TriggerClientEvent('esx_vehicleshop:sendCategories', -1, categories)
	TriggerClientEvent('esx_vehicleshop:sendVehicles', -1, vehicles)
end

function getVehicleFromModel(model)
	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		if vehicle.model == model then
			return vehicle
		end
	end

	return
end

RegisterNetEvent('esx_vehicleshop:setVehicleOwnedPlayerId')
AddEventHandler('esx_vehicleshop:setVehicleOwnedPlayerId', function(playerId, vehicleProps, model, label)
	local xPlayer, xTarget = ESX.GetPlayerFromId(source), ESX.GetPlayerFromId(playerId)

	if xPlayer.job.name == 'cardealer' and xTarget then
		MySQL.scalar('SELECT id FROM cardealer_vehicles WHERE vehicle = ?', {model},
		function(id)
			if id then
				MySQL.update('DELETE FROM cardealer_vehicles WHERE id = ?', {id},
				function(rowsChanged)
					if rowsChanged == 1 then
						MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {xTarget.identifier, vehicleProps.plate, json.encode(vehicleProps)},
						function(id)
							xPlayer.showNotification(_U('vehicle_set_owned', vehicleProps.plate, xTarget.getName()))
							xTarget.showNotification(_U('vehicle_belongs', vehicleProps.plate))
						end)

						MySQL.insert('INSERT INTO vehicle_sold (client, model, plate, soldby, date) VALUES (?, ?, ?, ?, ?)', {xTarget.getName(), label, vehicleProps.plate, xPlayer.getName(), os.date('%Y-%m-%d %H:%M')})
					end
				end)
			end
		end)
	end
end)

ESX.RegisterServerCallback('esx_vehicleshop:getSoldVehicles', function(source, cb)
	MySQL.query('SELECT client, model, plate, soldby, date FROM vehicle_sold ORDER BY DATE DESC', function(result)
		cb(result)
	end)
end)

RegisterNetEvent('esx_vehicleshop:rentVehicle')
AddEventHandler('esx_vehicleshop:rentVehicle', function(vehicle, plate, rentPrice, playerId)
	local xPlayer, xTarget = ESX.GetPlayerFromId(source), ESX.GetPlayerFromId(playerId)

	if xPlayer.job.name == 'cardealer' and xTarget then
		MySQL.single('SELECT id, price FROM cardealer_vehicles WHERE vehicle = ?', {vehicle},
		function(result)
			if result then
				MySQL.update('DELETE FROM cardealer_vehicles WHERE id = ?', {result.id},
				function(rowsChanged)
					if rowsChanged == 1 then
						MySQL.insert('INSERT INTO rented_vehicles (vehicle, plate, player_name, base_price, rent_price, owner) VALUES (?, ?, ?, ?, ?, ?)', {vehicle, plate, xTarget.getName(), result.price, rentPrice, xTarget.identifier},
						function(id)
							xPlayer.showNotification(_U('vehicle_set_rented', plate, xTarget.getName()))
						end)
					end
				end)
			end
		end)
	end
end)

RegisterNetEvent('esx_vehicleshop:getStockItem')
AddEventHandler('esx_vehicleshop:getStockItem', function(itemName, count)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cardealer', function(inventory)
		local item = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and item.count >= count then

			-- can the player carry the said amount of x item?
			if xPlayer.canCarryItem(itemName, count) then
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				xPlayer.showNotification(_U('have_withdrawn', count, item.label))
			else
				xPlayer.showNotification(_U('player_cannot_hold'))
			end
		else
			xPlayer.showNotification(_U('not_enough_in_society'))
		end
	end)
end)

RegisterNetEvent('esx_vehicleshop:putStockItems')
AddEventHandler('esx_vehicleshop:putStockItems', function(itemName, count)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cardealer', function(inventory)
		local item = inventory.getItem(itemName)

		if item.count >= 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			xPlayer.showNotification(_U('have_deposited', count, item.label))
		else
			xPlayer.showNotification(_U('invalid_amount'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getCategories', function(source, cb)
	cb(categories)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getVehicles', function(source, cb)
	cb(vehicles)
end)

ESX.RegisterServerCallback('esx_vehicleshop:buyVehicle', function(source, cb, model, plate, automobile)
	local xPlayer = ESX.GetPlayerFromId(source)
	local modelPrice = getVehicleFromModel(model).price

	if modelPrice and xPlayer.getMoney() >= modelPrice then
		xPlayer.removeMoney(modelPrice, "Vehicle Purchase")

		MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {xPlayer.identifier, plate, json.encode({model = joaat(model), plate = plate})
		}, function(rowsChanged)
			xPlayer.showNotification(_U('vehicle_belongs', plate))
			ESX.OneSync.SpawnVehicle(joaat(model), Config.Zones.ShopOutside.Pos, Config.Zones.ShopOutside.Heading, false,{plate = plate}, function(vehicle)
				local vehicle = NetworkGetEntityFromNetworkId(vehicle)
				TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
			end)
			cb(true)
		end)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_vehicleshop:getCommercialVehicles', function(source, cb)
	MySQL.query('SELECT price, vehicle FROM cardealer_vehicles ORDER BY vehicle ASC', function(result)
		cb(result)
	end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:buyCarDealerVehicle', function(source, cb, model)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'cardealer' then
		local modelPrice = getVehicleFromModel(model).price

		if modelPrice then
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
				if account.money >= modelPrice then
					account.removeMoney(modelPrice)

					MySQL.insert('INSERT INTO cardealer_vehicles (vehicle, price) VALUES (?, ?)', {model, modelPrice},
					function(rowsChanged)
						cb(true)
					end)
				else
					cb(false)
				end
			end)
		end
	end
end)

RegisterNetEvent('esx_vehicleshop:returnProvider')
AddEventHandler('esx_vehicleshop:returnProvider', function(vehicleModel)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'cardealer' then
		MySQL.single('SELECT id, price FROM cardealer_vehicles WHERE vehicle = ?', {vehicleModel},
		function(result)
			if result then
				local id = result.id

				MySQL.update('DELETE FROM cardealer_vehicles WHERE id = ?', {id},
				function(rowsChanged)
					if rowsChanged == 1 then
						TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
							local price = ESX.Math.Round(result.price * 0.75)
							local vehicleLabel = getVehicleFromModel(vehicleModel).label

							account.addMoney(price)
							xPlayer.showNotification(_U('vehicle_sold_for', vehicleLabel, ESX.Math.GroupDigits(price)))
						end)
					end
				end)
			else
				print(('[^3WARNING^7] Player ^5%s^7 Attempted To Sell Invalid Vehicle - ^5%s^7!'):format(source, vehicleModel))
			end
		end)
	end
end)

ESX.RegisterServerCallback('esx_vehicleshop:getRentedVehicles', function(source, cb)
	MySQL.query('SELECT * FROM rented_vehicles ORDER BY player_name ASC', function(result)
		local vehicles = {}

		for i = 1, #result do
			local vehicle = result[i]
			vehicles[#vehicles + 1] = {
				name = vehicle.vehicle,
				plate = vehicle.plate,
				playerName = vehicle.player_name
			}
		end

		cb(vehicles)
	end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:giveBackVehicle', function(source, cb, plate)
	MySQL.single('SELECT base_price, vehicle FROM rented_vehicles WHERE plate = ?', {plate},
	function(result)
		if result then
			local vehicle = result.vehicle
			local basePrice = result.base_price

			MySQL.update('DELETE FROM rented_vehicles WHERE plate = ?', {plate},
			function(rowsChanged)
				MySQL.insert('INSERT INTO cardealer_vehicles (vehicle, price) VALUES (?, ?)', {result.vehicle, result.base_price})

				RemoveOwnedVehicle(plate)
				cb(true)
			end)
		else
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:resellVehicle', function(source, cb, plate, model)
	local xPlayer, resellPrice = ESX.GetPlayerFromId(source)

	if xPlayer.job.name == 'cardealer' or not Config.EnablePlayerManagement then
		-- calculate the resell price
		for i=1, #vehicles, 1 do
			if joaat(vehicles[i].model) == model then
				resellPrice = ESX.Math.Round(vehicles[i].price / 100 * Config.ResellPercentage)
				break
			end
		end

		if not resellPrice then
			print(('[^3WARNING^7] Player ^5%s^7 Attempted To Resell Invalid Vehicle - ^5%s^7!'):format(source, model))
			cb(false)
		else
			MySQL.single('SELECT * FROM rented_vehicles WHERE plate = ?', {plate},
			function(result)
				if result then -- is it a rented vehicle?
					cb(false) -- it is, don't let the player sell it since he doesn't own it
				else
					MySQL.single('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?', {xPlayer.identifier, plate},
					function(result)
						if result then -- does the owner match?
							local vehicle = json.decode(result.vehicle)

							if vehicle.model == model then
								if vehicle.plate == plate then
									xPlayer.addMoney(resellPrice, "Sold Vehicle")
									RemoveOwnedVehicle(plate)
									cb(true)
								else
									print(('[^3WARNING^7] Player ^5%s^7 Attempted To Resell Vehicle With Invalid Plate - ^5%s^7!'):format(source, plate))
									cb(false)
								end
							else
								print(('[^3WARNING^7] Player ^5%s^7 Attempted To Resell Vehicle With Invalid Model - ^5%s^7!'):format(source, model))
								cb(false)
							end
						end
					end)
				end
			end)
		end
	end
end)

ESX.RegisterServerCallback('esx_vehicleshop:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cardealer', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items = xPlayer.inventory

	cb({items = items})
end)

ESX.RegisterServerCallback('esx_vehicleshop:isPlateTaken', function(source, cb, plate)
	MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
	function(result)
		cb(result ~= nil)
	end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:retrieveJobVehicles', function(source, cb, type)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.query('SELECT * FROM owned_vehicles WHERE owner = ? AND type = ? AND job = ?', {xPlayer.identifier, type, xPlayer.job.name},
	function(result)
		cb(result)
	end)
end)

RegisterNetEvent('esx_vehicleshop:setJobVehicleState')
AddEventHandler('esx_vehicleshop:setJobVehicleState', function(plate, state)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.update('UPDATE owned_vehicles SET `stored` = ? WHERE plate = ? AND job = ?', {state, plate, xPlayer.job.name},
	function(rowsChanged)
		if rowsChanged == 0 then
			print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit the Garage!'):format(source, plate))
		end
	end)
end)

function PayRent()
	local timeStart = os.clock()
	print('[^2INFO^7] ^5Rent Payments^7 Initiated')

	MySQL.query('SELECT rented_vehicles.owner, rented_vehicles.rent_price, rented_vehicles.plate, users.accounts FROM rented_vehicles LEFT JOIN users ON rented_vehicles.owner = users.identifier', {},
	function(rentals)
		local owners = {}
		for i = 1, #rentals do
			local rental = rentals[i]
			if not owners[rental.owner] then
				owners[rental.owner] = {rental}
			else
				owners[rental.owner][#owners[rental.owner] + 1] = rental
			end
		end

		local total = 0
		local unrentals = {}
		local users = {}
		for k, v in pairs(owners) do
			local sum = 0
			for i = 1, #v do
				sum = sum + v[i].rent_price
			end
			local xPlayer = ESX.GetPlayerFromIdentifier(k)

			if xPlayer then
				local bank = xPlayer.getAccount('bank').money

				if bank >= sum and #v > 1 then
					total = total + sum
					xPlayer.removeAccountMoney('bank', sum, "Vehicle Rental")
					xPlayer.showNotification(('You have paid $%s for all of your rentals'):format(ESX.Math.GroupDigits(sum)))
				else
					for i = 1, #v do
						local rental = v[i]
						if xPlayer.getAccount('bank').money >= rental.rent_price then
							total = total + rental.rent_price
							xPlayer.removeAccountMoney('bank', rental.rent_price, "Vehicle Rental")
							xPlayer.showNotification(_U('paid_rental', ESX.Math.GroupDigits(rental.rent_price), rental.plate))
						else
							xPlayer.showNotification(_U('paid_rental_evicted', ESX.Math.GroupDigits(rental.rent_price), rental.plate))
							unrentals[#unrentals + 1] = {rental.owner, rental.plate}
						end
					end
				end
			else
				local accounts = json.decode(v[1].accounts)
				if accounts.bank < sum then
					sum = 0
					local limit = false
					for i = 1, #v do
						local rental = v[i]
						if not limit then
							sum = sum + rental.rent_price
							if sum > accounts.bank then
								sum = sum - rental.rent_price
								limit = true
							end
						else
							unrentals[#unrentals + 1] = {rental.owner, rental.plate}
						end
					end
				end
				if sum > 0 then
					total = total + sum
					accounts.bank = accounts.bank - sum
					users[#users + 1] = {json.encode(accounts), k}
				end
			end
		end

		if total > 0 then
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
				account.addMoney(total)
			end)
		end

		if next(users) then
			MySQL.prepare.await('UPDATE users SET accounts = ? WHERE identifier = ?', users)
		end

		if next(unrentals) then
			MySQL.prepare.await('DELETE FROM rented_vehicles WHERE owner = ? AND plate = ?', unrentals)
		end

		print(('[^2INFO^7] ^5Rent Payments^7 took ^5%s^7 ms to execute'):format(ESX.Math.Round((os.time() - timeStart) / 1000000, 2)))
	end)
end

TriggerEvent('cron:runAt', 22, 00, PayRent)
