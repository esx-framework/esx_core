# fxserver-esx_addonaccount
ESX AddonAccount

[INSTALLATION]

1) CD in your resources/[esx] folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-esx_addonaccount esx_addonaccount
```
3) Import esx_addonaccount.sql in your database
4) Add this in your server.cfg :

```
start esx_addonaccount
```

[USAGE]

There is two types of accounts : shared and not shared.

- Shared accounts dont belong to a specific user. Example : society account.
- Not shared accounts are created for every user in the server. They are created in db when player is loaded, Example : property black money

You must create the account in the database (addon_account) before using it :

name = name of the account, label = label of the account, shared (0 or 1) = Is account shared

```
TriggerEvent('esx_addonaccount:getSharedAccount', 'society_realestateagent', function(account)
  account.addMoney(500)
end)

TriggerEvent('esx_addonaccount:getAccount', 'property_black_money', 'steam:0123456789', function(account)
  account.removeMoney(500)
end)
```
