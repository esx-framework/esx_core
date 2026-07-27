local Identity = {}

local playerIdentity = {}
local alreadyRegistered = {}

function Identity.SetPlayerData(xPlayer, data)
    local name = ("%s %s"):format(data.firstName, data.lastName)
    xPlayer.setName(name)
    xPlayer.set("firstName", data.firstName)
    xPlayer.set("lastName", data.lastName)
    xPlayer.set("dateofbirth", data.dateOfBirth)
    xPlayer.set("sex", data.sex)
    xPlayer.set("height", data.height)

    local state = Player(xPlayer.getSource()).state
    state:set("name", name, true)
    state:set("firstName", data.firstName, true)
    state:set("lastName", data.lastName, true)
    state:set("dateofbirth", data.dateOfBirth, true)
    state:set("sex", data.sex, true)
    state:set("height", data.height, true)
end

function Identity.IsRegistered(identifier)
    return alreadyRegistered[identifier] == true
end

function Identity.MarkAsRegistered(identifier)
    alreadyRegistered[identifier] = true
end

function Identity.MarkAsNotRegistered(identifier)
    alreadyRegistered[identifier] = false
end

function Identity.SetPlayerIdentity(identifier, identity)
    playerIdentity[identifier] = identity
end

function Identity.GetPlayerIdentity(identifier)
    return playerIdentity[identifier]
end

function Identity.ClearPlayerIdentity(identifier)
    playerIdentity[identifier] = nil
end

function Identity.SendNotification(source, translationKey, translationParams)
    TriggerClientEvent("esx:showNotification", source, TranslateCap(translationKey, translationParams), "error")
end

Modules.Identity = Identity
return Identity

