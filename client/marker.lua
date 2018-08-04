local HasAlreadyEnteredMarker = false
local LastZone                = nil

CurrentAction     = nil
CurrentActionMsg  = ''
CurrentActionData = {}

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if CurrentAction == nil then
			Citizen.Wait(200)
		else

			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) then

				if CurrentAction == 'boat_shop' then
					OpenBoatShop(Config.Zones.BoatShops[CurrentActionData.zoneNum])
				end

				CurrentAction = nil
			end
		end
	end
end)

AddEventHandler('esx_boat:hasEnteredMarker', function(zone, zoneNum)
	print(zone)
	print(zoneNum)

	if zone == 'boat_shop' then
		CurrentAction     = 'boat_shop'
		CurrentActionMsg  = _U('boat_shop_open')
		CurrentActionData = { zoneNum = zoneNum }
	end
end)

AddEventHandler('esx_boat:hasExitedMarker', function()
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

-- Draw markers
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)

		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		for i=1, #Config.Zones.BoatShops, 1 do
			local zone = Config.Zones.BoatShops[i].Outside
			if GetDistanceBetweenCoords(coords, zone.x, zone.y, zone.z, true) < Config.DrawDistance then
				DrawMarker(Config.MarkerType, zone.x, zone.y, zone.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end

	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()

	while true do

		Citizen.Wait(1)

		local playerPed      = PlayerPedId()
		local coords         = GetEntityCoords(playerPed)
		local isInMarker     = false
		local currentZone    = nil
		local currentZoneNum = nil

			for i=1, #Config.Zones.BoatShops, 1 do

				if GetDistanceBetweenCoords(coords, Config.Zones.BoatShops[i].Outside.x, Config.Zones.BoatShops[i].Outside.y, Config.Zones.BoatShops[i].Outside.z,  true) < Config.MarkerSize.x then
					isInMarker     = true
					currentZone    = 'boat_shop'
					currentZoneNum = i
				end

--[[
					if GetDistanceBetweenCoords(coords,  v.Helicopters[i].SpawnPoint.x,  v.Helicopters[i].SpawnPoint.y,  v.Helicopters[i].SpawnPoint.z,  true) < Config.MarkerSize.x then
					isInMarker     = true
					currentZone    = 'HelicopterSpawnPoint'
					currentZoneNum = i
				end
				extra för garage
]] 

			

			end

		local hasExited = false

		if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastZone ~= currentZone or LastZoneNum ~= currentZoneNum) ) then

			if
				(LastZone ~= nil and LastZoneNum ~= nil) and
				(LastZone ~= currentZone or LastZoneNum ~= currentZoneNum)
			then
				TriggerEvent('esx_boat:hasExitedMarker', LastZone)
				hasExited = true
			end

			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			LastZoneNum             = currentZoneNum

			TriggerEvent('esx_boat:hasEnteredMarker', currentZone, currentZoneNum)
		end

		if not hasExited and not isInMarker and HasAlreadyEnteredMarker then

			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_boat:hasExitedMarker')
		end

	end
end)
