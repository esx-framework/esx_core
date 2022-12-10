local hasAlreadyEnteredMarker, lastZone
local currentAction, currentActionMsg, currentActionData = nil, nil, {}
local resourceName = GetCurrentResourceName()

function OpenShopMenu(zone)
	local elements = {
		{unselectable = true, icon = "fas fa-shopping-basket", title = TranslateCap('shop') }
	}

	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]
		elements[#elements+1] = {
			icon = "fas fa-shopping-basket",
			title = ('%s - <span style="color:green;">%s</span>'):format(item.label, TranslateCap('shop_item', ESX.Math.GroupDigits(item.price))),
			itemLabel = item.label,
			item = item.name,
			price = item.price
		}
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local elements2 = {
			{unselectable = true, icon = "fas fa-shopping-basket", title = element.title},
			{icon = "fas fa-shopping-basket", title = "Amount", input = true, inputType = "number", inputPlaceholder = "Amount you want to buy", inputMin = 1, inputMax = 25},
			{icon = "fas fa-check-double", title = "Confirm", val = "confirm"}
		}

		ESX.OpenContext("right", elements2, function(menu2,element2)
			local amount = menu2.eles[2].inputValue
			ESX.CloseContext()
			TriggerServerEvent('esx_shops:buyItem', element.item, amount, zone)
		end, function(menu)
			currentAction     = 'shop_menu'
			currentActionMsg  = TranslateCap('press_menu')
			currentActionData = {zone = zone}
		end)
	end, function(menu)
		currentAction     = 'shop_menu'
		currentActionMsg  = TranslateCap('press_menu')
		currentActionData = {zone = zone}
	end)
end

AddEventHandler('esx_shops:hasEnteredMarker', function(zone)
	currentAction     = 'shop_menu'
	currentActionMsg  = TranslateCap('press_menu')
	currentActionData = {zone = zone}
	ESX.TextUI(currentActionMsg)
end)

AddEventHandler('esx_shops:hasExitedMarker', function(zone)
	ESX.HideUI()
	currentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Create Blips
CreateThread(function()
	for k,v in pairs(Config.Zones) do
		for i = 1, #v.Pos, 1 do
			if v.ShowBlip then
			local blip = AddBlipForCoord(v.Pos[i])

			SetBlipSprite (blip, v.Type)
			SetBlipScale  (blip, v.Size)
			SetBlipColour (blip, v.Color)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(TranslateCap('shops'))
			EndTextCommandSetBlipName(blip)
			end
		end
	end
end)

ESX.RegisterInput("shops:interact", "(ESX Shops): Interact", "keyboard", "E", function()
	if not currentAction then return end
			if currentAction == 'shop_menu' then
				ESX.HideUI()
				OpenShopMenu(currentActionData.zone)
			end
			currentAction = nil
end)

-- Enter / Exit marker events
CreateThread(function()
	while true do
		local Sleep = 1500

		local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
		local isInMarker, currentZone = false, nil

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				local distance = #(playerCoords - v.Pos[i])

				if distance < Config.DrawDistance then
					Sleep = 0
					if v.ShowMarker then
						DrawMarker(Config.MarkerType, v.Pos[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
				  end
					if distance < 2.0 then
						isInMarker  = true
						currentZone = k
						lastZone    = k
					end
				end
			end
		end

		if isInMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			TriggerEvent('esx_shops:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_shops:hasExitedMarker', lastZone)
		end
	Wait(Sleep)
	end
end)
