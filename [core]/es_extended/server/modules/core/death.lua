RegisterNetEvent('esx:onPlayerDeath')
RegisterNetEvent('esx:onPlayerRevive')

local deadPlayers = {}

local function SetDeadStatus(state)
    if not Config.SaveDeathStatus then return end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not type(state) == 'boolean' then return end
    MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', { state, xPlayer.identifier })
end

local function GetDeadStatus(xPlayer)
    local isDead = MySQL.query.await('SELECT is_dead FROM users WHERE identifier = ?', { xPlayer.identifier })
    return isDead[1].is_dead
end

AddEventHandler('esx:onPlayerDeath', function()
    deadPlayers[source] = true
    SetDeadStatus(true)
end)

AddEventHandler('esx:onPlayerRevive', function()
    deadPlayers[source] = nil
    SetDeadStatus(false)
end)

AddEventHandler('esx:playerLoaded', function (playerId, xPlayer, isNew)
    if not Config.SaveDeathStatus then return end
    local deadStatus = GetDeadStatus(xPlayer)
    if not deadStatus then return end
    Wait(1000)
    xPlayer.triggerEvent('esx:killPlayer')
end)

AddEventHandler('esx:onPlayerLogout', function()
    deadPlayers[source] = nil
end)

AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if GetInvokingResource() ~= "monitor" or type(eventData) ~= "table" or type(eventData.id) ~= "number" then
		return
	end

    if not deadPlayers[eventData.id] then return end
    local xPlayer = ESX.GetPlayerFromId(eventData.id)
    xPlayer.revive()
end)

function ESX.GetDeadPlayers()
    return deadPlayers
end