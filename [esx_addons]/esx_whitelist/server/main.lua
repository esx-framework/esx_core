WhiteList = {}

function loadWhiteList(cb)
	Whitelist = {}

	MySQL.Async.fetchAll('SELECT identifier FROM whitelist', {}, function(result)
		for k,v in ipairs(result) do
			WhiteList[v.identifier] = true
		end

		if cb then
			cb()
		end
	end)
end

MySQL.ready(function()
	loadWhiteList()
end)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
	local xPlayers = ESX.GetPlayers()

	-- Mark this connection as deferred, this is to prevent problems while checking player identifiers.
	deferrals.defer()

	local playerId, kickReason = source
	
	-- Letting the user know what's going on.
	deferrals.update(_U('whitelist_check'))
	
	-- Needed, not sure why.
	Citizen.Wait(100)

	local identifier = ESX.GetIdentifier(playerId)

	if ESX.Table.SizeOf(WhiteList) == 0 then
		kickReason = _U('whitelist_empty')
	elseif not identifier then
		kickReason = _U('license_missing')
	elseif not WhiteList[identifier] then
		kickReason = _U('not_whitelisted')
	end

	if whitelisted or #xPlayers < Config.MinPlayer then
		deferrals.done()
	else
	  if kickReason then
		  deferrals.done(kickReason)
	  else
		  deferrals.done()
	  end
  end
end)
