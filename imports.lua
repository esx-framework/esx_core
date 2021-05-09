ESX = exports['es_extended']:getSharedObject()

AddEventHandler('esx:setPlayerData', function(key, val)
	if GetInvokingResource() == 'es_extended' then
		ESX.PlayerData[key] = val
		if OnPlayerData ~= nil then OnPlayerData(key, val) end
	end
end)
