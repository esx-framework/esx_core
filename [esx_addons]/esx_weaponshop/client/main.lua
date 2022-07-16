local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local ShopOpen = false

function OpenBuyLicenseMenu(zone)
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_license', {
		title = _U('buy_license'),
		align = 'top-left',
		elements = {
			{label = _U('no'), value = 'no'},
			{label = _U('yes', ('<span style="color: green;">%s</span>'):format((_U('shop_menu_item', ESX.Math.GroupDigits(Config.LicensePrice))))), value = 'yes'},
		}
	}, function(data, menu)
		if data.current.value == 'yes' then
			ESX.TriggerServerCallback('esx_weaponshop:buyLicense', function(bought)
				if bought then
					menu.close()
					OpenShopMenu(zone)
				end
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenShopMenu(zone)
	local elements = {}
	ShopOpen = true

	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]
		item.label = ESX.GetWeaponLabel(item.name)

		table.insert(elements, {
			label = ('%s - <span style="color: green;">%s</span>'):format(item.label, _U('shop_menu_item', ESX.Math.GroupDigits(item.price))),
			price = item.price,
			weaponName = item.name
		})
	end

	ESX.UI.Menu.CloseAll()
	PlaySoundFrontend(-1, 'BACK', 'UD_AMMO_SHOP_SOUNDSET', false)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title = _U('shop_menu_title'),
		align = 'top-left',
		elements = elements
	}, function(data, menu)
		ESX.TriggerServerCallback('esx_weaponshop:buyWeapon', function(bought)
			if bought then
				DisplayBoughtScaleform(data.current.weaponName, data.current.price)
			else
				PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)
			end
		end, data.current.weaponName, zone)
	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
		ShopOpen = false
		menu.close()

		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('shop_menu_prompt')
		CurrentActionData = { zone = zone }
	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
end

function DisplayBoughtScaleform(weaponName, price)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
	local sec = 4

	BeginScaleformMovieMethod(scaleform, 'SHOW_WEAPON_PURCHASED')

	ScaleformMovieMethodAddParamTextureNameString(_U('weapon_bought', ESX.Math.GroupDigits(price)))
	ScaleformMovieMethodAddParamTextureNameString(ESX.GetWeaponLabel(weaponName))
	ScaleformMovieMethodAddParamInt(GetHashKey(weaponName))
	ScaleformMovieMethodAddParamTextureNameString('')
	ScaleformMovieMethodAddParamInt(100)
	EndScaleformMovieMethod()

	PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)

	CreateThread(function()
		while sec > 0 do
			Wait(0)
			sec = sec - 0.01
	
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		end
	end)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if ShopOpen then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

-- Create Blips
CreateThread(function()
	for k,v in pairs(Config.Zones) do
		if v.Legal then
			for i = 1, #v.Locations, 1 do
				local blip = AddBlipForCoord(v.Locations[i])

				SetBlipSprite (blip, 110)
				SetBlipDisplay(blip, 4)
				SetBlipScale  (blip, 0.8)
				SetBlipColour (blip, 81)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentSubstringPlayerName(_U('map_blip'))
				EndTextCommandSetBlipName(blip)
			end
		end
	end
end)

local TextShown = false

-- Display markers
CreateThread(function()
	while true do
		local Sleep = 1500
		local InShop = false
		local CurrentShop = nil
		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Locations, 1 do
				if (Config.Type ~= -1 and #(coords - v.Locations[i]) < Config.DrawDistance) then
					InShop = true
					CurrentShop = v.Locations[i]
					Sleep = 0
					if #(coords - CurrentShop) < 2.0 then
							if not TextShown then 
								ESX.TextUI(_U('shop_menu_prompt'))
								TextShown = true
							end
							if IsControlJustReleased(0, 38) then
								if Config.LicenseEnable and v.Legal then
									ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
										if hasWeaponLicense then
											OpenShopMenu(k)
										else
											OpenBuyLicenseMenu(k)
										end
									end, GetPlayerServerId(PlayerId()), 'weapon')
								else
									OpenShopMenu(k)
								end
							end
						end
						end
					DrawMarker(Config.Type, v.Locations[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		if not CurrentShop and TextShown then 
			TextShown = false
			ESX.HideUI()
		end
		if not InShop and ShopOpen then
			if ShopOpen then
				TextShown = false
				ESX.HideUI()
				ESX.UI.Menu.CloseAll()
				ShopOpen = false
			end
		end
	Wait(Sleep)
	end
end)
