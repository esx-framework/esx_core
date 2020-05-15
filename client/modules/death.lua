AddEventHandler('baseevents:onPlayerDied', function(killerType, deathCoords)

  local playerPed = PlayerPedId()

	local data = {
		killed      = false,
		killerType  = killerType,
		deathCoords = deathCoords,
		deathCause  = GetPedCauseOfDeath(playerPed)
	}

	TriggerEvent('esx:onPlayerDeath', data)
  TriggerServerEvent('esx:onPlayerDeath', data)

end)

AddEventHandler('baseevents:onPlayerKilled', function(killerId, data)
	local playerPed = PlayerPedId()
	local killer    = GetPlayerFromServerId(killerId)

	if NetworkIsPlayerActive(killer) then

    local victimCoords = data.killerpos
		local weaponHash   = data.weaponhash

		data.killerpos  = nil
		data.weaponhash = nil

		local killerPed    = GetPlayerPed(killer)
		local killerCoords = GetEntityCoords(killerPed)
		local distance     = GetDistanceBetweenCoords(victimCoords[1], victimCoords[2], victimCoords[3], killerCoords, false)

    data.victimCoords = victimCoords
    data.weaponHash   = weaponHash
    data.deathCause   = GetPedCauseOfDeath(playerPed)
    data.killed       = true
    data.killerId     = killerId
    data.killerCoords = {x = killerCoords.x, y = killerCoords.y, z = killerCoords.z}
    data.distance     = distance

  else

    data.killed     = false
    data.deathCause = GetPedCauseOfDeath(playerPed)

	end

	TriggerEvent('esx:onPlayerDeath', data)
  TriggerServerEvent('esx:onPlayerDeath', data)

end)
