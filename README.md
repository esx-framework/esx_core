# esx_license

## Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_license
```

### Manually

- Download https://github.com/ESX-Org/esx_license/releases/latest
- Put it in [esx] directory


1) Import `esx_license.sql` in your database
2) Add this in your `server.cfg`:

```
start esx_license
```
