local CurrentAction, CurrentActionMsg, CurrentActionData, CurrentTest, CurrentTestType, CurrentVehicle = nil, nil, nil, nil, nil, nil
local CurrentBlip, CurrentZoneType, LastVehicleHealth= nil, nil, nil
local Licenses = {}
local CurrentCheckPoint, DriveErrors = 0, 0
local LastCheckPoint = -1
local IsAboveSpeedLimit = false

function DrawMissionText(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end

function StartTheoryTest()
	CurrentTest = 'theory'
    theoryTest()

	SendNUIMessage({
		openQuestion = true
	})

	ESX.SetTimeout(200, function()
		SetNuiFocus(true, true)
	end)


end

function StopTheoryTest(success)
	CurrentTest = nil

	SendNUIMessage({
		openQuestion = false
	})

	SetNuiFocus(false)

	if success then
		TriggerServerEvent('esx_dmvschool:addLicense', 'dmv')
		ESX.ShowNotification(_U('passed_test'))
	else
		ESX.ShowNotification(_U('failed_test'))
	end
end

function StartDriveTest(type)
	ESX.Game.SpawnVehicle(Config.VehicleModels[type], Config.Zones.VehicleSpawnPoint.Pos, Config.Zones.VehicleSpawnPoint.Pos.h, function(vehicle)
		CurrentTest       = 'drive'
		CurrentTestType   = type
		CurrentCheckPoint = 0
		LastCheckPoint    = -1
		CurrentZoneType   = 'residence'
		DriveErrors       = 0
		IsAboveSpeedLimit = false
		CurrentVehicle    = vehicle
		LastVehicleHealth = GetEntityHealth(vehicle)

		local playerPed   = PlayerPedId()
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleFuelLevel(vehicle, 100.0)
		DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	end)
    driveTest()
    speedDamageDriveTest()
end

function StopDriveTest(success)
	if success then
		TriggerServerEvent('esx_dmvschool:addLicense', CurrentTestType)
		ESX.ShowNotification(_U('passed_test'))
	else
		ESX.ShowNotification(_U('failed_test'))
	end

	CurrentTest     = nil
	CurrentTestType = nil
end

function SetCurrentZoneType(type)
CurrentZoneType = type
end

function OpenDMVSchoolMenu()
	local ownedLicenses = {}

	for i=1, #Licenses, 1 do
		ownedLicenses[Licenses[i].type] = true
	end

	local elements = {}

	if not ownedLicenses['dmv'] then
		table.insert(elements, {
			label = (('%s: <span style="color:green;">%s</span>'):format(_U('theory_test'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['dmv'])))),
			value = 'theory_test'
		})
	end

	if ownedLicenses['dmv'] then
		if not ownedLicenses['drive'] then
			table.insert(elements, {
				label = (('%s: <span style="color:green;">%s</span>'):format(_U('road_test_car'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive'])))),
				value = 'drive_test',
				type = 'drive'
			})
		end

		if not ownedLicenses['drive_bike'] then
			table.insert(elements, {
				label = (('%s: <span style="color:green;">%s</span>'):format(_U('road_test_bike'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive_bike'])))),
				value = 'drive_test',
				type = 'drive_bike'
			})
		end

		if not ownedLicenses['drive_truck'] then
			table.insert(elements, {
				label = (('%s: <span style="color:green;">%s</span>'):format(_U('road_test_truck'), _U('school_item', ESX.Math.GroupDigits(Config.Prices['drive_truck'])))),
				value = 'drive_test',
				type = 'drive_truck'
			})
		end
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dmvschool_actions', {
		title    = _U('driving_school'),
		elements = elements,
		align    = 'bottom-right'
	}, function(data, menu)
		if data.current.value == 'theory_test' then
			menu.close()
			ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
				if haveMoney then
					StartTheoryTest()
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end, 'dmv')
		elseif data.current.value == 'drive_test' then
			menu.close()
			ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
				if haveMoney then
					StartDriveTest(data.current.type)
				else
					ESX.ShowNotification(_U('not_enough_money'))
				end
			end, data.current.type)
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = _U('press_open_menu')
		CurrentActionData = {}
	end)
end

RegisterNUICallback('question', function(data, cb)
	SendNUIMessage({
		openSection = 'question'
	})

	cb()
end)

RegisterNUICallback('close', function(data, cb)
	StopTheoryTest(true)
	cb()
end)

RegisterNUICallback('kick', function(data, cb)
	StopTheoryTest(false)
	cb()
end)

AddEventHandler('esx_dmvschool:hasEnteredMarker', function(zone)
	if zone == 'DMVSchool' then
		CurrentAction     = 'dmvschool_menu'
		CurrentActionMsg  = _U('press_open_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_dmvschool:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

RegisterNetEvent('esx_dmvschool:loadLicenses')
AddEventHandler('esx_dmvschool:loadLicenses', function(licenses)
	Licenses = licenses
end)

-- Create Blips
CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos)

	SetBlipSprite (blip, 408)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.2)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('driving_school_blip'))
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
CreateThread(function()
	while true do
		sleep = 500

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
            local dist = #(coords - v.Pos)
			if(v.Type ~= -1 and dist < Config.DrawDistance) then sleep = 0
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end

        Wait(sleep)
	end
end)

-- Enter / Exit marker events
CreateThread(function()
	while true do
        sleep = 500

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if(#(coords - v.Pos) < v.Size.x) then = sleep = 1
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_dmvschool:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_dmvschool:hasExitedMarker', LastZone)
		end

        Wait(sleep)
	end
end)

-- Block UI
theoryTest = function()
    CreateThread(function()
        while CurrentTest == 'theory' do
            Wait(1)

            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisablePlayerFiring(playerPed, true) -- Disable weapon firing
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        end
    end)
end

-- Key Controls
CreateThread(function()
	while true do
		sleep = 500

		if CurrentAction then sleep = 1
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'dmvschool_menu' then
					OpenDMVSchoolMenu()
				end

				CurrentAction = nil
			end
		end

        Wait(sleep)
	end
end)

-- Drive test
driveTest = function()
    CreateThread(function()
        while CurrentTest == 'drive' do

            Wait(0)

            local playerPed      = PlayerPedId()
            local coords         = GetEntityCoords(playerPed)
            local nextCheckPoint = CurrentCheckPoint + 1

            if Config.CheckPoints[nextCheckPoint] == nil then
                if DoesBlipExist(CurrentBlip) then
                    RemoveBlip(CurrentBlip)
                end

                CurrentTest = nil

                ESX.ShowNotification(_U('driving_test_complete'))

                if DriveErrors < Config.MaxErrors then
                    StopDriveTest(true)
                else
                    StopDriveTest(false)
                end
            else

                if CurrentCheckPoint ~= LastCheckPoint then
                    if DoesBlipExist(CurrentBlip) then
                        RemoveBlip(CurrentBlip)
                    end

                    CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos)
                    SetBlipRoute(CurrentBlip, 1)

                    LastCheckPoint = CurrentCheckPoint
                end
            
                local distance = #(coords - Config.CheckPoints[nextCheckPoint].Pos)
            
                if distance <= 100.0 then
                    DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
                    if distance <= 3.0 then
                        Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
                        CurrentCheckPoint = CurrentCheckPoint + 1
                    end
                end

            end
        end
    end)
end

-- Speed / Damage control
speedDamageDriveTest = function()
    CreateThread(function()
        while CurrentTest == 'drive' do
            Wait(10)

            local playerPed = PlayerPedId()

            if IsPedInAnyVehicle(playerPed, false) then

                local vehicle      = GetVehiclePedIsIn(playerPed, false)
                local speed        = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
                local tooMuchSpeed = false

                for k,v in pairs(Config.SpeedLimits) do
                    if CurrentZoneType == k and speed > v then
                        tooMuchSpeed = true

                        if not IsAboveSpeedLimit then
                            DriveErrors       = DriveErrors + 1
                            IsAboveSpeedLimit = true

                            ESX.ShowNotification(_U('driving_too_fast', v))
                            ESX.ShowNotification(_U('errors', DriveErrors, Config.MaxErrors))
                        end
                    end
                end

                if not tooMuchSpeed then
                    IsAboveSpeedLimit = false
                end

                local health = GetEntityHealth(vehicle)
                if health < LastVehicleHealth then

                    DriveErrors = DriveErrors + 1

                    ESX.ShowNotification(_U('you_damaged_veh'))
                    ESX.ShowNotification(_U('errors', DriveErrors, Config.MaxErrors))

                    -- avoid stacking faults
                    LastVehicleHealth = health
                    Wait(1500)
                end
            end
        end
    end)
end
