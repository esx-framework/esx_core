local rob = false
local robbers = {}

RegisterServerEvent('esx_holdup:tooFar')
AddEventHandler('esx_holdup:tooFar', function(currentStore)
	local source = source
	rob = false
	for _, xPlayer in pairs(ESX.GetExtendedPlayers('job', 'police')) do
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('robbery_cancelled_at', Stores[currentStore].nameOfStore))
		TriggerClientEvent('esx_holdup:killBlip', xPlayer.source)
	end
	if robbers[source] then
		TriggerClientEvent('esx_holdup:tooFar', source)
		ESX.ClearTimeout(robbers[source])
        robbers[source] = nil
		TriggerClientEvent('esx:showNotification', source, _U('robbery_cancelled_at', Stores[currentStore].nameOfStore))
	end
end)

RegisterServerEvent('esx_holdup:robberyStarted')
AddEventHandler('esx_holdup:robberyStarted', function(currentStore)
	local source  = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	if Stores[currentStore] then
		local store = Stores[currentStore]
		if (os.time() - store.lastRobbed) < Config.TimerBeforeNewRob and store.lastRobbed ~= 0 then
			TriggerClientEvent('esx:showNotification', source, _U('recently_robbed', Config.TimerBeforeNewRob - (os.time() - store.lastRobbed)))
			return
		end
		if not rob then
			local xPlayers = ESX.GetExtendedPlayers('job', 'police')
			if #xPlayers >= Config.PoliceNumberRequired then
				rob = true
				for i=1, #(xPlayers) do 
					local xPlayer = xPlayers[i]
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('rob_in_prog', store.nameOfStore))
					TriggerClientEvent('esx_holdup:setBlip', xPlayer.source, Stores[currentStore].position)
				end
				TriggerClientEvent('esx:showNotification', source, _U('started_to_rob', store.nameOfStore))
				TriggerClientEvent('esx:showNotification', source, _U('alarm_triggered'))
				TriggerClientEvent('esx_holdup:currentlyRobbing', source, currentStore)
				TriggerClientEvent('esx_holdup:startTimer', source)
				Stores[currentStore].lastRobbed = os.time()
				robbers[source] = ESX.SetTimeout(store.secondsRemaining * 1000, function()
					rob = false
                    if xPlayer then
                        TriggerClientEvent('esx_holdup:robberyComplete', source, store.reward)
                        if Config.GiveBlackMoney then
                            xPlayer.addAccountMoney('black_money', store.reward)
                        else
                            xPlayer.addMoney(store.reward)
                        end
                        local xPlayers = ESX.GetExtendedPlayers('job', 'police')
												for i=1, #(xPlayers) do 
													local xPlayer = xPlayers[i]
                            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('robbery_complete_at', store.nameOfStore))
                            TriggerClientEvent('esx_holdup:killBlip', xPlayer.source)
                        end
                    end
				end)
			else
				TriggerClientEvent('esx:showNotification', source, _U('min_police', Config.PoliceNumberRequired))
			end
		else
			TriggerClientEvent('esx:showNotification', source, _U('robbery_already'))
		end
	end
end)
