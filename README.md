# fxserver-es_extended [WIP]
FXServer ES Extended

[UPDATE]

Since commit : https://github.com/FXServer-ESX/fxserver-es_extended/commit/ec1e8c0852b7461472dc9c332464ad55c81682e7 you have to add this SQL if you have already installed es_extended :
```sql
ALTER TABLE `items`
	ADD COLUMN `rare` int(11) NOT NULL DEFAULT '0',
	ADD COLUMN `can_remove` int(11) NOT NULL DEFAULT '1'
;
```

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
git clone https://github.com/FXServer-ESX/fxserver-es_extended
cd fxserver-es_extended
git submodule init
git submodule update --recursive
```

1) Copy all folders inside resources to your server resources folder
2) Import es_extended.sql in your database
3) Add this in your server.cfg :

```
start es_extended

start esx_menu_default
start esx_menu_list
start esx_menu_dialog
```

