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

ESX = nil
local ped = GetPlayerPed(-1)
local sitting = false
local lastPos = nil
local currentSitObj = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


function headsUp(text)
	SetTextComponentFormat('STRING')
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


Citizen.CreateThread(function()
	local objects = {}
	for k,v in pairs(Config.Sitable) do
		table.insert(objects, v.prop)
	end
	while true do
		Wait(0)
		--local object, distance = ESX.Game.GetClosestObject(objects)
		local list = {}
		for k,v in pairs(objects) do
			local obj = GetClosestObjectOfType(GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z, 3.0, GetHashKey(v), false, true ,true)
			local dist = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(obj), true)
			table.insert(list, {object = obj, distance = dist})
		end

		local closest = list[1]
		for k,v in pairs(list) do
			if v.distance < closest.distance then
				closest = v
			end
		end

		local distance = closest.distance
		local object = closest.object

		if distance < Config.MaxDistance and sitting == false and DoesEntityExist(object) then
			headsUp('You are near an object you can sit on! Press ~INPUT_CONTEXT~ to sit!')
			DrawMarker(0, GetEntityCoords(object).x, GetEntityCoords(object).y, GetEntityCoords(object).z+1.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 100, false, true, 2, false, false, false, false)
			if IsControlJustPressed(0, Keys['E']) then
				sit(object)
			end
		end
		if sitting then
			headsUp('Press ~INPUT_VEH_DUCK~ get up.')
			if IsControlJustPressed(0, Keys['X']) then
				ClearPedTasks(ped)
				sitting = false
				SetEntityCoords(ped, lastPos)
				FreezeEntityPosition(ped, false)
				FreezeEntityPosition(currentSitObj, false)
				TriggerServerEvent('sit:unoccupyObj', currentSitObj)
				currentSitObj = nil
			end
		end
	end
end)



function sit(object)
	local isOccupied = nil
	ESX.TriggerServerCallback('sit:getOccupied', function(occupied)
		isOccupied = false
		for k,v in pairs(occupied) do
			if v == object then
				isOccupied = true
			end
		end
	end)
	while isOccupied == nil do
		Wait(0)
	end
	if isOccupied == false then
		lastPos = GetEntityCoords(ped)
		currentSitObj = object
		TriggerServerEvent('sit:occupyObj', object)
		FreezeEntityPosition(object, true)
		local objinfo = {}
		for k,v in pairs(Config.Sitable) do
			if tostring(GetHashKey(v.prop)) == tostring(GetEntityModel(object)) then
				objinfo = v
			end
		end
		local objloc = GetEntityCoords(object)
		SetEntityCoords(ped, objloc.x, objloc.y, objloc.z+objinfo.verticalOffset)
		SetEntityHeading(ped, GetEntityHeading(object)+180.0)
		FreezeEntityPosition(ped, true)
		sitting = true
		TaskStartScenarioInPlace(ped, objinfo.scenario, 0, true)
	end
end