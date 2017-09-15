# es_extended
FXServer ES Extended

[DISCORD]

https://discord.me/fivem_esx

[SCREENSHOT]

![screenshot](http://i.imgur.com/aPFdJl3.jpg)

[DESCRIPTION]

Add support for accounts (bank / black money) you can also add others accounts

Add support for inventory (press F2 ingame) => Players can now remove items from inventory

Add support for jobs

Loadouts are saved in database and restored on spawn

Positions are saved in database and restored on spawn

[REQUIREMENTS]

- essentialmode + es_admin => https://forum.fivem.net/t/release-essentialmode-base/3665
- esplugin_mysql => https://forum.fivem.net/t/release-essentialmode-base/3665/1181

[INSTALLATION]

```
cd in your ressources directory
git clone https://github.com/ESX-Org/es_extended [esssential]/es_extended
git clone https://github.com/ESX-Org/esx_menu-core [esx]/[ui]/esx_menu-core
git clone https://github.com/ESX-Org/esx_menu-list [esx]/[ui]/esx_menu-list
git clone https://github.com/ESX-Org/esx_menu-dialog [esx]/[ui]/esx_menu-dialog

```

1) Import es_extended.sql in your database
2) Add this in your server.cfg :

```
start es_extended

start esx_menu-core
start esx_menu-list
start esx_menu-dialog
```

