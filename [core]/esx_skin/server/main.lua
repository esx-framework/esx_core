-- Highest configured backpack modifier: a client-supplied bags_1 can never raise max weight past it.
local MaxBackpackModifier = 0
for _, modifier in pairs(Config.BackpackWeight) do
    if type(modifier) == "number" and modifier > MaxBackpackModifier then
        MaxBackpackModifier = modifier
    end
end

-- skin (and bags_1) come from the client: only accept a numeric key mapping to a configured backpack
-- and clamp the modifier to the highest configured value.
local function resolveBackpackModifier(skin)
    local modifier = type(skin.bags_1) == "number" and Config.BackpackWeight[skin.bags_1] or nil
    return modifier and math.min(modifier, MaxBackpackModifier) or nil
end

RegisterNetEvent("esx_skin:save", function(skin)
    if not skin or type(skin) ~= "table" then
        return
    end
    local xPlayer = ESX.Player(source)
    if not xPlayer then
        return
    end

    if not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        local backpackModifier = resolveBackpackModifier(skin)

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + backpackModifier)
        else
            xPlayer.setMaxWeight(defaultMaxWeight)
        end
    end

    MySQL.update("UPDATE users SET skin = @skin WHERE identifier = @identifier", {
        ["@skin"] = json.encode(skin),
        ["@identifier"] = xPlayer.getIdentifier(),
    })
end)

RegisterNetEvent("esx_skin:setWeight", function(skin)
    if type(skin) ~= "table" then
        return
    end
    local xPlayer = ESX.Player(source)
    if not xPlayer then
        return
    end

    if not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        local backpackModifier = resolveBackpackModifier(skin)

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + backpackModifier)
        else
            xPlayer.setMaxWeight(defaultMaxWeight)
        end
    end
end)

ESX.RegisterServerCallback("esx_skin:getPlayerSkin", function(source, cb)
    local xPlayer = ESX.Player(source)

    MySQL.query("SELECT skin FROM users WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.getIdentifier(),
    }, function(users)
        local user, skin = users[1], nil

        local jobSkin = {
            skin_male = xPlayer.getJob().skin_male,
            skin_female = xPlayer.getJob().skin_female,
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
