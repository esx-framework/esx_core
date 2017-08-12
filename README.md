# fxserver-esx_basicneeds
FXServer ESX Basic Needs

[REQUIREMENTS]

- esx_status => https://github.com/FXServer-ESX/fxserver-esx_status

[INFO]

This plugin add hunger and thirst status, they can be increased when eating bread or drinking water

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_basicneeds esx_basicneeds
```
3) Import esx_basicneeds.sql in your database
4) Add this in your server.cfg :

```
start esx_basicneeds
```
