local Status, isPaused = {}, false

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
	ESX.PlayerLoaded = false
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
	ESX.PlayerLoaded = true
	TriggerEvent('esx_status:loaded')
	for i=1, #Status, 1 do
		for j=1, #status, 1 do
			if Status[i].name == status[j].name then
				Status[i].set(status[j].val)
			end
		end
	end

	if Config.Display then TriggerEvent('esx_status:setDisplay', 0.5) end

	CreateThread(function()
		local data = {}
		while ESX.PlayerLoaded do
			for i=1, #Status do
				Status[i].onTick()
				table.insert(data, {
					name = Status[i].name,
					val = Status[i].val,
					percent = (Status[i].val / 1000000) * 100
				})
			end

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
			table.wipe(data)
			Wait(Config.TickTime)
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
if Config.Display then
	CreateThread(function()
		while true do
			Wait(300)

			if IsPauseMenuActive() and not isPaused then
				isPaused = true
				TriggerEvent('esx_status:setDisplay', 0.0)
			elseif not IsPauseMenuActive() and isPaused then
				isPaused = false 
				TriggerEvent('esx_status:setDisplay', 0.5)
			end
		end
	end)
end

-- Loading screen off event
AddEventHandler('esx:loadingScreenOff', function()
	if not isPaused then
		TriggerEvent('esx_status:setDisplay', 0.3)
	end
end)

-- Update server
CreateThread(function()
	while true do
		Wait(Config.UpdateInterval)
		if ESX.PlayerLoaded then TriggerServerEvent('esx_status:update', GetStatusData(true)) end
	end
end)
