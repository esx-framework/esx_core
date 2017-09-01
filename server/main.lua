ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'taxi', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'taxi', 'Client taxi', true, true)

RegisterServerEvent('esx_taxijob:success')
AddEventHandler('esx_taxijob:success', function()

	math.randomseed(os.time())

	local xPlayer        = ESX.GetPlayerFromId(source)
  local total          = math.random(Config.NPCJobEarnings.min, Config.NPCJobEarnings.max);
  local societyAccount = nil

  if xPlayer.job.grade >= 3 then
  	total = total * 2
  end

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_taxi', function(account)
  	societyAccount = account
  end)

  if societyAccount ~= nil then

	  local playerMoney  = math.floor(total / 100 * 30)
	  local societyMoney = math.floor(total / 100 * 70)

	  xPlayer.addMoney(playerMoney)
	  societyAccount.addMoney(societyMoney)

	  TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. playerMoney)
	  TriggerClientEvent('esx:showNotification', xPlayer.source, _U('comp_earned') .. societyMoney)

	else

		xPlayer.addMoney(total)
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_earned') .. total)

	end

end)
