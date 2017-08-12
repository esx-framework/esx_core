local Status = {}
local loaded = false

RegisterNetEvent('esx_status:update')
AddEventHandler('esx_status:update', function(status)
	
	Status = status

	SendNUIMessage({
		update = true,
		status = Status
	})

	if not loaded then
		TriggerEvent('esx_status:loaded')
		loaded = true
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

-- Calculate status
Citizen.CreateThread(function()
  while true do

  	for i=1, #Status, 1 do

  		if Status[i].clientAction.add ~= nil then

  			local val = Status[i].clientAction.add

				if Status[i].val + val > Config.StatusMax then
					Status[i].val = StatusMax
				else
					Status[i].val = Status[i].val + val
				end

  		end

  		if Status[i].clientAction.remove ~= nil then
				
  			local val = Status[i].clientAction.remove

				if Status[i].val - val < 0 then
					Status[i].val = 0
				else
					Status[i].val = Status[i].val - val
				end

  		end

  	end

		SendNUIMessage({
			update = true,
			status = Status
		})

    Citizen.Wait(Config.TickTime)

  end
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