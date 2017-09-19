# esx_license
FXServer ESX License

[INSTALLATION]

1) Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_license

```

2) Manually

- Download https://github.com/ESX-Org/esx_license/releases/latest
- Put it in [esx] directory


1) Import esx_license.sql in your database
2) Add this in your server.cfg :

```
start esx_license
```
