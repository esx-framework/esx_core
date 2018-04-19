# esx_identity

[REQUIREMENTS]

* Dependencies For Full Functionality
  * [esx_skin](https://github.com/ESX-Org/esx_skin)
  * [esx_policejob](https://github.com/ESX-Org/esx_policejob)
  * [esx_society](https://github.com/ESX-Org/esx_society)

[INSTALLATION]

1) Install To resources/[esx]/esx_identity
`<< MUST BE INSTALLED HERE`
2) Import esx_identity.sql in your database

3) Add this in your server.cfg :

```
start esx_identity
```

4) If you are using esx_policejob or esx_society, you need to enable the following in the files config.lua:
```Config.EnableESXIdentity          = true```

### Commands
```
/register
/charlist
/charselect
/chardel
```

### License
This script is licensed under GPLv3, see the [license](LICENSE)
