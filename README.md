# es_extended
FXServer ES Extended

## DISCORD

https://discord.me/fivem_esx

## SCREENSHOT

![screenshot](http://i.imgur.com/aPFdJl3.jpg)

## DESCRIPTION

Add support for accounts (bank / black money) you can also add others accounts

Add support for inventory (press F2 ingame) => Players can now remove items from inventory

Add support for jobs

Loadouts are saved in database and restored on spawn

Positions are saved in database and restored on spawn

## Requirements

- **essentialmode** + **es_admin** => https://forum.fivem.net/t/release-essentialmode-base/3665
- **esplugin_mysql** => https://forum.fivem.net/t/release-essentialmode-base/3665/1181
- **mysql-async** => https://github.com/brouznouf/fivem-mysql-async/releases/latest
- **async** => https://github.com/esx-org/async/releases/latest

## Download

**1) Using [fvm](https://github.com/qlaffont/fvm-installer)**

```
fvm install --save --folder=essential esx-org/es_extended
fvm install --save --folder=esx esx-org/esx_menu_default
fvm install --save --folder=esx esx-org/esx_menu_dialog
fvm install --save --folder=esx esx-org/esx_menu_list

```

**2) Manually**

- Download https://github.com/ESX-Org/es_extended/releases/latest
- Put it in resource/[essential] directory
- Download https://github.com/ESX-Org/esx_menu_default/releases/latest
- Put it in resource/[esx] directory
- Download https://github.com/ESX-Org/esx_menu_dialog/releases/latest
- Put it in resource/[esx] directory
- Download https://github.com/ESX-Org/esx_menu_list/releases/latest
- Put it in resource/[esx] directory

**3) Using git**

```
cd resources
git clone https://github.com/ESX-Org/es_extended [essential]/es_extended
git clone https://github.com/ESX-Org/esx_menu_default [esx]/[ui]/esx_menu_default
git clone https://github.com/ESX-Org/esx_menu_dialog [esx]/[ui]/esx_menu_dialog
git clone https://github.com/ESX-Org/esx_menu_list [esx]/[ui]/esx_menu_list
```

## Installation

1) Import es_extended.sql in your database
2) Add this in your server.cfg :

```
start es_extended

start esx_menu_default
start esx_menu_list
start esx_menu_dialog
```
