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

local sitting = false
local lastPos = nil
local currentSitObj = nil
local currentScenario = nil

local debugProps = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function DrawText3D(x,y,z, text, r,v,b)
    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r, v, b, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if #debugProps > 0 then
			for i=1, #debugProps, 1 do
				local coords = GetEntityCoords(debugProps[i])
				local hash = GetEntityModel(debugProps[i])
				local id = coords.x .. coords.y .. coords.z
				local model = "unknown"
				
				for i=1, #Config.Interactables, 1 do
					local seat = Config.Interactables[i]
					if hash == GetHashKey(seat) then
						model = seat
						break
					end
				end

				local txt = "ID: " .. id .. "\nHASH: " .. hash .. '\nMODEL: ' .. 
				DrawText3D(coords.x, coords.y, coords.z + 2.0, txt, 0, 255, 255)
			end
		end

		local playerPed = GetPlayerPed(-1)

		if sitting and not IsPedUsingScenario(playerPed, currentScenario) then
			wakeup()
		end

		if (GetLastInputMethod(2) and IsControlJustPressed(1, 38) and IsControlPressed(1, 21)) and not IsPedInAnyVehicle(playerPed, true) then			

			if sitting then
				wakeup()
			else

				local object, distance = ESX.Game.GetClosestObject(Config.Interactables)

				if Config.debug then
					table.insert(debugProps, object)
				end

				if distance < 1.5 then

					local hash = GetEntityModel(object)
					local data = nil
					local modelName = nil
					local found = false

					for k,v in pairs(Config.Sitable) do
						if GetHashKey(k) == hash then
							data = v
							modelName = k
							found = true
							break
						end
					end

					if found == true then
						sit(object, modelName, data)
					end

				end

			end
			
		end

	end
end)

function wakeup()
	local playerPed = GetPlayerPed(-1)
	ClearPedTasks(playerPed)
	sitting = false
	SetEntityCoords(playerPed, lastPos)
	FreezeEntityPosition(playerPed, false)
	FreezeEntityPosition(currentSitObj, false)
	TriggerServerEvent('esx_interact:leavePlace', currentSitObj)
	currentSitObj = nil
	currentScenario = nil
end

function sit(object, modelName, data)

	local pos = GetEntityCoords(object)
	local id = pos.x .. pos.y .. pos.z

	ESX.TriggerServerCallback('esx_interact:getPlace', function(occupied)

		if occupied then
			ESX.ShowNotification("Cette place est prise...")
		else
			local playerPed = GetPlayerPed(-1)
			lastPos = GetEntityCoords(playerPed)
			currentSitObj = id

			TriggerServerEvent('esx_interact:takePlace', id)
			FreezeEntityPosition(object, true)

			currentScenario = data.scenario

			TaskStartScenarioAtPosition(playerPed, currentScenario, pos.x, pos.y, pos.z - data.verticalOffset, GetEntityHeading(object)+180.0, 0, true, true)

			sitting = true
		
		end

	end)

end
