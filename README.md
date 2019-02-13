# esx_accessories

Shops with accessories (hat/helmet, glasses, masks, ears accessories). You can put on or take off the accessories with a menu. Accessories saved in database.

/!\ Works only with accessories purchased in the special areas of the clothing store, not via the esx_clotheshop script.

## Requirements
- [esx_skin](https://github.com/ESX-Org/esx_skin)
- [esx_datastore](https://github.com/ESX-Org/esx_datastore)

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_accessories
```

### Using Git
```
cd resources
git clone https://github.com/ESX-Org/esx_accessories [esx]/esx_accessories
```

### Manually
- Download https://github.com/ESX-Org/esx_accessories/archive/master.zip
- Put it in the `[esx]` directory

## Installation
- Import `esx_accessories.sql` in your database
- Add this in your `server.cfg`:

```
start esx_accessories
```

# Legal
### License
esx_accessories - buy some shiny stuff!

Copyright (C) 2015-2018 Lenaic Corbeau

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
