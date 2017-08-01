ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_skin:save')
AddEventHandler('esx_skin:save', function(skin)

	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.execute(
		'UPDATE users SET `skin` = @skin WHERE identifier = @identifier',
		{
			['@skin']       = json.encode(skin),
			['@identifier'] = xPlayer.identifier
		}
	)

end)

ESX.RegisterServerCallback('esx_skin:getPlayerSkin', function(source, cb)

	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll(
		'SELECT * FROM users WHERE identifier = @identifier',
		{
			['@identifier'] = xPlayer.identifier
		},
		function(users)

			local user = users[1]
			local skin = nil
			
			local jobSkin = {
				skin_male   = xPlayer.job.skin_male,
				skin_female = xPlayer.job.skin_female
			}

			if user.skin ~= nil then
				skin = json.decode(user.skin)
			end

			cb(skin, jobSkin)

		end
	)

end)

-- Commands
TriggerEvent('es:addGroupCommand', 'skin', "admin", function(source, args, user)
	TriggerClientEvent('esx_skin:openSaveableMenu', source)
end, function(source, args, user)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, 'Insufficienct permissions!')
end)