local inAnim = false

function startAttitude(lib, anim)
	ESX.Streaming.RequestAnimSet(lib, function()
		SetPedMovementClipset(PlayerPedId(), anim, true)
	end)
end

function startAnim(lib, anim)
	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
	end)
end

function startScenario(anim)
	TaskStartScenarioInPlace(PlayerPedId(), anim, 0, false)
end

function OpenAnimationsMenu()
	local elements = {}

	for i=1, #Config.Animations, 1 do
		table.insert(elements, {label = Config.Animations[i].label, value = Config.Animations[i].name})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations', {
		title    = 'Animations',
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		OpenAnimationsSubMenu(data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

function OpenAnimationsSubMenu(menu)
	local title    = nil
	local elements = {}

	for i=1, #Config.Animations, 1 do
		if Config.Animations[i].name == menu then
			title = Config.Animations[i].label

			for j=1, #Config.Animations[i].items, 1 do
				table.insert(elements, {
					label = Config.Animations[i].items[j].label,
					type  = Config.Animations[i].items[j].type,
					value = Config.Animations[i].items[j].data
				})
			end

			break

		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'animations_sub', {
		title    = title,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		local type = data.current.type
		local lib  = data.current.value.lib
		local anim = data.current.value.anim

		if type == 'scenario' then
			startScenario(anim)
		elseif type == 'attitude' then
			startAttitude(lib, anim)
		elseif type == 'anim' then
			startAnim(lib, anim)
		end
	end, function(data, menu)
		menu.close()
	end)
end

-- Key Controls
RegisterCommand('animmenu', function()
	if not ESX.PlayerData.dead then
		OpenAnimationsMenu()
	end
end, false)

RegisterCommand('cleartasks', function()
	if not ESX.PlayerData.dead then
	ClearPedTasks(PlayerPedId())
	end
end, false)

RegisterKeyMapping('animmenu', 'Open Animations Menu', 'keyboard', 'f3')
RegisterKeyMapping('cleartasks', 'Stop Anmimation', 'keyboard', 'z')
