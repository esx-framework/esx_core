<h1 align='center'>[ESX] Banking</a></h1><p align='center'><b><a href='https://discord.esx-framework.org/'>Discord</a> - <a href='https://esx-framework.org/'>Website</a> - <a href='https://docs.esx-framework.org/legacy/installation'>Documentation</a></b></h5>

A beautiful and Easy-To-Use Banking & ATM system for ESX, with optional OX Target Support


## BANK UI
![esx_banking_pic1](https://user-images.githubusercontent.com/22717950/189738189-375101ac-c86b-4ce8-8df3-19d740c3809c.png)
## ATM UI
![esx_banking_pic2](https://user-images.githubusercontent.com/22717950/189738199-a325092b-5f1d-4c7f-8950-d660d053ed0f.png)
![esx_banking_pic3](https://user-images.githubusercontent.com/22717950/189738210-7af2c7d5-7fa1-4f70-8460-743ee9258f88.png)


## Special thanks: Gellipapa#9186,Rav3n95#2849,Csoki, csontvazharcos, Füsti, Pécé

## Download & Installation

- Download https://github.com/esx-framework/esx-legacy/tree/main/%5Besx_addons%5D/esx_banking
- Put it in the `[esx-addons]` directory

## Installation
- Add this to your `server.cfg`:

```
ensure esx_banking
```

# Database
```
Run the banking.sql into your database. Done.
```

# If you want to create a bank log in another script, you can do it this way! Only server side!
```
exports["esx_banking"]:logTransaction(source,logType,amount)

- First param: source - player source
- Second param: logType - WITHDRAW,DEPOSIT,TRANSFER_RECEIVE  you can only use these log types!
- Third param: amount - The amount to be logged

For example: exports["esx_banking"]:logTransaction(source,"WITHDRAW",200)
```

# Legal
### License
esx_banking - banking script for ESX

Copyright (C) 2022 ESX-Framework

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
