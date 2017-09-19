--==================================================================================
--======               ESX_IDENTITY BY ARKSEYONET @Ark                        ======
--======    YOU CAN FIND ME ON MY DISCORD @Ark - https://discord.gg/cGHHxPX   ======
--======    IF YOU ALTER THIS VERSION OF THE SCRIPT, PLEASE GIVE ME CREDIT    ======
--======     Special Thanks To Alphakush and CMD.Telhada For Help Testing     ======
--==================================================================================

--===============================================
--==     Get The Player's Identification       ==
--===============================================
function getIdentity(source, callback)
	local identifier = GetPlayerIdentifiers(source)[1]
    MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = @identifier",
	{
		['@identifier'] = identifier
	},
	function(result)
		if result[1]['firstname'] ~= nil then
			local data = {
				identifier	= result[1]['identifier'],
				firstname	= result[1]['firstname'],
				lastname	= result[1]['lastname'],
				dateofbirth	= result[1]['dateofbirth'],
				sex			= result[1]['sex'],
				height		= result[1]['height']
			}
			
			callback(data)
		else	
			local data = {
				identifier 	= '',
				firstname 	= '',
				lastname 	= '',
				dateofbirth = '',
				sex 		= '',
				height 		= ''
			}
			
			callback(data)
		end
	end)
end

--===============================================
--==    Set The Player's Identification        ==
--===============================================
function setIdentity(identifier, data, callback)
  MySQL.Async.execute("UPDATE `users` SET `firstname` = @firstname, `lastname` = @lastname, `dateofbirth` = @dateofbirth, `sex` = @sex, `height` = @height WHERE identifier = @identifier",
    {
      ['@identifier']   = identifier,
      ['@firstname']    = data.firstname,
      ['@lastname']     = data.lastname,
      ['@dateofbirth']  = data.dateofbirth,
      ['@sex']    		= data.sex,
      ['@height']     	= data.height
    },
	function(done)
		if callback then
			callback(true)
		end
	end)
end

--===============================================
--==       Server Event Set Identity           ==
--===============================================
RegisterServerEvent('esx_identity:setIdentity')
AddEventHandler('esx_identity:setIdentity', function(data)
	local identifier = GetPlayerIdentifiers(source)[1]
    setIdentity(GetPlayerIdentifiers(source)[1], data, function(callback)
		if callback == true then
			print('Successfully Set Identity For ' .. identifier)
		else
			print('Failed To Set Identity.')
		end
	end)
end)

--===============================================
--==       Player Loaded Event Handler         ==
--===============================================
AddEventHandler('es:playerLoaded', function(source)
	getIdentity(source, function(data)
		if data.firstname == '' then
			TriggerClientEvent('esx_identity:showRegisterIdentity', source)
		else
			print('Successfully Loaded Identity For ' .. data.firstname .. ' ' .. data.lastname)
		end
	end)
end)

--===============================================
--==      /register - Open Registration        ==
--===============================================
TriggerEvent('es:addCommand', 'register', function(source, args, user)
	TriggerClientEvent('esx_identity:showRegisterIdentity', source, {})
end)
