local holdingup = false
local store = ""
local blipRobbery = nil
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function DisplayHelpText(str)
    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
        SetTextOutline()
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('esx_holdup:currentlyrobbing')
AddEventHandler('esx_holdup:currentlyrobbing', function(robb)
    holdingup = true
    store = robb
end)

RegisterNetEvent('esx_holdup:killblip')
AddEventHandler('esx_holdup:killblip', function()
    RemoveBlip(blipRobbery)
end)

RegisterNetEvent('esx_holdup:setblip')
AddEventHandler('esx_holdup:setblip', function(position)
    blipRobbery = AddBlipForCoord(position.x, position.y, position.z)
    SetBlipSprite(blipRobbery , 161)
    SetBlipScale(blipRobbery , 2.0)
    SetBlipColour(blipRobbery, 3)
    PulseBlip(blipRobbery)
end)

RegisterNetEvent('esx_holdup:toofarlocal')
AddEventHandler('esx_holdup:toofarlocal', function(robb)
    holdingup = false
    ESX.ShowNotification(_U('robbery_cancelled'))
    robbingName = ""
    incircle = false
end)


RegisterNetEvent('esx_holdup:robberycomplete')
AddEventHandler('esx_holdup:robberycomplete', function(robb)
    holdingup = false
    ESX.ShowNotification(_U('robbery_complete'))
    store = ""
    incircle = false
end)


RegisterNetEvent('esx_holdup:starttimer')
AddEventHandler('esx_holdup:starttimer', function(source)
    timer = Stores[store].secondsRemaining
    Citizen.CreateThread(function()
        while timer > 0 do
            Citizen.Wait(0)
            Citizen.Wait(1000)
            if(timer > 0)then
                timer = timer - 1
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if holdingup  then
                drawTxt(0.66, 1.44, 1.0,1.0,0.4, _U('robbery_of') .. timer .. _U('seconds_remaining'), 255, 255, 255, 255)
            end
        end
    end)
end)


Citizen.CreateThread(function()
    for k,v in pairs(Stores)do
        local ve = v.position

        local blip = AddBlipForCoord(ve.x, ve.y, ve.z)
        SetBlipSprite(blip, 156)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U('shop_robbery'))
        EndTextCommandSetBlipName(blip)
    end
end)
incircle = false


Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(GetPlayerPed(-1), true)

        for k,v in pairs(Stores)do
            local pos2 = v.position

            if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 15.0)then
                if not holdingup then
                    DrawMarker(1, v.position.x, v.position.y, v.position.z - 1, 0, 0, 0, 0, 0, 0, 1.0001, 1.0001, 1.5001, 1555, 0, 0,255, 0, 0, 0,0)

                    if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) < 1.0)then
                        if (incircle == false) then
                            DisplayHelpText(_U('press_to_rob') .. v.nameofstore)
                        end
                        incircle = true
                        if IsControlJustReleased(1, 51) then
                            TriggerServerEvent('esx_holdup:rob', k)
                        end
                    elseif(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > 1.0)then
                        incircle = false
                    end
                end
            end
        end

        if holdingup then

            local pos2 = Stores[store].position

            if(Vdist(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z) > 13)then
                TriggerServerEvent('esx_holdup:toofar', store)
            end
        end

        Citizen.Wait(0)
    end
end)
