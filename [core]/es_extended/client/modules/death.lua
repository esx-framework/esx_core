local basicneeds_state = GetResourceState('esx_basicneeds'):find('start')
local esx_basicneeds = basicneeds_state == 1 and true or false

local deadAnims = {
	onFoot = {
		dict = 'combat@damage@writhe',
		anim = 'writhe_loop'
	},
	inVehicle = {
		dict = 'veh@low@front_ps@idle_duck',
		anim = 'sit'
	},
	onAttach = {
		dict = 'combat@damage@writhe',
		anim = 'writhe_loop'
	}
}

local ANIM = {
	current = {
		dict = nil,
		anim = nil
	}
}

CreateThread(function ()
	for index, data in pairs(deadAnims) do
		ESX.Streaming.RequestAnimDict(data.dict)
	end
end)

local function SetDeadState(state)
	local playerPed = PlayerPedId()
	ESX.SetPlayerData('ped', playerPed)
	ESX.SetPlayerData('dead', state)

	SetEntityInvincible(ESX.PlayerData.ped, state)
	SetEntityMaxHealth(ESX.PlayerData.ped, 200)
	SetEntityHealth(ESX.PlayerData.ped, 200)
	SetEveryoneIgnorePlayer(PlayerId(), state)
end

local function attachCheck()
	local attached = GetEntityAttachedTo(ESX.PlayerData.ped)
	return attached ~= 0 and true or false
end

local function OnPlayerDeath(data)
	SetDeadState(true)

	if esx_basicneeds then
		TriggerEvent('esx_basicneeds:resetStatus')
	end

	if Config.OxInventory then
		TriggerEvent('ox_inventory:disarm')
	end

	while GetEntitySpeed(ESX.PlayerData.ped) > 0.5 or IsPedRagdoll(ESX.PlayerData.ped) do
		Wait(100)
	end

	local coords = GetEntityCoords(ESX.PlayerData.ped)
	local heading = GetEntityHeading(ESX.PlayerData.ped)
	local inVehicle = ESX.GetPlayerStateBag('inVehicle')

	if inVehicle then
		local vehicle = NetToVeh(inVehicle)

		local tries = 0
		while not vehicle and tries < 100 do
			vehicle = NetToVeh(inVehicle)
			tries += 1
			Wait(100)
		end

		if not vehicle then
			NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z + 0.5, heading, true, false)
			return
		end

		local model = GetEntityModel(vehicle)
		local vehseats = GetVehicleModelNumberOfSeats(GetHashKey(tostring(model)))
		for i = -1, vehseats do
			local occupant = GetPedInVehicleSeat(vehicle, i)
			if occupant == ESX.PlayerData.ped then
				NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z + 0.5, heading, true, false)
				SetPedIntoVehicle(ESX.PlayerData.ped, vehicle, i)
			end
		end
	else
		NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z + 0.5, heading, true, false)
	end

	ANIM:checkerThread()

	TriggerEvent('esx:onPlayerDeath', data)
	TriggerServerEvent('esx:onPlayerDeath', data)
end

local function OnPlayerRevive()
	SetDeadState(false)
	ClearPedBloodDamage(ESX.PlayerData.ped)

	ANIM:stop()

	TriggerEvent('esx:onPlayerRevive')
	TriggerServerEvent('esx:onPlayerRevive')
end

function ANIM:play(type)
	if self:playing() then
		self:stop()
	end

	if not type then type = ESX.GetPlayerStateBag('inVehicle') and 'inVehicle' or 'onFoot' end

	self.current.dict = deadAnims[type].dict
	self.current.anim = deadAnims[type].anim
	TaskPlayAnim(ESX.PlayerData.ped, self.current.dict, self.current.anim, 2.0, 2.0, -1, 1, 0, false, false, false)
end

function ANIM:stop()
	if not self:playing() then return end
	StopAnimTask(ESX.PlayerData.ped, self.current.dict, self.current.anim, 2.0)
	self:reset()
end

function ANIM:reset()
	self.current = {
		dict = nil,
		anim = nil
	}
end

function ANIM:playing()
	if IsEntityPlayingAnim(ESX.PlayerData.ped, self.current.dict, self.current.anim, 3) == 1 then
		return true
	end

	return false
end

function ANIM:checkerThread()
	local carried = false
	CreateThread(function ()
		while ESX.PlayerData.dead do
			-- Check if he carried, if is then change anim
			local tempCarried = attachCheck()

			if carried ~= tempCarried then
				carried = tempCarried
				if carried then
					self:play('onAttach')
				else
					self:play()
				end
			end

			--Check if playing anim, if not then we set the anim
			if not self:playing() then
				if carried then
					self:play('onAttach')
				else
					self:play()
				end
			end

			Wait(200)
		end
	end)
end

AddEventHandler('gameEventTriggered', function(event, data)
	if event ~= 'CEventNetworkEntityDamage' then return end
	local victim, victimDied = data[1], data[4]
	if not IsPedAPlayer(victim) then return end
	local player = PlayerId()
	local playerPed = PlayerPedId()
	if victimDied and NetworkGetPlayerIndexFromPed(victim) == player and
		(IsPedDeadOrDying(victim, true) or IsPedFatallyInjured(victim)) then
		local killerEntity, deathCause = GetPedSourceOfDeath(playerPed), GetPedCauseOfDeath(playerPed)
		local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
		if killerEntity ~= playerPed and killerClientId and NetworkIsPlayerActive(killerClientId) then
			PlayerKilledByPlayer(GetPlayerServerId(killerClientId), killerClientId, deathCause)
		else
			PlayerKilled(deathCause)
		end
	end
end)

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
	local victimCoords = GetEntityCoords(PlayerPedId())
	local killerCoords = GetEntityCoords(GetPlayerPed(killerClientId))
	local distance = #(victimCoords - killerCoords)

	local data = {
		victimCoords = { x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1),
			z = ESX.Math.Round(victimCoords.z, 1) },
		killerCoords = { x = ESX.Math.Round(killerCoords.x, 1), y = ESX.Math.Round(killerCoords.y, 1),
			z = ESX.Math.Round(killerCoords.z, 1) },

		killedByPlayer = true,
		deathCause = deathCause,
		distance = ESX.Math.Round(distance, 1),

		killerServerId = killerServerId,
		killerClientId = killerClientId
	}

	OnPlayerDeath(data)
end

function PlayerKilled(deathCause)
	local playerPed = PlayerPedId()
	local victimCoords = GetEntityCoords(playerPed)

	local data = {
		victimCoords = { x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1),
			z = ESX.Math.Round(victimCoords.z, 1) },

		killedByPlayer = false,
		deathCause = deathCause
	}

	OnPlayerDeath(data)
end

RegisterNetEvent('esx:revivePlayer', OnPlayerRevive)