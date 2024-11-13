function Core.PlayerJoined(playerId)
    local identifier = ESX.GetIdentifier(playerId)
    if not identifier then
        return DropPlayer(playerId, "[ESX] there was an error loading your character!\nError code: identifier-missing-ingame\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.")
    end

    if ESX.GetPlayerFromIdentifier(identifier) then
        DropPlayer(
            playerId,
            ("[ESX] there was an error loading your character!\nError code: identifier-active-ingame\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same Rockstar account.\n\nYour Rockstar identifier: %s"):format(
                identifier
            )
        )
    else
        local result = MySQL.scalar.await("SELECT 1 FROM users WHERE identifier = ?", { identifier })
        if result then
            Core.LoadPlayer(identifier, playerId, false)
        else
            Core.CreatePlayer(identifier, playerId)
        end
    end
end

if Config.Multichar then
    AddEventHandler("esx:onPlayerJoined", function(src, char, data)
        while not next(ESX.Jobs) do
            Wait(50)
        end

        if not ESX.Players[src] then
            local identifier = char .. ":" .. ESX.GetIdentifier(src)
            if data then
                Core.CreatePlayer(identifier, src, data)
            else
                Core.LoadPlayer(identifier, src, false)
            end
        end
    end)
else
    RegisterNetEvent("esx:onPlayerJoined", function()
        local _source = source
        while not next(ESX.Jobs) do
            Wait(50)
        end

        if not ESX.Players[_source] then
            Core.PlayerJoined(_source)
        end
    end)

    AddEventHandler("playerConnecting", function(_, _, deferrals)
        local playerId = source
        deferrals.defer()
        Wait(0) -- Required
        local identifier = ESX.GetIdentifier(playerId)


        if not SetEntityOrphanMode then
            return deferrals.done(("[ESX] ESX Requires a minimum Artifact version of 10188, Please update your server."))
        end

        local oneSyncState = GetConvar("onesync", "off")
        if oneSyncState == "off" or oneSyncState == "legacy" then
            return deferrals.done(("[ESX] ESX Requires Onesync Infinity to work. This server currently has Onesync set to: %s"):format(oneSyncState))
        end

        if not Core.DatabaseConnected then
            return deferrals.done("[ESX] OxMySQL Was Unable To Connect to your database. Please make sure it is turned on and correctly configured in your server.cfg")
        end

        if identifier then
            if ESX.GetPlayerFromIdentifier(identifier) then
                return deferrals.done(
                    ("[ESX] There was an error loading your character!\nError code: identifier-active\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same account.\n\nYour identifier: %s"):format(identifier)
                )
            else
                return deferrals.done()
            end
        else
            return deferrals.done("[ESX] There was an error loading your character!\nError code: identifier-missing\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.")
        end
    end)
end

RegisterNetEvent("esx:onPlayerSpawn", function()
    ESX.Players[source].spawned = true
end)
