local Vehicles
local Customs = {}

RegisterNetEvent('esx_lscustom:startModing', function(props, netId)
	local src = tostring(source)
	if Customs[src] then
		Customs[src][props.plate] = {props = props, netId = netId}
	else
		Customs[src] = {}
		Customs[src][props.plate] = {props = props, netId = netId}
	end
end)

RegisterNetEvent('esx_lscustom:stopModing', function(plate)
	local src = tostring(source)
	if Customs[src] then
		Customs[src][tostring(plate)] = nil
	end
end)

AddEventHandler('esx:playerDropped', function(src)
	src = tostring(src)
	local playersCount = #ESX.GetExtendedPlayers()
	if Customs[src] then
		for k,v in pairs(Customs[src]) do
			local entity = NetworkGetEntityFromNetworkId(v.netId)
			if DoesEntityExist(entity) then
				if playersCount > 0 then
					TriggerClientEvent('esx_lscustom:restoreMods', -1, v.netId, v.props)
				else
					DeleteEntity(entity)
				end
			end
		end
		Customs[src] = nil
	end
end)

RegisterServerEvent('esx_lscustom:buyMod')
AddEventHandler('esx_lscustom:buyMod', function(price)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	price = tonumber(price)

	if Config.IsMechanicJobOnly then
		local societyAccount

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
			societyAccount = account
		end)

		if price < societyAccount.money then
			TriggerClientEvent('esx_lscustom:installMod', source)
			TriggerClientEvent('esx:showNotification', source, TranslateCap('purchased'))
			societyAccount.removeMoney(price)
		else
			TriggerClientEvent('esx_lscustom:cancelInstallMod', source)
			TriggerClientEvent('esx:showNotification', source, TranslateCap('not_enough_money'))
		end
	else
		if price < xPlayer.getMoney() then
			TriggerClientEvent('esx_lscustom:installMod', source)
			TriggerClientEvent('esx:showNotification', source, TranslateCap('purchased'))
			xPlayer.removeMoney(price, "LSC Purchase")
		else
			TriggerClientEvent('esx_lscustom:cancelInstallMod', source)
			TriggerClientEvent('esx:showNotification', source, TranslateCap('not_enough_money'))
		end
	end
end)

RegisterServerEvent('esx_lscustom:refreshOwnedVehicle')
AddEventHandler('esx_lscustom:refreshOwnedVehicle', function(vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.single('SELECT vehicle FROM owned_vehicles WHERE plate = ?', {vehicleProps.plate},
	function(result)
		if result then
			local vehicle = json.decode(result.vehicle)
			if vehicleProps.model == vehicle.model then
				MySQL.update('UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?', {json.encode(vehicleProps), vehicleProps.plate})
				Customs[tostring(source)][tostring(vehicleProps.plate)].props = vehicleProps
			else
				print(('[^3WARNING^7] Player ^5%s^7 Attempted To upgrade with mismatching vehicle model'):format(xPlayer.source))
			end
		end
	end)
end)

ESX.RegisterServerCallback('esx_lscustom:getVehiclesPrices', function(source, cb)
	if not Vehicles then
		Vehicles = MySQL.query.await('SELECT model, price FROM vehicles')
	end
	cb(Vehicles)
end)
