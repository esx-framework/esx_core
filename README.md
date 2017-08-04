# fxserver-esx_garage
FXServer ESX Garage

[REQUIREMENTS]

- instance => https://github.com/FXServer-ESX/fxserver-instance

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_garage esx_garage
```
3) Import esx_garage.sql in your database
4) Add this in your server.cfg :

```
start esx_garage
```
