Citizen.CreateThread(function()
	local isDead = false

	while true do
		Citizen.Wait(0)

		local player = PlayerId()

		if NetworkIsPlayerActive(player) then
			local playerPed = PlayerPedId()

			if IsPedFatallyInjured(playerPed) and not isDead then
				isDead = true

				local killer, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
				local killerServerId = NetworkGetPlayerIndexFromPed(killer)
		
				if killer ~= playerPed and killerServerId ~= nil and NetworkIsPlayerActive(killerServerId) then
					PlayerKilledByPlayer(GetPlayerServerId(killerServerId), killerServerId, killerWeapon)
				else
					PlayerKilled()
				end

			elseif not IsPedFatallyInjured(playerPed) then
				isDead = false
			end
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, killerWeapon)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance     = GetDistanceBetweenCoords(victimCoords, killerCoords, true)

	local data = {
		victimCoords = victimCoords,
		killerCoords = killerCoords,

		killedByPlayer = true,
		deathCause     = killerWeapon,
		distance       = ESX.Math.Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end

function PlayerKilled()
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(PlayerPedId())

	local data = {
		victimCoords = victimCoords,

		killedByPlayer = false,
		deathCause     = GetPedCauseOfDeath(playerPed)
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end