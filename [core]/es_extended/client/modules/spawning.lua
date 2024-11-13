ESX.PlayerLoaded = false

---@return boolean
function ESX.IsPlayerLoaded()
    return ESX.PlayerLoaded
end

function ESX.DisableSpawnManager()
    if GetResourceState("spawnmanager") == "started" then
        exports.spawnmanager:setAutoSpawn(false)
    end
end

---@param freeze boolean Whether to freeze the player
---@return nil
function Core.FreezePlayer(freeze)
    local ped = PlayerPedId()
    SetPlayerControl(ESX.playerId, not freeze, 0)

    if freeze then
        SetEntityCollision(ped, false, false)
        FreezeEntityPosition(ped, true)
    else
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
    end
end

---@param skin table Skin data to set
---@param coords table Coords to spawn the player at
---@param cb function Callback function
---@return nil
function ESX.SpawnPlayer(skin, coords, cb)
    local p = promise.new()
    TriggerEvent("skinchanger:loadSkin", skin, function()
        p:resolve()
    end)
    Citizen.Await(p)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local playerPed = PlayerPedId()
    local timer = GetGameTimer()

    Core.FreezePlayer(true)
    SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, true)
    SetEntityHeading(playerPed, coords.heading)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(playerPed) and (GetGameTimer() - timer) < 5000 do
        Wait(0)
    end

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, 0, true)
    TriggerEvent('playerSpawned', coords)
    cb()
end

local function ApplyMetadata(metadata)
    if metadata.health then
        SetEntityHealth(ESX.PlayerData.ped, metadata.health)
    end

    if metadata.armor and metadata.armor > 0 then
        SetPedArmour(ESX.PlayerData.ped, metadata.armor)
    end
end


function StartServerSyncLoops()
    if Config.CustomInventory then return end
    -- keep track of ammo
    CreateThread(function()
        local currentWeapon = { Ammo = 0 }
        while ESX.PlayerLoaded do
            local sleep = 1500
            if GetSelectedPedWeapon(ESX.PlayerData.ped) ~= -1569615261 then
                sleep = 1000
                local _, weaponHash = GetCurrentPedWeapon(ESX.PlayerData.ped, true)
                local weapon = ESX.GetWeaponFromHash(weaponHash)
                if weapon then
                    local ammoCount = GetAmmoInPedWeapon(ESX.PlayerData.ped, weaponHash)
                    if weapon.name ~= currentWeapon.name then
                        currentWeapon.Ammo = ammoCount
                        currentWeapon.name = weapon.name
                    else
                        if ammoCount ~= currentWeapon.Ammo then
                            currentWeapon.Ammo = ammoCount
                            TriggerServerEvent("esx:updateWeaponAmmo", weapon.name, ammoCount)
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end)
end

ESX.SecureNetEvent("esx:playerLoaded", function(xPlayer, _, skin)
    ESX.PlayerData = xPlayer

    if not Config.Multichar then
        ESX.SpawnPlayer(skin, ESX.PlayerData.coords, function()
            TriggerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:restoreLoadout")
            TriggerServerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:loadingScreenOff")
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
        end)
    end

    while not DoesEntityExist(ESX.PlayerData.ped) do
        Wait(20)
    end

    ESX.PlayerLoaded = true

    ApplyMetadata(ESX.PlayerData.metadata)

    local timer = GetGameTimer()
    while not HaveAllStreamingRequestsCompleted(ESX.PlayerData.ped) and (GetGameTimer() - timer) < 2000 do
        Wait(0)
    end

    Adjustments:Load()

    ClearPedTasksImmediately(ESX.PlayerData.ped)

    if not Config.Multichar then
        Core.FreezePlayer(false)
    end

    if IsScreenFadedOut() then
        DoScreenFadeIn(500)
    end

    Actions:Init()
    StartPointsLoop()
    StartServerSyncLoops()
end)

local function onPlayerSpawn()
    ESX.SetPlayerData("ped", PlayerPedId())
    ESX.SetPlayerData("dead", false)
end

AddEventHandler("playerSpawned", onPlayerSpawn)
AddEventHandler("esx:onPlayerSpawn", onPlayerSpawn)

AddEventHandler("skinchanger:modelLoaded", function()
    CreateThread(function()
        while not ESX.PlayerLoaded do
            Wait(100)
        end
        TriggerEvent("esx:restoreLoadout")
    end)
end)

ESX.SecureNetEvent("esx:onPlayerLogout", function()
    ESX.PlayerLoaded = false
end)

ESX.SecureNetEvent("esx:registerSuggestions", function(registeredCommands)
    for name, command in pairs(registeredCommands) do
        if command.suggestion then
            TriggerEvent("chat:addSuggestion", ("/%s"):format(name), command.suggestion.help, command.suggestion.arguments)
        end
    end
end)

if not Config.Multichar then
    CreateThread(function()
        while true do
            Wait(100)

            if NetworkIsPlayerActive(ESX.playerId) then
                ESX.DisableSpawnManager()
                DoScreenFadeOut(0)
                Wait(500)
                TriggerServerEvent("esx:onPlayerJoined")
                break
            end
        end
    end)
end
