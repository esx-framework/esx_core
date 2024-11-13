Core = {}
Core.UsableItemsCallbacks = {}
Core.Pickups = {}
Core.PickupId = 0
Core.DatabaseConnected = false
Core.vehicleTypesByModel = {}

NewPlayer = "INSERT INTO `users` SET `accounts` = ?, `identifier` = ?, `group` = ?"
LoadPlayer = "SELECT `accounts`, `job`, `job_grade`, `group`, `position`, `inventory`, `skin`, `loadout`, `metadata`"

if Config.Multichar then
    NewPlayer = NewPlayer .. ", `firstname` = ?, `lastname` = ?, `dateofbirth` = ?, `sex` = ?, `height` = ?"
end

if Config.StartingInventoryItems then
    NewPlayer = NewPlayer .. ", `inventory` = ?"
end

if Config.Multichar or Config.Identity then
    LoadPlayer = LoadPlayer .. ", `firstname`, `lastname`, `dateofbirth`, `sex`, `height`"
end

LoadPlayer = LoadPlayer .. " FROM `users` WHERE identifier = ?"

MySQL.ready(function()
    Core.DatabaseConnected = true
    if not Config.CustomInventory then
        local items = MySQL.query.await("SELECT * FROM items")
        for _, v in ipairs(items) do
            ESX.Items[v.name] = { label = v.label, weight = v.weight, rare = v.rare, canRemove = v.can_remove }
        end
    end

    ESX.RefreshJobs()

    print(("[^2INFO^7] ESX ^5Legacy %s^0 initialized!"):format(GetResourceMetadata(GetCurrentResourceName(), "version", 0)))

    Core.PlayerSaveLoop()
    if Config.EnablePaycheck then
        StartPayCheck()
    end
end)

Core.BlacklistedScripts = {
    ["essentialmode"] = true,
    ["es_admin2"] = true,
    ["basic-gamemode"] = true,
    ["mapmanager"] = true,
    ["fivem-map-skater"] = true,
    ["fivem-map-hipster"] = true,
    ["qb-core"] = true,
    ["default_spawnpoint"] = true,
}

for key in pairs(Core.BlacklistedScripts) do
    if GetResourceState(key) == "started" or GetResourceState(key) == "starting" then
        StopResource(key)
        error(("WE STOPPED A RESOURCE THAT WILL BREAK ^1ESX^1, PLEASE REMOVE ^5%s^1"):format(key))
    end
end

SetMapName(Config.MapName or "San Andreas")
SetGameType(Config.GameType or "ESX-Framework")
