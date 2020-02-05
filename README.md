# esx_billing

This resource for ESX adds possibility for different jobs to send bills to players, for example making police units able to give people fines. It comes with a menu for paying bills, to open the menu the default keybind is `F7`.

There is a developer server event available in order to register bills in the database, see default resources for examples.

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_billing
```

### Using Git
```
cd resources
git clone https://github.com/ESX-Org/esx_billing [esx]/esx_billing
```

### Manually
- Download https://github.com/ESX-Org/esx_billing/archive/master.zip
- Put it in the `[esx]` directory


## Installation
- Import `esx_billing.sql` in your database
- Add this to your `server.cfg`:

```
start esx_billing
```

## Usage
Press `[F7]` To show the billing menu

```lua
local amount                         = 100
local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

if closestPlayer == -1 or closestDistance > 3.0 then
	ESX.ShowNotification('There\'s no players nearby!')
else
	TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'Taxi', amount)
end
```

# Legal
### License
esx_billing - billing for ESX

Copyright (C) 2015-2020 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.