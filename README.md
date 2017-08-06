# fxserver-es_extended [WIP]
FXServer ES Extended

[DISCORD]

https://discord.me/fivem_esx

[REQUIREMENTS]

- essentialmode => https://forum.fivem.net/t/release-essentialmode-base/3665
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

4) Create a resource or add this in an existing resource :

```
server.lua

TriggerEvent('es:setDefaultSettings', {
	nativeMoneySystem = false,
});

```
