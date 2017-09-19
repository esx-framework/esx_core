# esx_dmvschool
FXServer ESX DMV SChool

[INSTALLATION]

1) Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_dmvschool
```

2) Manually

- Download https://github.com/ESX-Org/esx_dmvschool/releases/latest
- Put it in [esx] directory


1) Import esx_dmvschool.sql in your database
2) Add this in your server.cfg :

```
start esx_dmvschool
```
