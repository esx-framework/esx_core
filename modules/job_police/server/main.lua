local self = ESX.Modules['job_police']

if self.Config.EnableESXService then
	TriggerEvent('esx_service:activateService', 'police', self.Config.MaxInService)
end

TriggerEvent('esx_society:registerSociety', 'police', 'Police', 'society_police', 'society_police', 'society_police', {type = 'public'})
TriggerEvent('esx_phone:registerNumber', 'police', _U('alert_police'), true, true)
