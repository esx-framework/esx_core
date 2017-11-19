# fxserver-esx_accessories
FXServer ESX Accessories

[REQUIREMENTS]

- esx_skin => https://github.com/FXServer-ESX/fxserver-esx_skin
- esx_datastore => https://github.com/FXServer-ESX/fxserver-esx_datastore

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_accessories esx_accessories
```
3) Import esx_accessories.sql in your database
4) Add this in your server.cfg :

```
start baseevents
start esx_accessories
```
