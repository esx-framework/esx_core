ESX.Players = {}

function Server:ResetPlayers()
    if next(ESX.Players) then
        local players = table.clone(ESX.Players)
        table.wipe(ESX.Players)

        for _, v in pairs(players) do
            ESX.Players[ESX.GetIdentifier(v.source)] = v.identifier
        end
    else
        ESX.Players = {}
    end
end

function Server:OnConnecting(source, deferrals)
    deferrals.defer()
    Wait(0) -- Required
    local identifier
    local correctLicense, _ = pcall(function()
        identifier = ESX.GetIdentifier(source)
    end)

    -- luacheck: ignore
    if not SetEntityOrphanMode then
        return deferrals.done(("[ESX Multicharacter] ESX Requires a minimum Artifact version of 10188, Please update your server."))
    end

    if Server.oneSync == "off" or Server.oneSync == "legacy" then
        return deferrals.done(("[ESX Multicharacter] ESX Requires Onesync Infinity to work. This server currently has Onesync set to: %s"):format(Server.oneSync))
    end

    if not Database.found then
        deferrals.done("[ESX Multicharacter] Cannot Find the servers mysql_connection_string. Please make sure it is correctly configured in your server.cfg")
    end

    if not Database.connected then
        deferrals.done("[ESX Multicharacter] OxMySQL Was Unable To Connect to your database. Please make sure it is turned on and correctly configured in your server.cfg")
    end

    if not identifier or not correctLicense then return deferrals.done(("[ESX Multicharacter] Unable to retrieve player identifier.\nIdentifier type: %s"):format(Server.identifierType)) end

    if ESX.GetConfig().EnableDebug or not ESX.Players[identifier] then
        ESX.Players[identifier] = source
        return deferrals.done()
    end

    ---@param staleSrc number
    local function cleanupStalePlayer(staleSrc)
        deferrals.update(("[ESX Multicharacter] Cleaning stale player entry..."):format(identifier))
        TriggerEvent("esx:onPlayerDropped", staleSrc, "esx_stale_player_obj", function()
            ESX.Players[identifier] = source
            deferrals.done()
        end)
    end

    local function reject()
        return deferrals.done(
            ("[ESX Multicharacter] There was an error loading your character!\nError code: identifier-active\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same account.\n\nYour identifier: %s"):format(
                identifier)
        )
    end

    local plyRef = ESX.Players[identifier] ---@type number|string If player has not chosen character yet, plyRef = source, otherwise plyRef = identifier prefix ("char1", "char2", etc.)
    if type(plyRef) == "number" then
        if GetPlayerPing(plyRef --[[@as string]]) > 0 then
            return reject()
        end

        return cleanupStalePlayer(plyRef)
    end

    local xPlayer = ESX.GetPlayerFromIdentifier(("%s:%s"):format(plyRef, identifier))
    if not xPlayer then
        ESX.Players[identifier] = source
        return deferrals.done()
    end

    if GetPlayerPing(xPlayer.source --[[@as string]]) > 0 then
        return reject()
    end

    return cleanupStalePlayer(xPlayer.source)
end


Server:ResetPlayers()
