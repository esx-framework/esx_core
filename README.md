# fxserver-esx_realestateagentjob
FXServer ESX RealestateAgent Job

[REQUIREMENTS]

- esx_property => https://github.com/FXServer-ESX/fxserver-esx_property

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_realestateagentjob esx_realestateagentjob
```
3) Add this in your server.cfg :

```
start esx_realestateagentjob
```
4) Set Config.EnablePlayerManagement to true in esx_property/config.lua
