local npwd = GetResourceState('npwd'):find('start') and exports.npwd or nil

AddEventHandler('onServerResourceStart', function(resource)
	if resource ~= 'npwd' then
		return
	end

	npwd = GetResourceState('npwd'):find('start') and exports.npwd or nil

	for _, xPlayer in pairs(ESX.Players) do
		npwd:newPlayer({
			source = xPlayer.source,
			identifier = xPlayer.identifier,
			firstname = xPlayer.get('firstName'),
			lastname = xPlayer.get('lastName')
		})
	end
end)

AddEventHandler('onServerResourceStop', function(resource)
	if resource == 'npwd' then
		npwd = nil
	end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	if not npwd then
		return
	end

	if not xPlayer then
		xPlayer = ESX.GetPlayerFromId(playerId)
	end

	npwd:newPlayer({
		source = playerId,
		identifier = xPlayer.identifier,
		firstname = xPlayer.get('firstName'),
		lastname = xPlayer.get('lastName')
	})
end)

AddEventHandler('esx:playerLogout', function(playerId)
	if not npwd then
		return
	end

	npwd:unloadPlayer(playerId)
end)
