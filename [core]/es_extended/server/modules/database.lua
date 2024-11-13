Core.DatabaseConnected = false

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
