RegisterNetEvent("esx_skin:save", function(skin)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        local backpackModifier = Config.BackpackWeight[skin.bags_1]

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + backpackModifier)
        else
            xPlayer.setMaxWeight(defaultMaxWeight)
        end
    end

    MySQL.update("UPDATE users SET skin = @skin WHERE identifier = @identifier", {
        ["@skin"] = json.encode(skin),
        ["@identifier"] = xPlayer.identifier,
    })
end)

RegisterNetEvent("esx_skin:setWeight", function(skin)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        local backpackModifier = Config.BackpackWeight[skin.bags_1]

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + backpackModifier)
        else
            xPlayer.setMaxWeight(defaultMaxWeight)
        end
    end
end)

ESX.RegisterServerCallback("esx_skin:getPlayerSkin", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.query("SELECT skin FROM users WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.identifier,
    }, function(users)
        local user, skin = users[1], nil

        local jobSkin = {
            skin_male = xPlayer.job.skin_male,
            skin_female = xPlayer.job.skin_female,
        }

        if user.skin then
            skin = json.decode(user.skin)
        end

        cb(skin, jobSkin)
    end)
end)

ESX.RegisterCommand("skin", "admin", function(xPlayer, args)
    if not args.playerId then
        args.playerId = xPlayer
    end
    args.playerId.triggerEvent("esx_skin:openSaveableMenu")
end, false, { help = TranslateCap("skin"), arguments = { { name = "playerId", help = TranslateCap("skin"), type = "player" }} })
