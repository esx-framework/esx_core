# fxserver-esx_bankerjob
FXServer ESX BankerJob

[REQUIREMENTS]

- cron => https://github.com/FXServer-ESX/fxserver-cron
- esx_addonaccount => https://github.com/FXServer-ESX/fxserver-esx_addonaccount
- esx_society => https://github.com/FXServer-ESX/fxserver-esx_society

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_bankerjob esx_bankerjob
```
3) Import esx_bankerjob.sql in your database
4) Add this in your server.cfg :

```
start esx_bankerjob
```
