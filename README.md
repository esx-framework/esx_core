# esx_joblisting
Simple job listing script, you can specify what jobs you want to be whitelisted.

### Update
If you have an outdated version of ES Extended, you might need to run the following on your SQL server:

`ALTER TABLE jobs add whitelisted BOOLEAN NOT NULL DEFAULT FALSE;`

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_joblisting
```

### Using Git
```
cd resources
git clone https://github.com/ESX-Org/esx_joblisting [esx]/esx_joblisting
```

### Manually
- Download https://github.com/ESX-Org/esx_joblisting/archive/master.zip
- Put it in the `[esx]` directory

- Add this in your `server.cfg`:

```
start esx_joblisting
```

# Legal
### License
esx_joblisting - job listing script

Copyright (C) 2015-2018 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
