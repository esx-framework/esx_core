WhiteList = {}

function loadWhiteList()
	WhiteList = nil

	local List = LoadResourceFile(GetCurrentResourceName(),'players.json')
	if List then
		WhiteList = json.decode(List)
	end
end

loadWhiteList()

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
	if #(GetPlayers()) < Config.MinPlayer then
		deferrals.done()
	else 
	-- Mark this connection as deferred, this is to prevent problems while checking player identifiers.
	deferrals.defer()

	local playerId, kickReason = source

	-- Letting the user know what's going on.
	deferrals.update(_U('whitelist_check'))

	-- Needed, not sure why.
	Wait(100)

	local identifier = ESX.GetIdentifier(playerId)

	if ESX.Table.SizeOf(WhiteList) == 0 then
		kickReason = _U('whitelist_empty')
	elseif not identifier then
		kickReason = _U('license_missing')
	elseif not WhiteList[identifier] then
		kickReason = _U('not_whitelisted')
	end

	if kickReason then
		deferrals.done(kickReason)
	else
		deferrals.done()
	end
	end
end)

ESX.RegisterCommand('wlrefresh', 'admin', function(xPlayer, args, showError)
	loadWhiteList(function()
		showError('Whitelist reloaded')
	end)
end, true, {help = _U('help_whitelist_load')})

ESX.RegisterCommand('wladd', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if WhiteList[args.license] then
			showError('The player is already allowlisted on this server!')
	else
		WhiteList[args.license] = true
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(WhiteList))
		loadWhiteList()
	end
end, true, {help = _U('help_whitelist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})

ESX.RegisterCommand('wlremove', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if WhiteList[args.license] then
		WhiteList[args.license] = nil
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(WhiteList))
		loadWhiteList()
	else
		showError('Identifier is not Allowlisted on this server!')
	end
end, true, {help = _U('help_whitelist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})
