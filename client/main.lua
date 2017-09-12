local Status = {}

function GetStatusData(minimal)

	local status = {}

	for i=1, #Status, 1 do

		if minimal then

			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				percent = (Status[i].val / Config.StatusMax) * 100,
			})

		else

			table.insert(status, {
				name    = Status[i].name,
				val     = Status[i].val,
				color   = Status[i].color,
				visible = Status[i].visible(Status[i]),
				max     = Status[i].max,
				percent = (Status[i].val / Config.StatusMax) * 100,
			})

		end

	end

	return status

end

AddEventHandler('esx_status:registerStatus', function(name, default, color, visible, tickCallback)
	local s = CreateStatus(name, default, color, visible, tickCallback)
	table.insert(Status, s)
end)

RegisterNetEvent('esx_status:load')
AddEventHandler('esx_status:load', function(status)

	for i=1, #Status, 1 do
		for j=1, #status, 1 do
			if Status[i].name == status[j].name then
				Status[i].set(status[j].val)
			end
		end
	end

	Citizen.CreateThread(function()
	  while true do

	  	for i=1, #Status, 1 do
	  		Status[i].onTick()
	  	end

			SendNUIMessage({
				update = true,
				status = GetStatusData()
			})

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

	SendNUIMessage({
		update = true,
		status = GetStatusData()
	})

	TriggerServerEvent('esx_status:update', GetStatusData(true))

end)

RegisterNetEvent('esx_status:add')
AddEventHandler('esx_status:add', function(name, val)
	
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].add(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = GetStatusData()
	})

	TriggerServerEvent('esx_status:update', GetStatusData(true))

end)

RegisterNetEvent('esx_status:remove')
AddEventHandler('esx_status:remove', function(name, val)
	
	for i=1, #Status, 1 do
		if Status[i].name == name then
			Status[i].remove(val)
			break
		end
	end

	SendNUIMessage({
		update = true,
		status = GetStatusData()
	})

	TriggerServerEvent('esx_status:update', GetStatusData(true))

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
local isPaused = false

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    if IsPauseMenuActive() and not isPaused then
      isPaused = true
     	TriggerEvent('esx_status:setDisplay', 0.0)
    elseif not IsPauseMenuActive() and isPaused then
      isPaused = false 
     	TriggerEvent('esx_status:setDisplay', 0.5)
    end
  end
end)

-- Loaded event
Citizen.CreateThread(function()
	TriggerEvent('esx_status:loaded')
end)

-- Update server
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(Config.UpdateInterval)
		TriggerServerEvent('esx_status:update', GetStatusData(true))
	end
end)