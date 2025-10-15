Config.DisableHealthRegeneration = false -- Player will no longer regenerate health
Config.DisableVehicleRewards = false -- Disables Player Receiving weapons from vehicles
Config.DisableNPCDrops = false -- stops NPCs from dropping weapons on death
Config.DisableDispatchServices = true -- Disable Dispatch services
Config.DisableScenarios = true -- Disable Scenarios
Config.DisableAimAssist = false -- disables AIM assist (mainly on controllers)
Config.DisableVehicleSeatShuff = false -- Disables vehicle seat shuff
Config.DisableDisplayAmmo = false -- Disable ammunition display
Config.EnablePVP = true -- Allow Player to player combat
Config.EnableWantedLevel = false -- Use Normal GTA wanted Level?

Config.RemoveHudComponents = {
    [1] = false, --WANTED_STARS,
    [2] = false, --WEAPON_ICON
    [3] = false, --CASH
    [4] = false, --MP_CASH
    [5] = false, --MP_MESSAGE
    [6] = true, --VEHICLE_NAME
    [7] = true, -- AREA_NAME
    [8] = true, -- VEHICLE_CLASS
    [9] = true, --STREET_NAME
    [10] = false, --HELP_TEXT
    [11] = false, --FLOATING_HELP_TEXT_1
    [12] = false, --FLOATING_HELP_TEXT_2
    [13] = false, --CASH_CHANGE
    [14] = false, --RETICLE
    [15] = false, --SUBTITLE_TEXT
    [16] = false, --RADIO_STATIONS
    [17] = false, --SAVING_GAME,
    [18] = false, --GAME_STREAM
    [19] = false, --WEAPON_WHEEL
    [20] = false, --WEAPON_WHEEL_STATS
    [21] = false, --HUD_COMPONENTS
    [22] = false, --HUD_WEAPONS
}

Config.Multipliers = {
    pedDensity = 1.0,
    scenarioPedDensityInterior = 0.0,
    scenarioPedDensityExterior = 1.0,
    ambientVehicleRange = 1.0,
    parkedVehicleDensity = 1.0,
    randomVehicleDensity = 1.0,
    vehicleDensity = 1.0
}


Config.PlayerStatsByGender = {
    enabled = true,
    debugMode = true,
    useCharacterData = true, -- true: uses ESX.PlayerData.sex | false: uses ped model/skin
    malePeds = {
        `mp_m_freemode_01`,
    },
    femalePeds = {
        `mp_f_freemode_01`,
    },
    male = {
        stamina = 1.0,
        strength = 1.0,
        swimSpeed = 1.25,
        moveSpeed = 1.0,

        -- ADD NEW STATS HERE
        -- 1. Uncomment line below (remove --)
        -- 2. Change value: 1.0 = normal, 1.5 = +50%, 0.5 = -50%
        -- 3. Find natives: https://docs.fivem.net/natives/
        -- statName = 1.0,
    },
   female = {
        stamina = 1.15,
        strength = 0.85,
        swimSpeed = 1.25,
        moveSpeed = 7.00,
    }
}

-- Pattern string format
--1 will lead to a random number from 0-9.
--A will lead to a random letter from A-Z.
-- . will lead to a random letter or number, with a 50% probability of being either.
--^1 will lead to a literal 1 being emitted.
--^A will lead to a literal A being emitted.
--Any other character will lead to said character being emitted.
-- A string shorter than 8 characters will be padded on the right.
Config.CustomAIPlates = "........" -- Custom plates for AI vehicles

--[[
    PlaceHolders:
    {server_name} - Server Display Name
    {server_endpoint} - Server IP:Server Port
    {server_players} - Current Player Count
    {server_maxplayers} - Max Player Count

    {player_name} - Player Name
    {player_rp_name} - Player RP Name
    {player_id} - Player ID
    {player_street} - Player Street Name
]]

Config.DiscordActivity = {
    appId = 0, -- Discord Application ID,
    assetName = "LargeIcon", --image name for the "large" icon.
    assetText = "{server_name}", -- Text to display on the asset
    buttons = {
        { label = "Join Server", url = "fivem://connect/{server_endpoint}" },
        { label = "Discord", url = "https://discord.esx-framework.org" },
    },
    presence = "{player_name} [{player_id}] | {server_players}/{server_maxplayers}",
    refresh = 1 * 60 * 1000, -- 1 minute
}
