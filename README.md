# fxserver-esx_vehicleshop
FXServer ESX Vehicle Shop

[REQUIREMENTS]

* Auto mode
  * No need to download another resource

* Player management (billing and boss actions)
  * esx_society => https://github.com/FXServer-ESX/fxserver-esx_society
  * esx_billing => https://github.com/FXServer-ESX/fxserver-esx_billing

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_vehicleshop esx_vehicleshop
```
3) Import esx_vehicleshop.sql in your database

4) Add this in your server.cfg :

```
start esx_vehicleshop
```
5) If you want player management you have to set Config.EnablePlayerManagement to true in config.lua
