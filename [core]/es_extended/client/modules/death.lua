local IsPedAPlayer = IsPedAPlayer
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local IsPedDeadOrDying = IsPedDeadOrDying
local IsPedFatallyInjured = IsPedFatallyInjured
local GetPedSourceOfDeath = GetPedSourceOfDeath
local GetPedCauseOfDeath = GetPedCauseOfDeath
local NetworkIsPlayerActive = NetworkIsPlayerActive
local GetPlayerServerId = GetPlayerServerId
local GetEntityCoords = GetEntityCoords
local GetPlayerPed = GetPlayerPed
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent

AddEventHandler('gameEventTriggered', function(event, data)
	if event ~= 'CEventNetworkEntityDamage' then return end

	local victim, victimDied = data[1], data[4]
	if not IsPedAPlayer(victim) then
		return
	end

	if victimDied and NetworkGetPlayerIndexFromPed(victim) == ESX.PlayerData.player and
	(IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim) or ESX.PlayerData.dead) then
		local killerEntity, deathCause = GetPedSourceOfDeath(ESX.PlayerData.ped), GetPedCauseOfDeath(ESX.PlayerData.ped)
		local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)

		if killerEntity ~= ESX.PlayerData.ped and killerClientId and NetworkIsPlayerActive(killerClientId) then
			PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
		else
			PlayerKilled(deathCause)
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
	local victimCoords = GetEntityCoords(ESX.PlayerData.ped)
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = {
			x = ESX.Math.Round(victimCoords.x, 3),
			y = ESX.Math.Round(victimCoords.y, 3),
			z = ESX.Math.Round(victimCoords.z, 3)
		},

		killerCoords = {
			x = ESX.Math.Round(killerCoords.x, 3),
			y = ESX.Math.Round(killerCoords.y, 3),
			z = ESX.Math.Round(killerCoords.z, 3)
		},

		killedByPlayer = true,
		deathCause = deathCause,
		distance = ESX.Math.Round(distance, 3),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end

function PlayerKilled(deathCause)
	local victimCoords = GetEntityCoords(ESX.PlayerData.ped)

	local data = {
		victimCoords = {
			x = ESX.Math.Round(victimCoords.x, 3),
			y = ESX.Math.Round(victimCoords.y, 3),
			z = ESX.Math.Round(victimCoords.z, 3)
		},

		killedByPlayer = false,
		deathCause = deathCause
	}

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end
