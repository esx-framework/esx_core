Adjustments = {}

function Adjustments:RemoveHudComponents()
    for i = 1, #Config.RemoveHudComponents do
        if Config.RemoveHudComponents[i] then
            SetHudComponentSize(i, 0.0, 0.0)
            SetHudComponentPosition(i, 900.0, 900.0)
        end
    end
end

function Adjustments:DisableAimAssist()
    if Config.DisableAimAssist then
        SetPlayerTargetingMode(3)
    end
end

function Adjustments:DisableNPCDrops()
    if Config.DisableNPCDrops then
        local weaponPickups = { `PICKUP_WEAPON_CARBINERIFLE`, `PICKUP_WEAPON_PISTOL`, `PICKUP_WEAPON_PUMPSHOTGUN` }
        for i = 1, #weaponPickups do
            ToggleUsePickupsForPlayer(ESX.playerId, weaponPickups[i], false)
        end
    end
end

function Adjustments:SeatShuffle()
    if Config.DisableVehicleSeatShuff then
        AddEventHandler("esx:enteredVehicle", function(vehicle, _, seat)
            if seat > -1 then
                SetPedIntoVehicle(ESX.PlayerData.ped, vehicle, seat)
                SetPedConfigFlag(ESX.PlayerData.ped, 184, true)
            end
        end)
    end
end

function Adjustments:HealthRegeneration()
    if Config.DisableHealthRegeneration then
        SetPlayerHealthRechargeMultiplier(ESX.playerId, 0.0)
    end
end

function Adjustments:AmmoAndVehicleRewards()
    CreateThread(function()
        while true do
            if Config.DisableDisplayAmmo then
                DisplayAmmoThisFrame(false)
            end

            if Config.DisableVehicleRewards then
                DisablePlayerVehicleRewards(ESX.playerId)
            end

            Wait(0)
        end
    end)
end

function Adjustments:EnablePvP()
    if Config.EnablePVP then
        SetCanAttackFriendly(ESX.PlayerData.ped, true, false)
        NetworkSetFriendlyFireOption(true)
    end
end

function Adjustments:DispatchServices()
    if Config.DisableDispatchServices then
        for i = 1, 15 do
            EnableDispatchService(i, false)
        end
        SetAudioFlag('PoliceScannerDisabled', true)
    end
end

function Adjustments:NPCScenarios()
    if Config.DisableScenarios then
        local scenarios = {
            "WORLD_VEHICLE_ATTRACTOR",
            "WORLD_VEHICLE_AMBULANCE",
            "WORLD_VEHICLE_BICYCLE_BMX",
            "WORLD_VEHICLE_BICYCLE_BMX_BALLAS",
            "WORLD_VEHICLE_BICYCLE_BMX_FAMILY",
            "WORLD_VEHICLE_BICYCLE_BMX_HARMONY",
            "WORLD_VEHICLE_BICYCLE_BMX_VAGOS",
            "WORLD_VEHICLE_BICYCLE_MOUNTAIN",
            "WORLD_VEHICLE_BICYCLE_ROAD",
            "WORLD_VEHICLE_BIKE_OFF_ROAD_RACE",
            "WORLD_VEHICLE_BIKER",
            "WORLD_VEHICLE_BOAT_IDLE",
            "WORLD_VEHICLE_BOAT_IDLE_ALAMO",
            "WORLD_VEHICLE_BOAT_IDLE_MARQUIS",
            "WORLD_VEHICLE_BROKEN_DOWN",
            "WORLD_VEHICLE_BUSINESSMEN",
            "WORLD_VEHICLE_HELI_LIFEGUARD",
            "WORLD_VEHICLE_CLUCKIN_BELL_TRAILER",
            "WORLD_VEHICLE_CONSTRUCTION_SOLO",
            "WORLD_VEHICLE_CONSTRUCTION_PASSENGERS",
            "WORLD_VEHICLE_DRIVE_PASSENGERS",
            "WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED",
            "WORLD_VEHICLE_DRIVE_SOLO",
            "WORLD_VEHICLE_FIRE_TRUCK",
            "WORLD_VEHICLE_EMPTY",
            "WORLD_VEHICLE_MARIACHI",
            "WORLD_VEHICLE_MECHANIC",
            "WORLD_VEHICLE_MILITARY_PLANES_BIG",
            "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
            "WORLD_VEHICLE_PARK_PARALLEL",
            "WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN",
            "WORLD_VEHICLE_PASSENGER_EXIT",
            "WORLD_VEHICLE_POLICE_BIKE",
            "WORLD_VEHICLE_POLICE_CAR",
            "WORLD_VEHICLE_POLICE",
            "WORLD_VEHICLE_POLICE_NEXT_TO_CAR",
            "WORLD_VEHICLE_QUARRY",
            "WORLD_VEHICLE_SALTON",
            "WORLD_VEHICLE_SALTON_DIRT_BIKE",
            "WORLD_VEHICLE_SECURITY_CAR",
            "WORLD_VEHICLE_STREETRACE",
            "WORLD_VEHICLE_TOURBUS",
            "WORLD_VEHICLE_TOURIST",
            "WORLD_VEHICLE_TANDL",
            "WORLD_VEHICLE_TRACTOR",
            "WORLD_VEHICLE_TRACTOR_BEACH",
            "WORLD_VEHICLE_TRUCK_LOGS",
            "WORLD_VEHICLE_TRUCKS_TRAILERS",
            "WORLD_VEHICLE_DISTANT_EMPTY_GROUND",
            "WORLD_HUMAN_PAPARAZZI",
        }

        for i=1, #scenarios do
            SetScenarioTypeEnabled(scenarios[i], false)
        end
    end
