# fxserver-esx_billing
FXServer ESX Billing

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_billing esx_billing
```
3) Import esx_billing.sql in your database
4) Add this in your server.cfg :

```
start esx_billing
```

[USAGE]

Press [F7] To show billing menu

```
local amount                         = 100
local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

if closestPlayer == -1 or closestDistance > 3.0 then
  ESX.ShowNotification('Aucun joueur à proximité')
else
  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'Taxi', amount)
end
```
