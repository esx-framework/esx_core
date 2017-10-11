# fxserver-esx_identity
FXServer ESX Identity

[REQUIREMENTS]

* Dependencies For Full Functionality
  * esx_policejob => https://github.com/ESX-Org/esx_policejob
  * esx_society => https://github.com/ESX-Org/esx_society

[INSTALLATION]

1) Install To resources/[esx]/esx_identity
`<< MUST BE INSTALLED HERE`
2) Import esx_identity.sql in your database

3) Add this in your server.cfg :

Notice:
`If you were already using the latest version of esx_identity before the update, you can just import esx_identity_update.sql`

```
start esx_identity
```
4) If you are using esx_policejob or esx_society, you need to enable the following in the files config.lua:
```Config.EnableESXIdentity          = true```

```
Commands:

/identityhelp
/register
/charlist
/charselect 1,2,3
/delchar 1,2,3
```

Credits:
`Script Created By: ArkSeyonet @Ark`

Licensing:
`This script uses GNU GPLv3`

This version is not compatible with ES5, you must use the new version if you are using es5 => https://github.com/ArkSeyonet/esx_identity_es5

