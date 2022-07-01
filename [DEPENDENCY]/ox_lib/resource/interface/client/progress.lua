local progress
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local playerState = LocalPlayer.state

local function createProp(prop)
	lib.requestModel(prop.model)
	local coords = GetEntityCoords(cache.ped)
	local object = CreateObject(prop.model, coords.x, coords.y, coords.z, true, true, true)
	AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, 0, true)
	return object
end

local function startProgress(data)
	playerState.invBusy = true
	progress = data

	if data.anim then
		if data.anim.dict then
			lib.requestAnimDict(data.anim.dict)
			TaskPlayAnim(cache.ped, data.anim.dict, data.anim.clip, data.anim.blendIn or 3.0, data.anim.blendOut or 1.0, data.anim.duration or -1, data.anim.flag or 49, data.anim.playbackRate or 0, data.anim.lockX, data.anim.lockY, data.anim.lockZ)
			data.anim = true
		elseif data.anim.scenario then
			TaskStartScenarioInPlace(cache.ped, data.anim.scenario, 0, data.anim.playEnter ~= nil and data.anim.playEnter or true)
			data.anim = true
		end
	end

	if data.prop then
		if data.prop.model then
			data.prop1 = createProp(data.prop)
		else
			for i = 1, #data.prop do
				local prop = data.prop[i]

				if prop then
					data['prop'..i] = createProp(prop)
				end
			end
		end
	end

	if data.disable then
		while progress do
			if data.disable.mouse then
				DisableControlAction(0, 1, true)
				DisableControlAction(0, 2, true)
				DisableControlAction(0, 106, true)
			end

			if data.disable.move then
				DisableControlAction(0, 21, true)
				DisableControlAction(0, 30, true)
				DisableControlAction(0, 31, true)
				DisableControlAction(0, 36, true)
			end

			if data.disable.car then
				DisableControlAction(0, 63, true)
				DisableControlAction(0, 64, true)
				DisableControlAction(0, 71, true)
				DisableControlAction(0, 72, true)
				DisableControlAction(0, 75, true)
			end

			if data.disable.combat then
				DisableControlAction(0, 25, true)
				DisablePlayerFiring(cache.playerId, true)
			end

			Wait(0)
		end
	elseif data.canCancel then
		while progress do Wait(0) end
	else
		Wait(data.duration)
	end

	if data.anim then
		ClearPedTasks(cache.ped)
	end

	if data.prop then
		local n = #data.prop
		for i = 1, n > 0 and n or 1 do
			local prop = data['prop'..i]

			if prop then
				DetachEntity(prop)
				DeleteEntity(prop)
			end
		end
	end

	playerState.invBusy = false
	local cancel = progress == false
	progress = nil

	if cancel then
		SendNUIMessage({ action = 'progressCancel' })
		return false
	end

	return true
end

function lib.progressBar(data)
	while progress ~= nil do Wait(100) end

	if data.useWhileDead or not IsEntityDead(cache.ped) then
		SendNUIMessage({
			action = 'progress',
			data = {
				label = data.label,
				duration = data.duration
			}
		})

		return startProgress(data)
	end
end

function lib.progressCircle(data)
	while progress ~= nil do Wait(100) end

	if data.useWhileDead or not IsEntityDead(cache.ped) then
		SendNUIMessage({
			action = 'circleProgress',
			data = {
				duration = data.duration,
				position = data.position,
				label = data.label
			}
		})

		return startProgress(data)
	end
end

function lib.cancelProgress()
	if not progress then
		error('No progress bar is active')
	elseif not progress.canCancel then
		error(("Progress bar '%s' cannot be cancelled"):format(id))
	end

	progress = false
end

function lib.progressActive()
	return progress and true
end

RegisterNUICallback('progressComplete', function(data, cb)
	cb(1)
	progress = nil
end)

RegisterCommand('cancelprogress', function()
	if progress?.canCancel then progress = false end
end)

RegisterKeyMapping('cancelprogress', 'Cancel current progress bar', 'keyboard', 'x')
