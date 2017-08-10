local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get3DDistance(x1, y1, z1, x2, y2, z2)
	return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2) + math.pow(z1 - z2, 2))
end

RegisterServerEvent('esx_holdup:toofar')
AddEventHandler('esx_holdup:toofar', function(robb)
	local source = source
	local xPlayers = ESX.GetPlayers()
	rob = false
	for k, v in pairs(xPlayers) do
		if v.job.name == 'police' then
			TriggerClientEvent('esx:showNotification', k, '~r~ Braquage annulé à: ~b~' .. Stores[robb].nameofstore)
			TriggerClientEvent('esx_holdup:killblip', k)
		end
	end
	if(robbers[source])then
		TriggerClientEvent('esx_holdup:toofarlocal', source)
		robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, '~r~ Le braquage à été annulé: ~b~' .. Stores[robb].nameofstore)
	end
end)

RegisterServerEvent('esx_holdup:rob')
AddEventHandler('esx_holdup:rob', function(robb)
	
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local xPlayers = ESX.GetPlayers()
	
	if Stores[robb] then
		
		local store = Stores[robb]

		if (os.time() - store.lastrobbed) < 600 and store.lastrobbed ~= 0 then

			
			TriggerClientEvent('esx:showNotification', source, 'Ce magasin a déjà été braqué. Veuillez attendre: ' .. (1800 - (os.time() - store.lastrobbed)) .. "secondes.")
			return
		end

		
		local cops = 0
		for k, v in pairs(xPlayers) do
			if v.job.name == 'police' then
				cops = cops + 1
			end
		end

		
		if rob == false then
			
			if(cops > 1)then
				
				rob = true
				for k, v in pairs(xPlayers) do
					if v.job.name == 'police' then
						TriggerClientEvent('esx:showNotification', k, '~r~ Braquage en cours à: ~b~' .. store.nameofstore)
						TriggerClientEvent('esx_holdup:setblip', k, Stores[robb].position)
					end
				end				
				
				TriggerClientEvent('esx:showNotification', source, 'Vous avez commencé à braquer ' .. store.nameofstore .. ', ne vous éloignez pas!')
				TriggerClientEvent('esx:showNotification', source, 'L\'alarme à été déclenché ')
				TriggerClientEvent('esx:showNotification', source, 'Tenez la position pendant 5min et l\'argent est à vous! ')
				TriggerClientEvent('esx_holdup:currentlyrobbing', source, robb)
				Stores[robb].lastrobbed = os.time()
				robbers[source] = robb
				local savedSource = source
				SetTimeout(300000, function()
					
					if(robbers[savedSource])then
						
						rob = false
						TriggerClientEvent('esx_holdup:robberycomplete', savedSource, job)
						if(xPlayer)then 
							
							xPlayer.addAccountMoney('black_money', store.reward)
							TriggerClientEvent('esx:showNotification', source, '~r~ Braquage terminé.~s~ ~h~ Fuie!')
							for k, v in pairs(xPlayers) do
								if v.job.name == 'police' then
									TriggerClientEvent('esx:showNotification', k, '~r~ Braquage terminé à: ~b~' .. store.nameofstore)
									TriggerClientEvent('esx_holdup:killblip', k)
								end
							end
							
						end
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', source, 'Il faut minimum ~b~2 policiers~s~ en ville pour braquer.')
			end
		else
			TriggerClientEvent('esx:showNotification', source, '~r~Un braquage est déjà en cours.')				
		end
	end
end)