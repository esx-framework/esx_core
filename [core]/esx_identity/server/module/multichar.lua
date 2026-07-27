local Multichar = {}

local multichar = ESX.GetConfig().Multichar

function Multichar.IsEnabled()
    return multichar
end

local function setIdentity(xPlayer)
    local playerIdentifier = xPlayer.getIdentifier()
    if not Modules.Identity.IsRegistered(playerIdentifier) then
        return
    end
    local currentIdentity = Modules.Identity.GetPlayerIdentity(playerIdentifier)
    Modules.Identity.SetPlayerData(xPlayer, currentIdentity)

    TriggerClientEvent("esx_identity:setPlayerData", xPlayer.src, currentIdentity)
    if currentIdentity.saveToDatabase then
        Modules.Database.SaveIdentity(playerIdentifier, currentIdentity)
    end

    Modules.Identity.ClearPlayerIdentity(playerIdentifier)
end

local function checkIdentity(xPlayer)
    local playerIdentifier = xPlayer.getIdentifier()

    local result = Modules.Database.GetIdentity(playerIdentifier)

    if not result then
        Modules.Identity.ClearPlayerIdentity(playerIdentifier)
        Modules.Identity.MarkAsNotRegistered(playerIdentifier)
        return TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.src)
    end
    if not result.firstname then
        Modules.Identity.ClearPlayerIdentity(playerIdentifier)
        Modules.Identity.MarkAsNotRegistered(playerIdentifier)
        return TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.src)
    end

    Modules.Identity.SetPlayerIdentity(playerIdentifier, {
        firstName = result.firstname,
        lastName = result.lastname,
        dateOfBirth = result.dateofbirth,
        sex = result.sex,
        height = result.height,
    })

    Modules.Identity.MarkAsRegistered(playerIdentifier)
    setIdentity(xPlayer)
end

function Multichar.RegisterHandlers()
    if multichar then
        return
    end

    AddEventHandler("playerConnecting", function(_, _, deferrals)
        deferrals.defer()
        local _, identifier = source, nil

        local correctLicense, _ = pcall(function()
            identifier = ESX.GetIdentifier(source)
        end)

        Wait(40)

        if not identifier or not correctLicense then
            return deferrals.done(TranslateCap("no_identifier"))
        end

        local result = Modules.Database.GetIdentity(identifier)
        if not result then
            Modules.Identity.ClearPlayerIdentity(identifier)
            Modules.Identity.MarkAsNotRegistered(identifier)
            return deferrals.done()
        end
        if not result.firstname then
            Modules.Identity.ClearPlayerIdentity(identifier)
            Modules.Identity.MarkAsNotRegistered(identifier)
            return deferrals.done()
        end

        Modules.Identity.SetPlayerIdentity(identifier, {
            firstName = result.firstname,
            lastName = result.lastname,
            dateOfBirth = result.dateofbirth,
            sex = result.sex,
            height = result.height,
        })

        Modules.Identity.MarkAsRegistered(identifier)
        deferrals.done()
    end)

    AddEventHandler("onResourceStart", function(resource)
        if resource ~= GetCurrentResourceName() then
            return
        end
        Wait(300)

        while not ESX do
            Wait(0)
        end

        local xPlayers = ESX.ExtendedPlayers()

        for i = 1, #xPlayers do
            if xPlayers[i] then
                checkIdentity(xPlayers[i])
            end
        end
    end)

    RegisterNetEvent("esx:playerLoaded", function(_, xPlayer)
        local currentIdentity = Modules.Identity.GetPlayerIdentity(xPlayer.identifier)
        
        if not currentIdentity or not Modules.Identity.IsRegistered(xPlayer.identifier) then
            TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.source)
            return
        end

        Modules.Identity.SetPlayerData(xPlayer, currentIdentity)

        TriggerClientEvent("esx_identity:setPlayerData", xPlayer.source, currentIdentity)
        if currentIdentity.saveToDatabase then
            Modules.Database.SaveIdentity(xPlayer.identifier, currentIdentity)
        end

        Wait(0)

        TriggerClientEvent("esx_identity:alreadyRegistered", xPlayer.source)

        Modules.Identity.ClearPlayerIdentity(xPlayer.identifier)
    end)
end

Modules.Multichar = Multichar
return Multichar