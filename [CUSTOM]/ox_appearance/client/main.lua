local shops = {
	clothing = {
		vec(72.3, -1399.1, 28.4),
		vec(-708.71, -152.13, 36.4),
		vec(-165.15, -302.49, 38.6),
		vec(428.7, -800.1, 28.5),
		vec(-829.4, -1073.7, 10.3),
		vec(-1449.16, -238.35, 48.8),
		vec(11.6, 6514.2, 30.9),
		vec(122.98, -222.27, 53.5),
		vec(1696.3, 4829.3, 41.1),
		vec(618.1, 2759.6, 41.1),
		vec(1190.6, 2713.4, 37.2),
		vec(-1193.4, -772.3, 16.3),
		vec(-3172.5, 1048.1, 19.9),
		vec(-1108.4, 2708.9, 18.1),
		-- add 4th argument to create vector4 and disable blip
		vec(300.60162353516, -597.76068115234, 42.18409576416, 0),
		vec(461.47720336914, -998.05444335938, 30.201751708984, 0),
		vec(-1622.6466064453, -1034.0192871094, 13.145475387573, 0),
		vec(1861.1047363281, 3689.2331542969, 34.276859283447, 0),
		vec(1834.5977783203, 3690.5405273438, 34.270645141602, 0),
		vec(1742.1407470703, 2481.5856933594, 45.740657806396, 0),
		vec(516.8916015625, 4823.5693359375, -66.18879699707, 0),
	},

	barber = {
		vec(-814.3, -183.8, 36.6),
		vec(136.8, -1708.4, 28.3),
		vec(-1282.6, -1116.8, 6.0),
		vec(1931.5, 3729.7, 31.8),
		vec(1212.8, -472.9, 65.2),
		vec(-34.31, -154.99, 55.8),
		vec(-278.1, 6228.5, 30.7),
	},

	tattoos = {
		vec(1322.6, -1651.9, 51.2),
		vec(-1153.6, -1425.6, 4.9),
		vec(322.1, 180.4, 103.5),
		vec(-3170.0, 1075.0, 20.8),
		vec(1864.6, 3747.7, 33.0),
		vec(-293.7, 6200.0, 31.4)
	}
}

local function createBlip(name, sprite, colour, scale, location)
	if not location.w then
		local blip = AddBlipForCoord(location.x, location.y)
		SetBlipSprite(blip, sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, scale)
		SetBlipColour(blip, colour)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(name)
		EndTextCommandSetBlipName(blip)
	end
end

for i = 1, #shops.clothing do
	createBlip('Clothing store', 73, 47, 0.7, shops.clothing[i])
end

for i = 1, #shops.barber do
	createBlip('Barber shop', 71, 47, 0.7, shops.barber[i])
end

for i = 1, #shops.tattoos do
	createBlip('Tattoo studio', 75, 1, 0.7, shops.tattoos[i])
end

local shopType
local config = {
	clothing = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = false,
		components = true,
		props = true,
		tattoos = false
	},

	barber = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = true,
		components = false,
		props = false,
		tattoos = false
	},

	tattoos = {
		ped = false,
		headBlend = false,
		faceFeatures = false,
		headOverlays = false,
		components = false,
		props = false,
		tattoos = true
	}
}

local function getClosestShop(currentShop, coords)
	local closestShop = #(currentShop.xyz - coords)

	if closestShop > 25 then
		for name, data in pairs(shops) do
			for i = 1, #data do
				Wait(100)
				local distance = #(data[i].xyz - coords)
				if distance < closestShop then
					closestShop = distance
					currentShop = data[i]
					shopType = name
				end
			end
		end
	end

	if closestShop > 25 then
		Wait(1000)
	else
		Wait(0)
	if closestShop < 7 then
			if not show then 
				show = true
				
			if IsControlJustReleased(0, 38) then
				exports['fivem-appearance']:startPlayerCustomization(function(appearance)
					if (appearance) then
						if ESX then
							TriggerServerEvent('esx_skin:save', appearance)
						else
							TriggerServerEvent('ox_appearance:save', appearance)
						end
					end
				end, config[shopType])
			end
		end
	end
end
	return currentShop
end

CreateThread(function()
	local currentShop = vec(0, 0, 0)

	while true do
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		currentShop = getClosestShop(currentShop, playerCoords)
	end
end)