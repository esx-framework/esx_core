# fxserver-esx_drugs
FXserver ESX Drugs

[REQUIREMENTS]

  * esx_policejob => https://github.com/FXServer-ESX/fxserver-esx_policejob


  [UPDATE]
  to install opium :
```
INSERT INTO `items` (name, label) VALUES
	('opium', 'Opium'),
	('opium_pooch', 'Pochon de opium')
;
```
  
  [INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_drugs esx_drugs
```
3) * Import esx_drugs.sql in your database

4) Add this in your server.cfg :

```
start esx_drugs
```

[FEATURES]
* Use weed
* Cops can't see or interact with the drugs zones
* In the config.lua change the Config.RequiredCop to block the drugs zone in function of the cops count conected
