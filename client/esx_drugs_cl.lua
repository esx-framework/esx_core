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

local PID           			= 0
local GUI           			= {}
local cokeQTE       			= 0
ESX 			    			= nil
GUI.Time            			= 0
local coke_poochQTE 			= 0
local weedQTE					= 0
local weed_poochQTE 			= 0
local methQTE					= 0
local meth_poochQTE 			= 0
local opiumQTE					= 0
local opium_poochQTE 			= 0
local myJob 					= nil
local PlayerData 				= {}
local GUI 						= {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

AddEventHandler('esx_drugs:hasEnteredMarker', function(zone)

        ESX.UI.Menu.CloseAll()

        --coke
        if zone == 'CokeFarm' then
            if myJob ~= "police" then
                CurrentAction     = 'coke_harvest'
                CurrentActionMsg  = _U('press_collect_coke')
                CurrentActionData = {}
            end
        end

        if zone == 'CokeTreatment' then
            if myJob ~= "police" then
                if cokeQTE >= 5 then
                    CurrentAction     = 'coke_treatment'
                    CurrentActionMsg  = _U('press_process_coke')
                    CurrentActionData = {}
                end
            end
        end

        if zone == 'CokeResell' then
            if myJob ~= "police" then
                if coke_poochQTE >= 1 then
                    CurrentAction     = 'coke_resell'
                    CurrentActionMsg  = _U('press_sell_coke')
                    CurrentActionData = {}
                end
            end
        end

        --meth
        if zone == 'MethFarm' then
            if myJob ~= "police" then
                CurrentAction     = 'meth_harvest'
                CurrentActionMsg  = _U('press_collect_meth')
                CurrentActionData = {}
            end
        end

        if zone == 'MethTreatment' then
            if myJob ~= "police" then
                if methQTE >= 5 then
                    CurrentAction     = 'meth_treatment'
                    CurrentActionMsg  = _U('press_process_meth')
                    CurrentActionData = {}
                end
            end
        end

        if zone == 'MethResell' then
            if myJob ~= "police" then
                if meth_poochQTE >= 1 then
                    CurrentAction     = 'meth_resell'
                    CurrentActionMsg  = _U('press_sell_meth')
                    CurrentActionData = {}
                end
            end
        end

        --weed
        if zone == 'WeedFarm' then
            if myJob ~= "police" then
                CurrentAction     = 'weed_harvest'
                CurrentActionMsg  = _U('press_collect_weed')
                CurrentActionData = {}
            end
        end

        if zone == 'WeedTreatment' then
            if myJob ~= "police" then
                if weedQTE >= 5 then
                    CurrentAction     = 'weed_treatment'
                    CurrentActionMsg  = _U('press_process_weed')
                    CurrentActionData = {}
                end
            end
        end

        if zone == 'WeedResell' then
            if myJob ~= "police" then
                if weed_poochQTE >= 1 then
                    CurrentAction     = 'weed_resell'
                    CurrentActionMsg  = _U('press_sell_weed')
                    CurrentActionData = {}
                end
            end
        end

        --opium
        if zone == 'OpiumFarm' then
            if myJob ~= "police" then
                CurrentAction     = 'opium_harvest'
                CurrentActionMsg  = _U('press_collect_opium')
                CurrentActionData = {}
            end
        end

        if zone == 'OpiumTreatment' then
            if myJob ~= "police" then
                if opiumQTE >= 5 then
                    CurrentAction     = 'opium_treatment'
                    CurrentActionMsg  = _U('press_process_opium')
                    CurrentActionData = {}
                end
            end
        end

        if zone == 'OpiumResell' then
            if myJob ~= "police" then
                if opium_poochQTE >= 1 then
                    CurrentAction     = 'opium_resell'
                    CurrentActionMsg  = _U('press_sell_opium')
                    CurrentActionData = {}
                end
            end
        end
end)

AddEventHandler('esx_drugs:hasExitedMarker', function(zone)

        CurrentAction = nil
        ESX.UI.Menu.CloseAll()

        TriggerServerEvent('esx_drugs:stopHarvestCoke')
        TriggerServerEvent('esx_drugs:stopTransformCoke')
        TriggerServerEvent('esx_drugs:stopSellCoke')
        TriggerServerEvent('esx_drugs:stopHarvestMeth')
        TriggerServerEvent('esx_drugs:stopTransformMeth')
        TriggerServerEvent('esx_drugs:stopSellMeth')
        TriggerServerEvent('esx_drugs:stopHarvestWeed')
        TriggerServerEvent('esx_drugs:stopTransformWeed')
        TriggerServerEvent('esx_drugs:stopSellWeed')
        TriggerServerEvent('esx_drugs:stopHarvestOpium')
        TriggerServerEvent('esx_drugs:stopTransformOpium')
        TriggerServerEvent('esx_drugs:stopSellOpium')
end)

-- Weed Effect
RegisterNetEvent('esx_drugs:onPot')
AddEventHandler('esx_drugs:onPot', function()
    RequestAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
    while not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK") do
        Citizen.Wait(0)
    end
    TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_SMOKING_POT", 0, true)
    Citizen.Wait(5000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    ClearPedTasksImmediately(GetPlayerPed(-1))
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(GetPlayerPed(-1), true)
    SetPedMovementClipset(GetPlayerPed(-1), "MOVE_M@DRUNK@SLIGHTLYDRUNK", true)
    SetPedIsDrunk(GetPlayerPed(-1), true)
    DoScreenFadeIn(1000)
    Citizen.Wait(600000)
    DoScreenFadeOut(1000)
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(GetPlayerPed(-1), 0)
    SetPedIsDrunk(GetPlayerPed(-1), false)
    SetPedMotionBlur(GetPlayerPed(-1), false)
end)

-- Render markers
Citizen.CreateThread(function()
    while true do

        Wait(0)

        local coords = GetEntityCoords(GetPlayerPed(-1))

        for k,v in pairs(Config.Zones) do
            if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.DrawDistance) then
                DrawMarker(Config.MarkerType, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            end
        end

    end
end)

-- RETURN NUMBER OF ITEMS FROM SERVER
RegisterNetEvent('esx_drugs:ReturnInventory')
AddEventHandler('esx_drugs:ReturnInventory', function(cokeNbr, cokepNbr, methNbr, methpNbr, weedNbr, weedpNbr, opiumNbr, opiumpNbr, jobName, currentZone)
    cokeQTE       = cokeNbr
    coke_poochQTE = cokepNbr
    methQTE 	  = methNbr
    meth_poochQTE = methpNbr
    weedQTE 	  = weedNbr
    weed_poochQTE = weedpNbr
    opiumQTE       = opiumNbr
    opium_poochQTE = opiumpNbr
    myJob         = jobName
    TriggerEvent('esx_drugs:hasEnteredMarker', currentZone)
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
    while true do

        Wait(0)

        local coords      = GetEntityCoords(GetPlayerPed(-1))
        local isInMarker  = false
        local currentZone = nil

        for k,v in pairs(Config.Zones) do
            if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.ZoneSize.x / 2) then
                isInMarker  = true
                currentZone = k
            end
        end

        if isInMarker and not hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = true
            lastZone                = currentZone
            TriggerServerEvent('esx_drugs:GetUserInventory', currentZone)
        end

        if not isInMarker and hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = false
            TriggerEvent('esx_drugs:hasExitedMarker', lastZone)
        end

    end
end)

-- Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustReleased(0, 38) then
                if CurrentAction == 'coke_harvest' then
                    TriggerServerEvent('esx_drugs:startHarvestCoke')
                end
                if CurrentAction == 'coke_treatment' then
                    TriggerServerEvent('esx_drugs:startTransformCoke')
                end
                if CurrentAction == 'coke_resell' then
                    TriggerServerEvent('esx_drugs:startSellCoke')
                end
                if CurrentAction == 'meth_harvest' then
                    TriggerServerEvent('esx_drugs:startHarvestMeth')
                end
                if CurrentAction == 'meth_treatment' then
                    TriggerServerEvent('esx_drugs:startTransformMeth')
                end
                if CurrentAction == 'meth_resell' then
                    TriggerServerEvent('esx_drugs:startSellMeth')
                end
                if CurrentAction == 'weed_harvest' then
                    TriggerServerEvent('esx_drugs:startHarvestWeed')
                end
                if CurrentAction == 'weed_treatment' then
                    TriggerServerEvent('esx_drugs:startTransformWeed')
                end
                if CurrentAction == 'weed_resell' then
                    TriggerServerEvent('esx_drugs:startSellWeed')
                end
                if CurrentAction == 'opium_harvest' then
                    TriggerServerEvent('esx_drugs:startHarvestOpium')
                end
                if CurrentAction == 'opium_treatment' then
                    TriggerServerEvent('esx_drugs:startTransformOpium')
                end
                if CurrentAction == 'opium_resell' then
                    TriggerServerEvent('esx_drugs:startSellOpium')
                end
                CurrentAction = nil
            end
        end
    end
end)
