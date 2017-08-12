ESX          = nil
local IsDead = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('playerSpawned', function()

	if IsDead then
		TriggerServerEvent('esx_basicneeds:resetStatus')
	end

	IsDead = false
end)

AddEventHandler('esx_status:loaded', function(status)

	Citizen.CreateThread(function()

		while true do

			Wait(1000)

			local playerPed  = GetPlayerPed(-1)
			local prevHealth = GetEntityHealth(playerPed)
			local health     = prevHealth

			TriggerEvent('esx_status:getStatus', 'hunger', function(status)
				
				if status.val == 0 then

					if prevHealth <= 150 then
						health = health - 5
					else
						health = health - 1
					end

				end

			end)

			TriggerEvent('esx_status:getStatus', 'thirst', function(status)
				
				if status.val == 0 then

					if prevHealth <= 150 then
						health = health - 5
					else
						health = health - 1
					end

				end

			end)

			if health ~= prevHealth then
				SetEntityHealth(playerPed,  health)
			end

		end

	end)

	Citizen.CreateThread(function()

		while true do

			Wait(0)

			local playerPed = GetPlayerPed(-1)
			
			if IsEntityDead(playerPed) and not IsDead then
				IsDead = true
			end

		end

	end)

end)

RegisterNetEvent('esx_basicneeds:onEat')
AddEventHandler('esx_basicneeds:onEat', function()
  
  local pid = PlayerPedId()
  
  RequestAnimDict("mp_player_inteat@burger")
  
  while not HasAnimDictLoaded("mp_player_inteat@burger") do
  	Wait(0)
  end

  TaskPlayAnim(pid, 'mp_player_inteat@burger', 'mp_player_int_eat_burger', 1.0, -1.0, 2000, 0, 1, true, true, true)
end)

RegisterNetEvent('esx_basicneeds:onDrink')
AddEventHandler('esx_basicneeds:onDrink', function()

  local pid = PlayerPedId()
  
  RequestAnimDict("amb@world_human_drinking@coffee@male@idle_a")
  
  while not HasAnimDictLoaded("amb@world_human_drinking@coffee@male@idle_a") do
  	Wait(0)
  end

  TaskPlayAnim(pid, 'amb@world_human_drinking@coffee@male@idle_a', 'idle_a', 1.0, -1.0, 2000, 0, 1, true, true, true)

end)
