local menuOpen = false
local inZoneDrugShop = false
local inRangeMarkerDrugShop = false
local cfgMarker = Config.Marker;

--slow loop
CreateThread(function()
	while true do
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local distDrugShop = #(coords - Config.CircleZones.DrugDealer.coords)

		inRangeMarkerDrugShop = false
		if(distDrugShop <= Config.Marker.Distance) then
			inRangeMarkerDrugShop = true
		end

		if distDrugShop < 1 then
			inZoneDrugShop = true
		else
			inZoneDrugShop = false
			if menuOpen then
				menuOpen=false
			end
		end

		Wait(500)
	end
end)

--drawk marker
CreateThread(function()
	while true do 
		local Sleep = 1500
		if(inRangeMarkerDrugShop) then
			Sleep = 0
			local coordsMarker = Config.CircleZones.DrugDealer.coords
			local color = cfgMarker.Color
			DrawMarker(cfgMarker.Type, coordsMarker.x, coordsMarker.y,coordsMarker.z - 1.0,
			0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
			cfgMarker.Size, color.r,color.g,color.b,color.a,
			false, true, 2, false, nil, nil, false)
		end
		Wait(Sleep)
	end
end)

--main loop
CreateThread(function ()
	while true do 
		local Sleep = 1500
		if inZoneDrugShop and not menuOpen then
			Sleep = 0
			ESX.ShowHelpNotification(TranslateCap('dealer_prompt'),true)
			if IsControlJustPressed(0, 38) then
				OpenDrugShop()
			end
		end
	Wait(Sleep)
	end
end)

function OpenDrugShop()
	local elements = {
		{unselectable = true, icon = "fas fa-cannabis", title = TranslateCap('dealer_title')}
	}
	menuOpen = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.DrugDealerItems[v.name]

		if price and v.count > 0 then
			elements[#elements+1] = {
				icon = "fas fa-shopping-basket",
				title = ('%s - <span style="color:green;">%s</span>'):format(v.label, TranslateCap('dealer_item', ESX.Math.GroupDigits(price))),
				name = v.name,
				price = price,
			}
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local elements2 = {
			{unselectable = true, icon = "fas fa-shopping-basket", title = element.title},
			{icon = "fas fa-shopping-basket", title = "Amount", input = true, inputType = "number", inputPlaceholder = "Amount you want to sell", inputMin = Config.SellMenu.Min, inputMax = Config.SellMenu.Max},
			{icon = "fas fa-check-double", title = "Confirm", val = "confirm"}
		}

		ESX.OpenContext("right", elements2, function(menu2,element2)
			local amount = menu2.eles[2].inputValue
			ESX.CloseContext()
			TriggerServerEvent('esx_drugs:sellDrug', element.name, amount)
		end, function(menu)
			menuOpen = false
		end)
	end, function(menu)
		menuOpen = false
	end)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuOpen then
			ESX.CloseContext()
		end
	end
end)

function OpenBuyLicenseMenu(licenseName)
	menuOpen = true
	local license = Config.LicensePrices[licenseName]

	local elements = {
		{unselectable = true, title = TranslateCap('purchase_license')},
		{title = ('%s - <span style="color:green;">%s</span>'):format(license.label, TranslateCap('dealer_item', ESX.Math.GroupDigits(license.price))), value = licenseName, price = license.price, licenseName = license.label}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		ESX.TriggerServerCallback('esx_drugs:buyLicense', function(boughtLicense)
			if boughtLicense then
				ESX.CloseContext()
				ESX.ShowNotification(TranslateCap('license_bought', element.licenseName, ESX.Math.GroupDigits(element.price)))
			else
				ESX.ShowNotification(TranslateCap('license_bought_fail', element.licenseName))
			end
		end, element.value)
	end, function(menu)
		menuOpen = false
	end)
end

function CreateBlipCircle(coords, text, radius, color, sprite)
	local blip = AddBlipForRadius(coords, radius)

	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, 1)
	SetBlipAlpha (blip, 128)

	-- create a blip in the middle
	blip = AddBlipForCoord(coords)

	SetBlipHighDetail(blip, true)
	SetBlipSprite (blip, sprite)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, color)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
end

CreateThread(function()
	for k,zone in pairs(Config.CircleZones) do
		CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
	end
end)
