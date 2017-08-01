ESX                  = nil
local HasLoadedModel = false
local LastSkin       = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function OpenMenu(submitCb, cancelCb, restrict)

	TriggerEvent('skinchanger:getSkin', function(skin)
		LastSkin = skin
	end)

	TriggerEvent('skinchanger:getData', function(components, maxVals)

		local elements    = {}
		local _components = {}

		-- Restrict menu
		if restrict == nil then
			for i=1, #components, 1 do
				_components[i] = components[i]
			end
		else
			for i=1, #components, 1 do

				local found = false

				for j=1, #restrict, 1 do
					if components[i].name == restrict[j] then
						found = true
					end
				end

				if found then
					table.insert(_components, components[i])
				end

			end
		end

		-- Insert elements
		for i=1, #_components, 1 do
							
			local data = {
				label     = _components[i].label,
				name      = _components[i].name,	
				value     = _components[i].value,
				textureof = _components[i].textureof,
				type      = 'slider'
			}

			for k,v in pairs(maxVals) do
				if k == _components[i].name then
					data.max = v
				end
			end

			table.insert(elements, data)

		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'skin',
			{
				title = 'Skin Menu',
				align = 'top-left',
				elements = elements
			},
			submitCb,
			function(data, menu)
				
				menu.close()

				TriggerEvent('skinchanger:loadSkin', LastSkin)

				if cancelCb ~= nil then
					cancelCb(data, menu)
				end

			end,
			function(data, menu)

				TriggerEvent('skinchanger:getSkin', function(skin)
					
					if skin[data.current.name] ~= data.current.value then

						-- Change skin element
						TriggerEvent('skinchanger:change', data.current.name, data.current.value)

						-- Update max values
						TriggerEvent('skinchanger:getData', function(components, maxVals)
							for i=1, #elements, 1 do
								if elements[i].textureof ~= nil then
									
									local newData = {max = maxVals[elements[i].name]}

									if data.current.name == elements[i].textureof then
										newData.value = 0
									end

									menu.update({name = elements[i].name}, newData)
									
								end
							end
						end)

					end

				end)

			end
		)

	end)

end

function OpenSaveableMenu(submitCb, cancelCb, restrict)

	TriggerEvent('skinchanger:getSkin', function(skin)
		LastSkin = skin
	end)

	OpenMenu(function(data, menu)

		menu.close()

		TriggerEvent('skinchanger:getSkin', function(skin)

			TriggerServerEvent('esx_skin:save', skin)

			if submitCb ~= nil then
				submitCb(data, menu)
			end

		end)

	end, cancelCb, restrict)

end

AddEventHandler('playerSpawned', function()
	TriggerEvent('skinchanger:LoadDefaultModel', true)
end)

AddEventHandler('esx_skin:getLastSkin', function(cb)
	cb(LastSkin)
end)

RegisterNetEvent('esx_skin:openMenu')
AddEventHandler('esx_skin:openMenu', function(submitCb, cancelCb)
	OpenMenu(submitCb, cancelCb, nil)
end)

RegisterNetEvent('esx_skin:openRestrictedMenu')
AddEventHandler('esx_skin:openRestrictedMenu', function(submitCb, cancelCb, restrict)
	OpenMenu(submitCb, cancelCb, restrict)
end)

RegisterNetEvent('esx_skin:openSaveableMenu')
AddEventHandler('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
	OpenSaveableMenu(submitCb, cancelCb, nil)
end)

RegisterNetEvent('esx_skin:openSaveableRestrictedMenu')
AddEventHandler('esx_skin:openSaveableRestrictedMenu', function(submitCb, cancelCb, restrict)
	OpenSaveableMenu(submitCb, cancelCb, restrict)
end)

AddEventHandler('skinchanger:modelLoaded', function()
	
	if not HasLoadedModel then
		
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)

			HasLoadedModel = true

			if skin == nil then
				OpenSaveableMenu(nil, nil, nil)
			else
				TriggerEvent('skinchanger:loadSkin', skin)
			end

		end)

	end
end)

Citizen.CreateThread(function()
	while true do
		
		Citizen.Wait(0)
		
		local playerPed = GetPlayerPed(-1)

		if IsEntityDead(playerPed) then
			HasLoadedModel = false
		end

	end
end)