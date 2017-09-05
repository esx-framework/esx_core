# fxserver-esx_property
FXServer ESX Property

[REQUIREMENTS]

- instance => https://github.com/FXServer-ESX/fxserver-instance
- cron => https://github.com/FXServer-ESX/fxserver-cron
- esx_addonaccount => https://github.com/FXServer-ESX/fxserver-esx_addonaccount
- esx_addoninventory => https://github.com/FXServer-ESX/fxserver-esx_addoninventory
- esx_datastore => https://github.com/FXServer-ESX/fxserver-esx_datastore

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_property esx_property
```
3) Import esx_property.sql in your database
4) Import esx_offices.sql in your database if you want the offices to added in your server(The Arcadius Business Centre is not included because realstateagentjob)
5) Add this in your server.cfg :

```
start esx_property
```
