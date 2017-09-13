--==================================================================================
--======		           ESX_IDENTITY BY ARKSEYONET @Ark                    ======
--======    YOU CAN FIND ME ON MY DISCORD @Ark - https://discord.gg/cGHHxPX   ======
--======    IF YOU ALTER THIS VERSION OF THE SCRIPT, PLEASE GIVE ME CREDIT    ======
--======            Special Thanks To COSHAREK FOR THE UI Design              ======
--======     Special Thanks To Alphakush and CMD.Telhada For Help Testing     ======
--==================================================================================

--===============================================
--==     Get The Player's Identification       ==
--===============================================
function getIdentity(source)
    local identifier = GetPlayerIdentifiers(source)[1]
    local result = MySQL.Sync.fetchAll("SELECT * FROM characters WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    })
	if result[1] ~= nil then
		local identity = result[1]
	
		return {
			firstname 		= identity['firstname'],
			lastname		= identity['lastname'],
			dateofbirth		= identity['dateofbirth'],
			sex			= identity['sex'],
			height			= identity['height']
		}
	else
		return {
			firstname 	= '',
			lastname	= '',
			dateofbirth	= '',
			sex		= '',
			height		= ''
		}	
    end
end

--===============================================
--==    Create The Player's Identification     ==
--===============================================
function createIdentity(identifier, data)
	MySQL.Sync.execute(
		'INSERT INTO characters (identifier, firstname, lastname, dateofbirth, sex, height) VALUES (@identifier, @firstname, @lastname, @dateofbirth, @sex, @height)',
		{
			['@identifier'] 	= identifier,
			['@firstname']  	= data.firstname,
			['@lastname'] 		= data.lastname,
			['@dateofbirth'] 	= data.dateofbirth,
			['@sex']		= data.sex,
			['@height'] 		= data.height
		})
end

--===============================================
--==       Server Event Create Identity        ==
--===============================================
RegisterServerEvent('esx_identity:createIdentity')
AddEventHandler('esx_identity:createIdentity', function(data)
    createIdentity(GetPlayerIdentifiers(source)[1], data)
end)

--===============================================
--==       Player Loaded Event Handler         ==
--===============================================
AddEventHandler('es:playerLoaded', function(source)
	local result = getIdentity(source)
	if result.firstname == '' then
		Wait(500)
        	TriggerClientEvent('esx_identity:showRegisterIdentity', source)
    	else
		print('Player Has An Identity. Continuing.')
    	end
end)
