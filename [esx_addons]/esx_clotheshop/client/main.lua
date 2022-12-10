
local hasAlreadyEnteredMarker, hasPaid, currentActionData = false, false, {}
local lastZone, currentAction, currentActionMsg

function OpenShopMenu()
	hasPaid = false

	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
		menu.close()

		local elements = {
			{unselectable = true, icon = "fas fa-check-double", title = TranslateCap("valid_this_purchase")},
			{icon = "fas fa-check-circle", title = TranslateCap("yes"), value = "yes"},
			{icon = "fas fa-window-close", title = TranslateCap("no"), value = "no"},
		}

		ESX.OpenContext("right", elements, function(menu,element)
			if element.value == "yes" then
				ESX.TriggerServerCallback('esx_clotheshop:buyClothes', function(bought)
					if bought then
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('esx_skin:save', skin)
						end)

						hasPaid = true
						ESX.TriggerServerCallback('esx_clotheshop:checkPropertyDataStore', function(foundStore)
							if foundStore then
								local elements2 = {
									{unselectable = true, icon = "fas fa-check-double", title = TranslateCap('save_in_dressing')},
									{icon = "fas fa-check-circle", title = TranslateCap("yes"), value = "yes"},
									{icon = "fas fa-window-close", title = TranslateCap("no"), value = "no"},
								}

								ESX.OpenContext("right", elements2, function(menu2,element2)
									if element2.value == "yes" then
										local elements3 = {
											{unselectable = true, icon = "fas fa-shirt", title = TranslateCap('name_outfit')},
											{title = "Outfit Name", input = true, inputType = "text", inputPlaceholder = "Outfit name in wardrobe.."},
											{icon = "fas fa-check-circle", title = "Confirm", value = "confirm"}
										}

										ESX.OpenContext("right", elements3, function(menu3,element3)
											TriggerEvent('skinchanger:getSkin', function(skin)
												ESX.CloseContext()
												TriggerServerEvent('esx_clotheshop:saveOutfit', menu3.eles[2].inputValue, skin)
												ESX.ShowNotification(TranslateCap('saved_outfit'))
											end)
										end)
									elseif element2.value == "no" then
										ESX.CloseContext()
									end
								end)
							end
						end)
					else
						ESX.CloseContext()
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
						end)
						ESX.ShowNotification(TranslateCap('not_enough_money'))
					end
				end)
			elseif element.value == "no" then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
				ESX.CloseContext()
			end
			currentAction     = 'shop_menu'
			currentActionMsg  = TranslateCap('press_menu')
			currentActionData = {}
		end, function(menu)
			currentAction     = 'shop_menu'
			currentActionMsg  = TranslateCap('press_menu')
			currentActionData = {}
		end)

	end, function(data, menu)
		menu.close()

		currentAction     = 'shop_menu'
		currentActionMsg  = TranslateCap('press_menu')
		currentActionData = {}
	end, {
		'tshirt_1', 'tshirt_2',
		'torso_1', 'torso_2',
		'decals_1', 'decals_2',
		'arms',	'arms_2',
		'pants_1', 'pants_2',
		'shoes_1', 'shoes_2',
        'bags_1', 'bags_2',
		'chain_1', 'chain_2',
		'helmet_1', 'helmet_2',
		'glasses_1', 'glasses_2'
	})
end

AddEventHandler('esx_clotheshop:hasEnteredMarker', function(zone)
	currentAction     = 'shop_menu'
	currentActionMsg  = TranslateCap('press_menu')
	currentActionData = {}
	ESX.TextUI(currentActionMsg)
end)

AddEventHandler('esx_clotheshop:hasExitedMarker', function(zone)
	ESX.HideUI()
	ESX.CloseContext()
	currentAction = nil

	if not hasPaid then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
	end
end)

if Config.Blip.Enabled then
  CreateThread(function()
    for i = 1, #Config.Shops, 1 do
      local blip = AddBlipForCoord(Config.Zones[i])

      SetBlipSprite(blip, Config.Blip.Sprite)
      SetBlipDisplay(blip, Config.Blip.Display)
      SetBlipScale(blip, Config.Blip.Scale)
      SetBlipColour(blip, Config.Blip.Colour)
      SetBlipAsShortRange(blip, Config.Blip.ShortRange)

      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName(TranslateCap('clothes'))
      EndTextCommandSetBlipName(blip)
    end
  end)
end

-- Create Blips
CreateThread(function()
	for i=1, #(Config.Shops) do
		local blip = AddBlipForCoord(Config.Shops[i])

		SetBlipSprite (blip, 73)
		SetBlipColour (blip, 47)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('clothes'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Enter / Exit marker events & draw markers
CreateThread(function()
	while true do
		local Sleep = 1000
		local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(ESX.PlayerData.ped), false, nil, true

		for k,v in pairs(Config.Shops) do
			local distance = #(playerCoords - v)

			if distance < Config.DrawDistance then
				Sleep = 0
				DrawMarker(Config.MarkerType, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)

				if distance < Config.MarkerSize.x then
					isInMarker, currentZone = true, k
				end
			end
		end

		if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
			hasAlreadyEnteredMarker, lastZone = true, currentZone
			TriggerEvent('esx_clotheshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_clotheshop:hasExitedMarker', lastZone)
		end

		Wait(Sleep)
	end
end)

ESX.RegisterInput("clotheshop:interact", "(ESX ClotheShop): Open Shop", "keyboard", "e", function()
	if not currentAction then return end 
	if currentAction ~= "shop_menu" then return end
	OpenShopMenu()
	currentAction = nil
end)
