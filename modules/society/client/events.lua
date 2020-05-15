local self = ESX.Modules['society']

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		self.UpdateSocietyMoneyHUDElement(money)
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	self.RefreshBossHUD()
end)

AddEventHandler('esx_society:openBossMenu', function(society, close, options)
	self.OpenBossMenu(society, close, options)
end)
