# fxserver-esx_mecanojob

FXServer ESX Mecano Job

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
git clone https://github.com/FXServer-ESX/fxserver-esx_mecanojob esx_mecanojob
```
3) Import esx_mecanojob.sql in your database

4) Add this in your server.cfg :

```
start esx_mecanojob
```
5) If you want player management you have to set Config.EnablePlayerManagement to true in config.lua

[KNOWN BUGS]

* Props spawn don't work at all
