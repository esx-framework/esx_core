local ActivateBlips = {}
local PlayerLoaded = true
local isInMarker, isInAtmMarker, isInMenu, isMarkerShowed = false, false, false, false
local _GetEntityCoords, _PlayerPedId

-- Functions

-- Listen for keypress while player inside the marker
local function Listen4Key()
    CreateThread(function()
        while (isInMarker or isInAtmMarker) and not isInMenu do
            if IsControlJustReleased(0, 38) then
                OpenUi(isInAtmMarker)
            end
            Wait(0)
        end
    end)
end

-- Create Blips
local function CreateBlips()
    local tmpActiveBlips = {}
    for i = 1, #Config.Banks do
        if type(Config.Banks[i].Blip) == 'table' and Config.Banks[i].Blip.Enabled then
            local blip = AddBlipForCoord(Config.Banks[i].Position.xy)
            SetBlipSprite(blip, Config.Banks[i].Blip.Sprite)
            SetBlipScale(blip, Config.Banks[i].Blip.Scale)
            SetBlipColour(blip, Config.Banks[i].Blip.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Banks[i].Blip.Label)
            EndTextCommandSetBlipName(blip)
            tmpActiveBlips[#tmpActiveBlips + 1] = blip
        end
    end

    ActivateBlips = tmpActiveBlips
end

-- Remove blips
local function RemoveBlips()
    for i = 1, #ActivateBlips do
        if DoesBlipExist(ActivateBlips[i]) then
            RemoveBlip(ActivateBlips[i])
        end
    end
    ActivateBlips = {}
end

function OpenUi(atm)
    atm = atm or false
    isInMenu = true
    ESX.HideUI()
    ESX.TriggerServerCallback('esx_banking:getPlayerData', function(data)
        SendNUIMessage({
            showMenu = true,
            openATM = atm,
            datas = {
                your_money_panel = {
                    accountsData = {{
                        name = "cash",
                        amount = data.money
                    }, {
                        name = "bank",
                        amount = data.bankMoney
                    }}
                },
                bankCardData = {
                    bankName = TranslateCap('bank_name'),
                    cardNumber = "2232 2222 2222 2222",
                    createdDate = "08/08",
                    name = data.playerName
                },
                transactionsData = data.transactionHistory
            }
        })
    end)
    SetNuiFocus(true, true)
end

local function CloseUi()
    SetNuiFocus(false, false)
    isInMenu = false
    SendNUIMessage({
        showMenu = false
    })

    if (isInMarker or isInAtmMarker) then
        ESX.TextUI(TranslateCap('press_e_banking'))
        Listen4Key()
    end
end

local function ShowMarker(coord)
    CreateThread(function()
        while isMarkerShowed do
            DrawMarker(20, coord.x, coord.y, coord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.2, 187, 255, 0, 255, false, true, 2, false, nil, nil, false)
            Wait(0)
        end
    end)
end

local function StartThread()
    CreateThread(function()
        CreateBlips()

        while PlayerLoaded do
            _PlayerPedId = PlayerPedId()
            _GetEntityCoords = GetEntityCoords(_PlayerPedId)

            if IsPedOnFoot(PlayerPedId()) then
                local closestBank = {}

                for i = 1, #Config.AtmModels do
                    local atm = GetClosestObjectOfType(_GetEntityCoords, 8.0, Config.AtmModels[i], false)
                    if atm ~= 0 then
                        local atmOffset = GetOffsetFromEntityInWorldCoords(atm, 0.0, -0.7, 0.0)
                        local atmDistance = #(_GetEntityCoords - atmOffset)
                        if not isInAtmMarker and atmDistance <= 1.5 then
                            isInAtmMarker = true
                            ESX.TextUI(TranslateCap('press_e_banking'))
                            Listen4Key()
                        elseif isInAtmMarker and atmDistance > 1.5 then
                            isInAtmMarker = false
                            ESX.HideUI()
                        end
                    end
                end

                for i = 1, #Config.Banks do
                    local bankDistance = #(_GetEntityCoords - Config.Banks[i].Position.xyz)

                    if bankDistance <= Config.DrawMarker then
                        closestBank = {Config.Banks[i].Position, bankDistance}
                    end
                end

                if not isMarkerShowed and next(closestBank) then
                    isMarkerShowed = true
                    ShowMarker(closestBank[1].xyz)
                elseif isMarkerShowed and not next(closestBank) then
                    isMarkerShowed = false
                end

                if next(closestBank) then
                    if not isInMarker and closestBank[2] <= 1.0 then
                        isInMarker = true
                        ESX.TextUI(TranslateCap('press_e_banking'))
                        Listen4Key()
                    elseif isInMarker and closestBank[2] > 1.0 then
                        isInMarker = false
                        ESX.HideUI()
                    end
                end

            end
            Wait(1000)
        end
    end)
end

-- NuiCallbacks
RegisterNUICallback('close', function(data, cb)
    CloseUi()
    cb('ok')
end)

RegisterNUICallback('clickButton', function(data, cb)
    if data ~= nil and isInMenu then
        TriggerServerEvent("esx_banking:doingType", data)
    end
    cb('ok')
end)

RegisterNUICallback('checkPincode', function(data, cb)
    if data ~= nil and isInMenu then
        ESX.TriggerServerCallback("esx_banking:checkPincode", function(pincode)
            if pincode then
                cb({
                    success = true
                })
                ESX.ShowNotification(TranslateCap('pincode_found'), "success")

            else
                cb({
                    error = true
                })
                ESX.ShowNotification(TranslateCap('pincode_not_found'), "error")
            end
        end, data)
    end
end)

-- Events
RegisterNetEvent('esx_banking:closebanking', function()
    CloseUi()
end)

local function loadNPC(index, netID)
    CreateThread(function()
        while not NetworkDoesEntityExistWithNetworkId(netID) do
            Wait(200)
        end
        local npc = NetworkGetEntityFromNetworkId(netID)
        
        TaskStartScenarioInPlace(npc, Config.Peds[index].Scenario, 0, true)
        SetEntityProofs(npc, true, true, true, true, true, true, true, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)
        SetPedCanRagdollFromPlayerImpact(npc, false)
        SetPedCanRagdoll(npc, false)
        SetEntityAsMissionEntity(npc, true, true)
        SetEntityDynamic(npc, false)
    end)
end

RegisterNetEvent('esx_banking:PedHandler', function(netIdTable)
    for i = 1, #netIdTable do
        loadNPC(i, netIdTable[i])
    end
end)

RegisterNetEvent('esx_banking:updateMoneyInUI')
AddEventHandler('esx_banking:updateMoneyInUI', function(doingType, bankMoney, money)
    SendNUIMessage({
        updateData = true,
        data = {
            type = doingType,
            bankMoney = bankMoney,
            money = money
        }
    })
end)

-- Resource starting
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    StartThread()
end)

-- Enables it on player loaded 
RegisterNetEvent('esx:playerLoaded', function()
    StartThread()
end)

-- Resource stopping
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    RemoveBlips()
    if isInMenu then
        CloseUi()
    end
end)
