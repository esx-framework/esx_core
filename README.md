# fxserver-esx_service
FXServer ESX Service

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_service esx_service
```
3) Add this in your server.cfg :

```
start esx_service
```

[USAGE]
```
-- Enable service
ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)

  if canTakeService then
    ESX.ShowNotification('Vous avez pris votre service')
  else
    ESX.ShowNotification('Service complet : ' .. inServiceCount .. '/' .. maxInService)
  end

end, 'taxi')

-- Disable service
TriggerServerEvent('esx_service:disableService', 'taxi')
```
