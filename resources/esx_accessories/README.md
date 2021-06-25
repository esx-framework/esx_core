<<<<<<< HEAD
# cron
=======
# esx_accessories

Shops with accessories (hat/helmet, glasses, masks, ears accessories). You can put on or take off the accessories with a menu. Accessories saved in database.

/!\ Works only with accessories purchased in the special areas of the clothing store, not via the esx_clotheshop script.

## Requirements
- [esx_skin](https://github.com/ESX-Org/esx_skin)
- [esx_datastore](https://github.com/ESX-Org/esx_datastore)
>>>>>>> esx_accessories/master

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
<<<<<<< HEAD
fvm install --save --folder=esx esx-org/cron
=======
fvm install --save --folder=esx esx-org/esx_accessories
>>>>>>> esx_accessories/master
```

### Using Git
```
cd resources
<<<<<<< HEAD
git clone https://github.com/ESX-Org/cron cron
```

### Manually
- Download https://github.com/ESX-Org/cron/archive/master.zip
- Put it in your resource directory


## Usage
```lua

-- Execute task 5:10, every day
function CronTask(d, h, m)
  print('Task done')
end

TriggerEvent('cron:runAt', 5, 10, CronTask)

-- Execute task every monday at 18:30
function CronTask(d, h, m)
  if d == 1 then
    print('Task done')
  end
end

TriggerEvent('cron:runAt', 18, 30, CronTask)

```

# Legal
### License
cron - do stuff in a specified time

Copyright (C) 2015-2018 Jérémie N'gadi
=======
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
>>>>>>> esx_accessories/master

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
