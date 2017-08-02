# fxserver-esx_society
FXServer ESX Society

[REQUIREMENTS]

- cron => https://github.com/FXServer-ESX/fxserver-cron
- esx_addonaccount => https://github.com/FXServer-ESX/fxserver-esx_addonaccount

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_society esx_society
```
3) Import esx_society.sql in your database
4) Add this in your server.cfg :

```
start esx_society
```
[EXPLANATION]

ESX Society works with addon accounts named 'society_xxx' like 'society_taxi' or 'society_realestateagent'.
If you job grade is 'boss', you will see the society_xxx money of your job showed in the HUD.

[USAGE]
```
local society = 'taxi'
local amount  = 100

TriggerServerEvent('esx_society:withdrawMoney', society, amount)
TriggerServerEvent('esx_society:depositMoney', society, amount)
TriggerServerEvent('esx_society:washMoney', society, amount)
```
