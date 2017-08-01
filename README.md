# fxserver-es_extended [WIP]
FXServer ES Extended

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