# fxserver-esx_identity
FXServer ESX Identity

[REQUIREMENTS]

* Dependencies For Full Functionality
  * esx_policejob => https://github.com/FXServer-ESX/fxserver-esx_policejob

[INSTALLATION]

1) Install To resources/esx_identity
`<< MUST BE INSTALLED HERE`
2) Import esx_identity.sql in your database

3) Add this in your server.cfg :

```
start esx_identity
```
4) If you are using esx_policejob, you need to change Config.EnableESXIdentity = true in esx_policejob/config.lua
```Config.EnableESXIdentity          = true```

Credits:
`Script Created By: ArkSeyonet @Ark`

Licensing:
`This script uses GNU GPLv3`

