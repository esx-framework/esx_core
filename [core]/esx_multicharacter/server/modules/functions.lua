function Server:GetIdentifier(source)
	local fxDk = GetConvarInt("sv_fxdkMode", 0)
	if fxDk == 1 then
		return "ESX-DEBUG-LICENCE"
	end

	local identifier = GetPlayerIdentifierByType(source, self.identifierType)
	return identifier and identifier:gsub(self.identifierType .. ":", "")
end

function Server:ResetPlayers()
	if next(ESX.Players) then
		local players = table.clone(ESX.Players)
		table.wipe(ESX.Players)

		for _, v in pairs(players) do
			ESX.Players[self:GetIdentifier(v.source)] = true
		end
	else
		ESX.Players = {}
	end
end

function Server:OnConnecting(source, deferrals)
	deferrals.defer()
	Wait(0) -- Required
	local identifier = self:GetIdentifier(source)

	if not SetEntityOrphanMode then
		return deferrals.done("[ESX] ESX Requires a minimum Artifact version of 10188, Please update your server.")
	end

	if Server.oneSync == "off" or Server.oneSync == "legacy" then
		return deferrals.done(
			("[ESX Multicharacter] ESX Requires Onesync Infinity to work. This server currently has Onesync set to: %s"):format(
				Server.oneSync
			)
		)
	end

	if not Database.found then
		deferrals.done(
			"[ESX Multicharacter] Cannot Find the servers mysql_connection_string. Please make sure it is correctly configured in your server.cfg"
		)
	end

	if not Database.connected then
		deferrals.done(
			"[ESX Multicharacter] OxMySQL Was Unable To Connect to your database. Please make sure it is turned on and correctly configured in your server.cfg"
		)
	end

	if not identifier then
		deferrals.done(
			("[ESX Multicharacter] Unable to retrieve player identifier.\nIdentifier type: %s"):format(
				Server.identifierType
			)
		)
		return
	end

	if ESX.GetConfig().EnableDebug then
		deferrals.done()
		return
	end

	if not ESX.Players[identifier] then
		return deferrals.done()
	end

	deferrals.done(
		("[ESX Multicharacter] A player is already connected to the server with this identifier.\nYour identifier: %s:%s"):format(
			Server.identifierType,
			identifier
		)
	)
end

Server:ResetPlayers()
