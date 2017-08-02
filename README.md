# fxserver-esx_realestateagentjob
FXServer ESX RealestateAgent Job

[REQUIREMENTS]

- esx_addonaccount => https://github.com/FXServer-ESX/fxserver-esx_society
- esx_property => https://github.com/FXServer-ESX/fxserver-esx_property
- (optionnal) esx_society => https://github.com/FXServer-ESX/fxserver-esx_society

If you add esx_society you will see the realestateagent account money in the HUD if your grade is 'boss'

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_realestateagentjob esx_realestateagentjob
```
3) Import esx_realestateagentjob.sql in your database
4) Add this in your server.cfg :

```
start esx_realestateagentjob
```
5) Set Config.EnablePlayerManagement to true in esx_property/config.lua