end

function Adjustments:LicensePlates()
    SetDefaultVehicleNumberPlateTextPattern(-1, Config.CustomAIPlates)
end

local placeHolders = {
    server_name = function()
        return GetConvar("sv_projectName", "ESX-Framework")
    end,
    server_endpoint = function()
        return GetCurrentServerEndpoint() or "localhost:30120"
    end,
    server_players = function()
        return GlobalState.playerCount or 0
    end,
    server_maxplayers = function()
        return GetConvarInt("sv_maxClients", 48)
    end,
    player_name = function()
        return GetPlayerName(ESX.playerId)
    end,
    player_rp_name = function()
        return ESX.PlayerData.name or "John Doe"
    end,
    player_id = function()
        return ESX.serverId
    end,
    player_street = function()
        if not ESX.PlayerData.ped then return "Unknown" end

        local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
        local streetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)

        return GetStreetNameFromHashKey(streetHash) or "Unknown"
    end,
}

function Adjustments:ReplacePlaceholders(text)
    for placeholder, cb in pairs(placeHolders) do
        local success, result = pcall(cb)

        if not success then
            error(("Failed to execute placeholder: ^5%s^7\n%s"):format(placeholder, result))
            result = "Unknown"
        end

        text = text:gsub(("{%s}"):format(placeholder), tostring(result))
    end
    return text
end

function Adjustments:DiscordPresence()
    if Config.DiscordActivity.appId ~= 0 then
        CreateThread(function()
            while true do
                SetDiscordAppId(Config.DiscordActivity.appId)
                SetRichPresence(self:ReplacePlaceholders(Config.DiscordActivity.presence))
                SetDiscordRichPresenceAsset(Config.DiscordActivity.assetName)
                SetDiscordRichPresenceAssetText(self:ReplacePlaceholders(Config.DiscordActivity.assetText))

                for i = 1, #Config.DiscordActivity.buttons do
                    local button = Config.DiscordActivity.buttons[i]
                    local buttonUrl = self:ReplacePlaceholders(button.url)
                    SetDiscordRichPresenceAction(i - 1, button.label, buttonUrl)
                end

                Wait(Config.DiscordActivity.refresh)
            end
        end)
    end
end

function Adjustments:WantedLevel()
    if not Config.EnableWantedLevel then
        ClearPlayerWantedLevel(ESX.playerId)
        SetMaxWantedLevel(0)
    end
end

function Adjustments:DisableRadio()
    if Config.RemoveHudComponents[16] then
        AddEventHandler("esx:enteredVehicle", function(vehicle, plate, seat, displayName, netId)
            SetVehRadioStation(vehicle,"OFF")
            SetUserRadioControlEnabled(false)
        end)
    end
end

function Adjustments:Multipliers()
    CreateThread(function()
        while true do
            SetPedDensityMultiplierThisFrame(Config.Multipliers.pedDensity)
            SetScenarioPedDensityMultiplierThisFrame(Config.Multipliers.scenarioPedDensityInterior, Config.Multipliers.scenarioPedDensityExterior)
            SetAmbientVehicleRangeMultiplierThisFrame(Config.Multipliers.ambientVehicleRange)
            SetParkedVehicleDensityMultiplierThisFrame(Config.Multipliers.parkedVehicleDensity)
            SetRandomVehicleDensityMultiplierThisFrame(Config.Multipliers.randomVehicleDensity)
            SetVehicleDensityMultiplierThisFrame(Config.Multipliers.vehicleDensity)
            Wait(0)
        end
    end)
end

