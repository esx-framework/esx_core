local menuIsShowed = false

function ShowJobListingMenu()
	menuIsShowed = true
	ESX.TriggerServerCallback('esx_joblisting:getJobsList', function(jobs)
		local elements = {}

		for k,v in pairs(jobs) do
			table.insert(elements, {
				label = v.label,
				job   = k
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'joblisting', {
			title    = _U('job_center'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			TriggerServerEvent('esx_joblisting:setJob', data.current.job)
			ESX.ShowNotification(_U('new_job'))
			menuIsShowed = false
			menu.close()
		end, function(data, menu)
			menuIsShowed = false
			menu.close()
		end)

	end)
end

-- Activate menu when player is inside marker, and draw markers
CreateThread(function()
	while true do
		local Sleep = 1500

		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker = false

		for i=1, #Config.Zones, 1 do
			local distance = #(coords - Config.Zones[i])

			if distance < Config.DrawDistance then
				Sleep = 0
				DrawMarker(Config.MarkerType, Config.Zones[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end

			if distance < (Config.ZoneSize.x / 2) then
				isInMarker = true
				ESX.ShowHelpNotification(_U('access_job_center'))
				if IsControlJustReleased(0, 38) and not menuIsShowed then
					ESX.UI.Menu.CloseAll()
					ShowJobListingMenu()
				end
			end
		end

		if not isInMarker and menuIsShowed then 
			ESX.UI.Menu.CloseAll()
			menuIsShowed = false
		end

		Wait(Sleep)
	end
end)

-- Create blips
CreateThread(function()
	for i=1, #Config.Zones, 1 do
		local blip = AddBlipForCoord(Config.Zones[i])

		SetBlipSprite (blip, Config.Blip.Sprite)
		SetBlipDisplay(blip, Config.Blip.Display)
		SetBlipScale  (blip, Config.Blip.Scale)
		SetBlipColour (blip, Config.Blip.Colour)
		SetBlipAsShortRange(blip, Config.Blip.ShortRange)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('job_center'))
		EndTextCommandSetBlipName(blip)
	end
end)
