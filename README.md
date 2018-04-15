# esx_identity

### Important message
This version is not compatible with ES5, use [esx_identity_es5](https://github.com/ArkSeyonet/esx_identity_es5)

[REQUIREMENTS]

* Dependencies For Full Functionality
  * [esx_policejob](https://github.com/ESX-Org/esx_policejob)
  * [esx_society](https://github.com/ESX-Org/esx_society)

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

### License
This script is licensed under GPLv3, see the [license](license.txt)
