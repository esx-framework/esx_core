# esx_addonaccount

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save --folder=esx esx-org/esx_addonaccount
```

### Using Git
```
cd resources
git clone https://github.com/ESX-Org/esx_addonaccount [esx]/esx_addonaccount
```

### Manually
- Download https://github.com/ESX-Org/esx_addonaccount/archive/master.zip
- Put it in the `[esx]` directory

## Installation
- Import `esx_addonaccount.sql` in your database
- Add this in your `server.cfg`:

```
start esx_addonaccount
```

## Usage
There is two types of accounts: shared and not shared.

- Shared accounts doesn't belong to a specific user. Example: society accounts.
- None-shared accounts are created for every user in the server. They are created in db when player is loaded, Example: property black money

### `addon_account` database information
An addon account must be configured in the database before using it. Don't forget to run a server restart afterwards (you can alternative restart the script and relog all clients)

| `name`   | `label` | `shared` |
| -------- | ------- | -------- |
| name of the account | label of the account (not used) | is the account shared with others? (boolean either `0` or `1`) |

```lua
TriggerEvent('esx_addonaccount:getSharedAccount', 'society_realestateagent', function(account)
	account.addMoney(500)
end)

TriggerEvent('esx_addonaccount:getAccount', 'property_black_money', 'steam:0123456789', function(account)
	account.removeMoney(500)
end)
```

# Legal
### License
esx_addonaccount - addon account for ESX

Copyright (C) 2015-2020 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.