ESX.Modules['society'] = {}
local self = ESX.Modules['society']

self.Config = ESX.EvalFile(GetCurrentResourceName(), 'modules/society/data/config.lua', {
  vector3 = vector3
})['Config']

self.Jobs = {}
self.RegisteredSocieties = {}

self.Init = function()

  local translations = ESX.EvalFile(GetCurrentResourceName(), 'modules/society/data/locales/' .. Config.Locale .. '.lua')['Translations']
  LoadLocale('society', Config.Locale, translations)

end

self.GetSociety = function(name)
	for i=1, #self.RegisteredSocieties, 1 do
		if self.RegisteredSocieties[i].name == name then
			return self.RegisteredSocieties[i]
		end
	end
end

self.isPlayerBoss = function(playerId, job)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer.job.name == job and xPlayer.job.grade_name == 'boss' then
		return true
	else
		print(('esx_society: %s attempted open a society boss menu!'):format(xPlayer.identifier))
		return false
	end
end

self.WashMoneyCRON = function(d, h, m)
	MySQL.Async.fetchAll('SELECT * FROM society_moneywash', {}, function(result)
		for i=1, #result, 1 do
			local society = self.GetSociety(result[i].society)
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)

			-- add society money
			TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
				account.addMoney(result[i].amount)
			end)

			-- send notification if player is online
			if xPlayer then
				xPlayer.showNotification(_U('society:you_have_laundered', ESX.Math.GroupDigits(result[i].amount)))
			end

			MySQL.Async.execute('DELETE FROM society_moneywash WHERE id = @id', {
				['@id'] = result[i].id
			})
		end
	end)
end


