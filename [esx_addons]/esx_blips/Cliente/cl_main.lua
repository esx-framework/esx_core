local coorz = {}
local blijp = {}
local serversql = {}
local blip = nil

AddEventHandler('esx:onPlayerSpawn', function()
    TriggerEvent('chat:addSuggestion', '/'..Config.OpenContext..'', ' Create Blip In Game (Admin Use Only)')
    TriggerEvent('chat:addSuggestion', '/'..Config.DeleteBlip..'', ' Delete Blip Created With ESX_BLIPS (Admin Use Only)')
    TriggerServerEvent("Esx_Blips:TO_Client", GetPlayerServerId(PlayerId()))
    ESX.TriggerServerCallback("esx:isUserAdmin", function(admin)
        if admin then
            AdminBool = true
        end
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerEvent('chat:removeSuggestion', '/'..Config.OpenContext..'')
        TriggerEvent('chat:removeSuggestion', '/'..Config.DeleteBlip..'')
        for k,v in pairs(blijp) do
            RemoveBlip(v)
        end
    end
end)

RegisterNetEvent("Esx_Blips:Sinc")
AddEventHandler("Esx_Blips:Sinc", function (bool)
	if bool then
        print("Devolucion: True")
        candelete = true
    else
        print("Devolucion: False")
        candelete = false
    end
end)

RegisterNetEvent("Esx_Blips:Load_Table")
AddEventHandler("Esx_Blips:Load_Table", function (coorz)
    serversql = coorz
    CreateBlip(coorz)
end)

RegisterNetEvent("Esx_Blips:Client:Removeblips")
AddEventHandler("Esx_Blips:Client:Removeblips", function ()
    for k,v in pairs(blijp) do
        RemoveBlip(v)
    end
end)

RegisterNetEvent("Esx_Blips:MenuBlip")
AddEventHandler("Esx_Blips:MenuBlip", function (source)

    if AdminBool then
        MenuBlip()
    end
end)

---------------------------------
-- shiti way to delete for now --
---------------------------------

Citizen.CreateThread(function()
    local id = GetPlayerServerId(PlayerId())
    while true do
        sleep = 600
        if candelete then
            sleep = 0
            for k,v in pairs(serversql) do
                local playerPos = GetEntityCoords(PlayerPedId(), true)
                local coordz = vector3(v.Coords.x, v.Coords.y, v.Coords.z)
                if GetDistanceBetweenCoords(playerPos, coordz, true)  < 20.0 then
                    DrawMarker(20, coordz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.75, 0.75, -0.75, 204, 204, 0, 100, false, true, 2, false, false, false, false)
                    if GetDistanceBetweenCoords(playerPos, coordz, true)  <= 0.75 then
                        SetTextComponentFormat('STRING')
                        AddTextComponentString(Translate['Press_To_Delete'])
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                        if IsControlJustPressed(0, 38) then
                            if AdminBool then
                                AdminRemoveBlip()
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

---------------------------------
-- shiti way to delete for now --
---------------------------------

---------------
-- Functions --
---------------

CreateBlip = function(blipstable)
    for k, v in pairs(blipstable) do
        print('Creating Blip Num: '..k..'') 
        blip = AddBlipForCoord(v.Coords.x, v.Coords.y, v.Coords.z)
        SetBlipDisplay(blip, 2)
        SetBlipSprite(blip, v.Sprite)
        SetBlipColour(blip, v.Color)
        SetBlipScale(blip, v.Size)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.Title)
        EndTextCommandSetBlipName(blip)
        table.insert(blijp, blip)
    end
end

AdminRemoveBlip = function()
    for _,i in pairs(serversql) do
        local playerPos = GetEntityCoords(PlayerPedId(), true)
        local coords = vector3(i.Coords.x, i.Coords.y, i.Coords.z)
        if GetDistanceBetweenCoords(playerPos, coords, true)  <= 0.75 then
            TriggerServerEvent('Esx_Blips:delete', _)
            break
        end
    end
end