# fxserver-esx_ambulancejob
FXServer ESX Ambulance Job

[REQUIREMENTS]

* Auto mode
   - esx_skin => https://github.com/FXServer-ESX/fxserver-esx_skin
  
* Player management (boss actions **There is no way to earn money for now**)
  * esx_society => https://github.com/FXServer-ESX/fxserver-esx_society

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_ambulancejob esx_ambulancejob
```
3) Import esx_ambulancejob.sql in your database

4) Add this in your server.cfg :

```
start baseevents
start esx_ambulancejob
```
5) * If you want player management you have to set Config.EnablePlayerManagement to true in config.lua