function Adjustments:ApplyPlayerStats()
 if not Config.PlayerStatsByGender.enabled then return end

    if Config.PlayerStatsByGender.debugMode then
        print('[^3adjustments^7] applying player stats...')
    end

    local gender = self:GetPlayerGender()
    if not gender then
        if Config.PlayerStatsByGender.debugMode then
            print('[^1adjustments^7] failed to detect gender')
        end
        return
    end

    local stats = Config.PlayerStatsByGender[gender]
    if not stats then
        if Config.PlayerStatsByGender.debugMode then
            print('[^1adjustments^7] no stats found for gender: ' .. gender)
        end
        return
    end

    if stats.stamina then
        SetRunSprintMultiplierForPlayer(ESX.playerId, stats.stamina)
        if Config.PlayerStatsByGender.debugMode then
            print('[^2adjustments^7] stamina: ' .. tostring(stats.stamina))
        end
    end

    if stats.strength then
        SetPlayerMeleeWeaponDamageModifier(ESX.playerId, stats.strength)
        if Config.PlayerStatsByGender.debugMode then
            print('[^2adjustments^7] strength: ' .. tostring(stats.strength))
        end
    end

    if stats.swimSpeed then
        SetSwimMultiplierForPlayer(ESX.playerId, stats.swimSpeed)
        if Config.PlayerStatsByGender.debugMode then
            print('[^2adjustments^7] swimSpeed: ' .. tostring(stats.swimSpeed))
        end
    end

    if stats.moveSpeed then
        self.currentMoveSpeed = stats.moveSpeed
        if not self.moveSpeedThreadRunning then
            self.moveSpeedThreadRunning = true
            CreateThread(function()
                while Config.PlayerStatsByGender.enabled and self.currentMoveSpeed do
                    if ESX.PlayerData.ped then
                        SetPedMoveRateOverride(ESX.PlayerData.ped, self.currentMoveSpeed)
                    end
                    Wait(0)
                end
                self.moveSpeedThreadRunning = false
            end)
        end
        if Config.PlayerStatsByGender.debugMode then
            print('[^2adjustments^7] moveSpeed: ' .. tostring(stats.moveSpeed))
        end
    end

    -- ADD NEW STATS HERE
    -- ========================================================================
    -- 1. Find your native: https://docs.fivem.net/natives/
    -- 2. Uncomment template below (remove --)
    -- 3. Replace "statName" with your stat name
    -- 4. Replace "YourNative" with native from docs
    -- 5. Add same stat to Config file
    -- 6. Debug print is OPTIONAL (can be removed)
    -- ========================================================================

    -- if stats.statName then
    --     YourNative(ESX.playerId, stats.statName)
    --     if Config.PlayerStatsByGender.debugMode then
    --         print('[^2adjustments^7] statName: ' .. tostring(stats.statName))
    --     end
    -- end

    if Config.PlayerStatsByGender.debugMode then
        print('[^2adjustments^7] stats applied for gender: ' .. gender)
    end
end

function Adjustments:GetPlayerGender()
    if not ESX.PlayerLoaded then
        if Config.PlayerStatsByGender.debugMode then
            print('[^1adjustments^7] player not loaded yet')
        end
        return
    end

    if Config.PlayerStatsByGender.debugMode then
        print('[^3adjustments^7] detecting gender using: ' .. (Config.PlayerStatsByGender.useCharacterData and 'character data' or 'ped model'))
    end

    if Config.PlayerStatsByGender.useCharacterData then
        if ESX.PlayerData.sex then
            return ESX.PlayerData.sex == 'm' and 'male' or 'female'
        end
    else
        local model = GetEntityModel(ESX.PlayerData.ped)

        for i = 1, #Config.PlayerStatsByGender.malePeds do
            if model == Config.PlayerStatsByGender.malePeds[i] then
                return 'male'
            end
        end

        for i = 1, #Config.PlayerStatsByGender.femalePeds do
            if model == Config.PlayerStatsByGender.femalePeds[i] then
                return 'female'
            end
        end

        if IsPedMale(ESX.PlayerData.ped) then
            return 'male'
        else
            return 'female'
        end
    end

    return nil
end


function Adjustments:RefreshPlayerStats()
      self:ApplyPlayerStats()
end

function Adjustments:Load()
    self:RemoveHudComponents()
    self:DisableAimAssist()
    self:DisableNPCDrops()
    self:SeatShuffle()
    self:HealthRegeneration()
    self:AmmoAndVehicleRewards()
    self:EnablePvP()
    self:DispatchServices()
    self:NPCScenarios()
    self:LicensePlates()
    self:DiscordPresence()
    self:WantedLevel()
    self:DisableRadio()
    self:Multipliers()

    AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
        if Config.PlayerStatsByGender.debugMode then
            print('[^3adjustments^7] esx:playerloaded event triggered')
        end
        self:ApplyPlayerStats()
    end)

    if not Config.PlayerStatsByGender.useCharacterData then
        AddEventHandler('skinchanger:modelLoaded', function()
            if Config.PlayerStatsByGender.debugMode then
                print('[^3adjustments^7] skinchanger:modelloaded event triggered')
            end
            self:RefreshPlayerStats()
        end)
    else
        if Config.PlayerStatsByGender.debugMode then
            print('[^3adjustments^7] skinchanger event not registered (using character data)')
        end
    end

    AddEventHandler('esx:onPlayerSpawn', function()
         if Config.PlayerStatsByGender.debugMode then
            print('[^3adjustments^7] esx:onplayerspawn event triggered')
        end
        self:RefreshPlayerStats()
    end)
    if Config.PlayerStatsByGender.enabled and Config.PlayerStatsByGender.debugMode then
        print('[^2adjustments^7] player stats by gender loaded')
        print('[^3adjustments^7] enabled: ' .. tostring(Config.PlayerStatsByGender.enabled))
        print('[^3adjustments^7] use character data: ' .. tostring(Config.PlayerStatsByGender.useCharacterData))
        print('[^3adjustments^7] debug mode: active')
    end
end
