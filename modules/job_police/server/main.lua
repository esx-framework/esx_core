local self = ESX.Modules['job_police']

if self.Config.EnableESXService then
	TriggerEvent('esx_service:activateService', 'police', self.Config.MaxInService)
end

AddEventHandler('onResourceStart', function(resource)

  if resource == 'esx_society' then
    TriggerEvent('esx_society:registerSociety', 'police', 'Police', 'society_police', 'society_police', 'society_police', {type = 'public'})
  elseif resource == 'esx_phone' then
    TriggerEvent('esx_phone:registerNumber', 'police', _U('alert_police'), true, true)
  end

end)
