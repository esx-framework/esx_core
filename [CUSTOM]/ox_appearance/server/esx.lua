local ESX = GetResourceState('es_extended'):find('start') and exports.es_extended:getSharedObject()
if not ESX then return end

ESX = {
    GetExtendedPlayers = ESX.GetExtendedPlayers,
    RegisterServerCallback = ESX.RegisterServerCallback,
}

do
    local xPlayers = ESX.GetExtendedPlayers()

    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        Players[xPlayer.source] = xPlayer.identifier
        TriggerClientEvent('ox_appearance:outfitNames', xPlayer.source, OutfitNames(xPlayer.identifier))
    end
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    Players[playerId] = xPlayer.identifier
    TriggerClientEvent('ox_appearance:outfitNames', playerId, OutfitNames(xPlayer.identifier))
end)

RegisterNetEvent('esx_skin:save', function(appearance)
    local identifier = Players[source]
    MySQL.update('UPDATE users SET skin = ? WHERE identifier = ?', { json.encode(appearance), identifier })
end)

ESX.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)
    local identifier = Players[source]
    local appearance = MySQL.scalar.await('SELECT skin FROM users WHERE identifier = ?', { identifier })
    cb(appearance and json.decode(appearance) or {})
end)
