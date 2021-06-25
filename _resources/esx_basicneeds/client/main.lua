<<<<<<< HEAD
ESX = nil
local Status, isPaused = {}, false
=======
ESX          = nil
local IsDead = false
local IsAnimated = false
>>>>>>> esx_basicneeds/master

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

<<<<<<< HEAD
function GetStatusData(minimal)
	local status = {}

	for i=1, #Status, 1 do
		if minimal then
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		else
			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				color   = Status[i].color,
				visible = Status[i].visible(Status[i]),
				percent = (Status[i].val / Config.StatusMax) * 100
			})
		end
	end

	return status
end

AddEventHandler('esx_status:registerStatus', function(name, default, color, visible, tickCallback)
	local status = CreateStatus(name, default, color, visible, tickCallback)
	table.insert(Status, status)
end)

AddEventHandler('esx_status:unregisterStatus', function(name)
	for k,v in ipairs(Status) do
		if v.name == name then
			table.remove(Status, k)
			break
		end
	end
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	Status = {}
	if Config.Display then
		SendNUIMessage({
			update = true,
			status = Status
		})
	end
end)

RegisterNetEvent('esx_status:load')
AddEventHandler('esx_status:load', function(status)
	TriggerEvent('esx_status:loaded')
	for i=1, #Status, 1 do
		for j=1, #status, 1 do
			if Status[i].name == status[j].name then
				Status[i].set(status[j].val)
			end
		end
	end

	if Config.Display then TriggerEvent('esx_status:setDisplay', 0.5) end

	Citizen.CreateThread(function()
		while #Status > 0 do
			for i=1, #Status, 1 do
				Status[i].onTick()
			end
			local data = GetStatusData(true)
			
			if Config.Display then
				local fullData = data
				for i=1, #data, 1 do
					fullData[i].color = Status[i].color
					fullData[i].visible = Status[i].visible(Status[i])
				end
				SendNUIMessage({
					update = true,
					status = fullData
				})
			end

			TriggerEvent('esx_status:onTick', data)
			Citizen.Wait(Config.TickTime)
		end
	end)
end)

RegisterNetEvent('esx_status:set')
AddEventHandler('esx_status:set', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].set(val)
			break
		end
	end
	if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].add(val)
			break
		end
	end
	if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(name, val)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].remove(val)
			break
		end
	end
		if Config.Display then
		SendNUIMessage({
			update = true,
			status = GetStatusData()
		})
	end
end)

AddEventHandler('esx_status:getStatus', function(name, cb)
	for i=1, #Status, 1 do
		if Status[i].name == name then
			cb(Status[i])
			return
		end
	end
end)

AddEventHandler('esx_status:setDisplay', function(val)
	SendNUIMessage({
		setDisplay = true,
		display    = val
	})
end)

-- Pause menu disable hud display
Citizen.CreateThread(function()
	while true do
		if Config.Display then
			Citizen.Wait(300)

			if IsPauseMenuActive() and not isPaused then
				isPaused = true
				TriggerEvent('esx_status:setDisplay', 0.0)
			elseif not IsPauseMenuActive() and isPaused then
				isPaused = false 
				TriggerEvent('esx_status:setDisplay', 0.5)
			end
		else Citizen.Wait(1000) end
	end
end)

-- Loading screen off event
AddEventHandler('esx:loadingScreenOff', function()
	if not isPaused then
		TriggerEvent('esx_status:setDisplay', 0.3)
	end
end)

-- Update server
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.UpdateInterval)

		TriggerServerEvent('esx_status:update', GetStatusData(true))
=======
AddEventHandler('esx_basicneeds:resetStatus', function()
	TriggerEvent('esx_status:set', 'hunger', 500000)
	TriggerEvent('esx_status:set', 'thirst', 500000)
end)

RegisterNetEvent('esx_basicneeds:healPlayer')
AddEventHandler('esx_basicneeds:healPlayer', function()
	-- restore hunger & thirst
	TriggerEvent('esx_status:set', 'hunger', 1000000)
	TriggerEvent('esx_status:set', 'thirst', 1000000)

	-- restore hp
	local playerPed = PlayerPedId()
	SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
end)

AddEventHandler('esx:onPlayerDeath', function()
	IsDead = true
end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
	if IsDead then
		TriggerEvent('esx_basicneeds:resetStatus')
	end

	IsDead = false
end)

AddEventHandler('esx_status:loaded', function(status)

	TriggerEvent('esx_status:registerStatus', 'hunger', 1000000, '#CFAD0F', function(status)
		return Config.Visible
	end, function(status)
		status.remove(100)
	end)

	TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, '#0C98F1', function(status)
		return Config.Visible
	end, function(status)
		status.remove(75)
	end)

end)

AddEventHandler('esx_status:onTick', function(data)
	local playerPed  = PlayerPedId()
	local prevHealth = GetEntityHealth(playerPed)
	local health     = prevHealth
	
	for k, v in pairs(data) do
		if v.name == 'hunger' and v.percent == 0 then
			if prevHealth <= 150 then
				health = health - 5
			else
				health = health - 1
			end
		elseif v.name == 'thirst' and v.percent == 0 then
			if prevHealth <= 150 then
				health = health - 5
			else
				health = health - 1
			end
		end
	end
	
	if health ~= prevHealth then SetEntityHealth(playerPed, health) end
end)

AddEventHandler('esx_basicneeds:isEating', function(cb)
	cb(IsAnimated)
end)

RegisterNetEvent('esx_basicneeds:onEat')
AddEventHandler('esx_basicneeds:onEat', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_cs_burger_01'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict('mp_player_inteat@burger', function()
				TaskPlayAnim(playerPed, 'mp_player_inteat@burger', 'mp_player_int_eat_burger_fp', 8.0, -8, -1, 49, 0, 0, 0, 0)

				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

	end
end)

RegisterNetEvent('esx_basicneeds:onDrink')
AddEventHandler('esx_basicneeds:onDrink', function(prop_name)
	if not IsAnimated then
		prop_name = prop_name or 'prop_ld_flow_bottle'
		IsAnimated = true

		Citizen.CreateThread(function()
			local playerPed = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(playerPed))
			local prop = CreateObject(GetHashKey(prop_name), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(playerPed, 18905)
			AttachEntityToEntity(prop, playerPed, boneIndex, 0.12, 0.028, 0.001, 10.0, 175.0, 0.0, true, true, false, true, 1, true)

			ESX.Streaming.RequestAnimDict('mp_player_intdrink', function()
				TaskPlayAnim(playerPed, 'mp_player_intdrink', 'loop_bottle', 1.0, -1.0, 2000, 0, 1, true, true, true)

				Citizen.Wait(3000)
				IsAnimated = false
				ClearPedSecondaryTask(playerPed)
				DeleteObject(prop)
			end)
		end)

>>>>>>> esx_basicneeds/master
	end
end)
