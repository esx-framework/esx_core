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

### Available triggers (server side)
- `'esx_license:addLicense', function(target, type, cb)`
- `'esx_license:removeLicense', function(target, type, cb)`
- `'esx_license:getLicense', function(source, cb, type)` (callback)
- `'esx_license:getLicenses', function(source, cb, target)` (callback)
- `'esx_license:checkLicense', function(source, cb, target, type)` (callback)
- `'esx_license:getLicensesList', function(source, cb)` (callback)
