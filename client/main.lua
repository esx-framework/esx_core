local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local isDead = false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

AddEventHandler('esx:onPlayerDeath', function()
	isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

function startAttitude(lib, anim)
	Citizen.CreateThread(function()
	
		local playerPed = GetPlayerPed(-1)
		RequestAnimSet(anim)
		
		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(1)
		end
		SetPedMovementClipset(playerPed, anim, true)
	end)
end

function startAnim(lib, anim)
	Citizen.CreateThread(function()
		RequestAnimDict(lib)
		while not HasAnimDictLoaded( lib) do
			Citizen.Wait(1)
		end

		TaskPlayAnim(GetPlayerPed(-1), lib ,anim ,8.0, -8.0, -1, 0, 0, false, false, false )
	end)
end

function startScenario(anim)
	TaskStartScenarioInPlace(GetPlayerPed(-1), anim, 0, false)
end

function OpenAnimationsMenu()
	local elements = {}

	for i=1, #Config.Animations, 1 do
		table.insert(elements, {label = Config.Animations[i].label, value = Config.Animations[i].name})
	end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'animations',
		{
			title    = 'Animations',
			align    = 'top-left',
			elements = elements
		},
		function(data, menu)
			OpenAnimationsSubMenu(data.current.value)
		end,
		function(data, menu)
			menu.close()
		end
	)
end

function OpenAnimationsSubMenu(menu)
	local title    = nil
	local elements = {}

	for i=1, #Config.Animations, 1 do
	
		if Config.Animations[i].name == menu then
			title = Config.Animations[i].label

			for j=1, # Config.Animations[i].items, 1 do
				table.insert(elements, {label = Config.Animations[i].items[j].label, type = Config.Animations[i].items[j].type, value = Config.Animations[i].items[j].data})
			end

			break

		end

	end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'animations_sub',
		{
			title    = title,
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local type = data.current.type
			local lib  = data.current.value.lib
			local anim = data.current.value.anim

			if type == 'scenario' then
				startScenario(anim)
			else
				if type == 'attitude' then
					startAttitude(lib, anim)
				else
					startAnim(lib, anim)
				end
			end

		end, function(data, menu)
			menu.close()
		end
	)

end

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if IsControlJustReleased(0, Keys['F3']) and GetLastInputMethod(2) and not isDead then
			OpenAnimationsMenu()
		end

		if IsControlJustReleased(0, Keys['X']) and GetLastInputMethod(2) and not isDead then
			ClearPedTasks(GetPlayerPed(-1))
		end

	end
end)