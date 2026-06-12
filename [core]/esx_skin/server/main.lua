-- Fix: precompute the highest configured backpack modifier so client-supplied bags_1 can never
-- raise the player's max weight beyond what the server config actually permits.
local MaxBackpackModifier = 0
for _, modifier in pairs(Config.BackpackWeight) do
    if type(modifier) == "number" and modifier > MaxBackpackModifier then
        MaxBackpackModifier = modifier
    end
end

RegisterNetEvent("esx_skin:save", function(skin)
    if not skin or type(skin) ~= "table" then
        return
    end
    local xPlayer = ESX.Player(source)

    if not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        -- Fix: the skin (and bags_1) come from the client; only accept a numeric key that maps to a
        -- configured backpack and bound the modifier to the highest configured value so a crafted
        -- value can never inflate the player's max weight beyond what the config allows.
        local backpackModifier = type(skin.bags_1) == "number" and Config.BackpackWeight[skin.bags_1] or nil

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + math.min(backpackModifier, MaxBackpackModifier))
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
    -- Fix: guard against a missing/invalid skin payload (this handler lacked the type check the
    -- save handler already has) before indexing it.
    if type(skin) ~= "table" then
        return
    end
    local xPlayer = ESX.Player(source)

    if not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        -- Fix: do not trust the client bags_1 value for max weight; require a numeric key and bound
        -- the resulting modifier to the highest configured backpack value.
        local backpackModifier = type(skin.bags_1) == "number" and Config.BackpackWeight[skin.bags_1] or nil

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + math.min(backpackModifier, MaxBackpackModifier))
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
