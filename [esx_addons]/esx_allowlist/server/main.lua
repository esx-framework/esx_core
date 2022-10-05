local AllowList = {}

function loadAllowList()
	AllowList = nil

	local List = LoadResourceFile(GetCurrentResourceName(),'players.json')
	if List then
		AllowList = json.decode(List)
	end
end

loadAllowList()

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
	if #(GetPlayers()) < Config.MinPlayer then
		deferrals.done()
	else 
	-- Mark this connection as deferred, this is to prevent problems while checking player identifiers.
	deferrals.defer()

	local playerId, kickReason = source, "There Was An Error, Please Contact the server owner!"

	-- Letting the user know what's going on.
	deferrals.update(_U('allowlist_check'))

	-- Needed, not sure why.
	Wait(100)

	local identifier = ESX.GetIdentifier(playerId)

	if ESX.Table.SizeOf(AllowList) == 0 then
		kickReason = _U('allowlist_empty')
	elseif not identifier then
		kickReason = _U('license_missing')
	elseif not AllowList[identifier] then
		kickReason = _U('not_allowlist')
	end

	if kickReason then
		deferrals.done(kickReason)
	else
		deferrals.done()
	end
	end
end)

ESX.RegisterCommand('alrefresh', 'admin', function(xPlayer, args)
	loadAllowList()
	print('[^2INFO^7] Allowlist ^5Refreshed^7!')
end, true, {help = _U('help_allowlist_load')})

ESX.RegisterCommand('aladd', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if AllowList[args.license] then
			showError('The player is already allowlisted on this server!')
	else
		AllowList[args.license] = true
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(AllowList))
		loadAllowList()
	end
end, true, {help = _U('help_allowlist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})

ESX.RegisterCommand('alremove', 'admin', function(xPlayer, args, showError)
	args.license = args.license:lower()

	if AllowList[args.license] then
		AllowList[args.license] = nil
		SaveResourceFile(GetCurrentResourceName(), 'players.json', json.encode(AllowList))
		loadAllowList()
	else
		showError('Identifier is not Allowlisted on this server!')
	end
end, true, {help = _U('help_allowlist_add'), validate = true, arguments = {
	{name = 'license', help = 'the player license', type = 'string'}
}})
