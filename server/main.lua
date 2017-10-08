ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetProperty(name)

  for i=1, #Config.Properties, 1 do
    if Config.Properties[i].name == name then
      return Config.Properties[i]
    end
  end

end

function SetPropertyOwned(name, price, rented, owner)

  MySQL.Async.execute(
    'INSERT INTO owned_properties (name, price, rented, owner) VALUES (@name, @price, @rented, @owner)',
    {
      ['@name']   = name,
      ['@price']  = price,
      ['@rented'] = (rented and 1 or 0),
      ['@owner']  = owner
    },
    function(rowsChanged)

      local xPlayers = ESX.GetPlayers()

      for i=1, #xPlayers, 1 do

        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

        if xPlayer.identifier == owner then

          TriggerClientEvent('esx_property:setPropertyOwned', xPlayer.source, name, true)

          if rented then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('rented_for') .. price)
          else
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('purchased_for') .. price)
          end

          break
        end
      end

    end
  )

end

function RemoveOwnedProperty(name, owner)

  MySQL.Async.execute(
    'DELETE FROM owned_properties WHERE name = @name AND owner = @owner',
    {
      ['@name']  = name,
      ['@owner'] = owner
    },
    function(rowsChanged)

      local xPlayers = ESX.GetPlayers()

      for i=1, #xPlayers, 1 do

        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

        if xPlayer.identifier == owner then
          TriggerClientEvent('esx_property:setPropertyOwned', xPlayer.source, name, false)
          TriggerClientEvent('esx:showNotification', xPlayer.source, _U('made_property'))
          break
        end
      end

    end
  )

end

AddEventHandler('onMySQLReady', function ()

  MySQL.Async.fetchAll('SELECT * FROM properties', {}, function(properties)

    for i=1, #properties, 1 do

      local entering  = nil
      local exit      = nil
      local inside    = nil
      local outside   = nil
      local isSingle  = nil
      local isRoom    = nil
      local isGateway = nil
      local roomMenu  = nil

      if properties[i].entering ~= nil then
        entering = json.decode(properties[i].entering)
      end

      if properties[i].exit ~= nil then
        exit = json.decode(properties[i].exit)
      end

      if properties[i].inside ~= nil then
        inside = json.decode(properties[i].inside)
      end

      if properties[i].outside ~= nil then
        outside = json.decode(properties[i].outside)
      end

      if properties[i].is_single == 0 then
        isSingle = false
      else
        isSingle = true
      end

      if properties[i].is_room == 0 then
        isRoom = false
      else
        isRoom = true
      end

      if properties[i].is_gateway == 0 then
        isGateway = false
      else
        isGateway = true
      end

      if properties[i].room_menu ~= nil then
        roomMenu = json.decode(properties[i].room_menu)
      end

      table.insert(Config.Properties, {
        name      = properties[i].name,
        label     = properties[i].label,
        entering  = entering,
        exit      = exit,
        inside    = inside,
        outside   = outside,
        ipls      = json.decode(properties[i].ipls),
        gateway   = properties[i].gateway,
        isSingle  = isSingle,
        isRoom    = isRoom,
        isGateway = isGateway,
        roomMenu  = roomMenu,
        price     = properties[i].price
      })

    end

  end)

end)

AddEventHandler('esx_ownedproperty:getOwnedProperties', function(cb)

  MySQL.Async.fetchAll(
    'SELECT * FROM owned_properties',
    {},
    function(result)

      local properties = {}

      for i=1, #result, 1 do

        table.insert(properties, {
          id     = result[i].id,
          name   = result[i].name,
          price  = result[i].price,
          rented = (rented == 1 and true or false),
          owner  = result[i].owner,
        })
      end

      cb(properties)

    end
  )

end)

AddEventHandler('esx_property:setPropertyOwned', function(name, price, rented, owner)
  SetPropertyOwned(name, price, rented, owner)
end)

AddEventHandler('esx_property:removeOwnedProperty', function(name, owner)
  RemoveOwnedProperty(name, owner)
end)

RegisterServerEvent('esx_property:rentProperty')
AddEventHandler('esx_property:rentProperty', function(propertyName)

  local xPlayer  = ESX.GetPlayerFromId(source)
  local property = GetProperty(propertyName)

  SetPropertyOwned(propertyName, property.price / 200, true, xPlayer.identifier)

end)

RegisterServerEvent('esx_property:buyProperty')
AddEventHandler('esx_property:buyProperty', function(propertyName)

  local xPlayer  = ESX.GetPlayerFromId(source)
  local property = GetProperty(propertyName)

  if property.price <= xPlayer.get('money') then

    xPlayer.removeMoney(property.price)
    SetPropertyOwned(propertyName, property.price, false, xPlayer.identifier)

  else
    TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
  end

end)

RegisterServerEvent('esx_property:removeOwnedProperty')
AddEventHandler('esx_property:removeOwnedProperty', function(propertyName)

  local xPlayer = ESX.GetPlayerFromId(source)

  RemoveOwnedProperty(propertyName, xPlayer.identifier)

end)

AddEventHandler('esx_property:removeOwnedPropertyIdentifier', function(propertyName, identifier)
  RemoveOwnedProperty(propertyName, identifier)
end)

RegisterServerEvent('esx_property:saveLastProperty')
AddEventHandler('esx_property:saveLastProperty', function(property)

  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.execute(
    'UPDATE users SET last_property = @last_property WHERE identifier = @identifier',
    {
      ['@last_property'] = property,
      ['@identifier']    = xPlayer.identifier
    }
  )

end)

RegisterServerEvent('esx_property:deleteLastProperty')
AddEventHandler('esx_property:deleteLastProperty', function()
  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.execute(
    'UPDATE users SET last_property = NULL WHERE identifier = @identifier',
    {
      ['@identifier']    = xPlayer.identifier
    }
  )
end)

RegisterServerEvent('esx_property:getItem')
AddEventHandler('esx_property:getItem', function(owner, type, item, count)

  local _source      = source
  local xPlayer      = ESX.GetPlayerFromId(_source)
  local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

  if type == 'item_standard' then

    TriggerEvent('esx_addoninventory:getInventory', 'property', xPlayerOwner.identifier, function(inventory)

      local roomItemCount = inventory.getItem(item).count

      if roomItemCount >= count then
        inventory.removeItem(item, count)
        xPlayer.addInventoryItem(item, count)
      else
        TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
      end

    end)

  end

  if type == 'item_account' then

    TriggerEvent('esx_addonaccount:getAccount', 'property_' .. item, xPlayerOwner.identifier, function(account)

      local roomAccountMoney = account.money

      if roomAccountMoney >= count then
        account.removeMoney(count)
        xPlayer.addAccountMoney(item, count)
      else
        TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
      end

    end)

  end

  if type == 'item_weapon' then

    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayerOwner.identifier, function(store)

      local storeWeapons = store.get('weapons')

      if storeWeapons == nil then
        storeWeapons = {}
      end

      local weaponName   = nil
      local ammo         = nil

      for i=1, #storeWeapons, 1 do
        if storeWeapons[i].name == item then

          weaponName = storeWeapons[i].name
          ammo       = storeWeapons[i].ammo

          table.remove(storeWeapons, i)

          break
        end
      end

      store.set('weapons', storeWeapons)

      xPlayer.addWeapon(weaponName, ammo)

    end)

  end

end)

RegisterServerEvent('esx_property:putItem')
AddEventHandler('esx_property:putItem', function(owner, type, item, count)

  local _source      = source
  local xPlayer      = ESX.GetPlayerFromId(_source)
  local xPlayerOwner = ESX.GetPlayerFromIdentifier(owner)

  if type == 'item_standard' then

    local playerItemCount = xPlayer.getInventoryItem(item).count

    if playerItemCount >= count then

      xPlayer.removeInventoryItem(item, count)

      TriggerEvent('esx_addoninventory:getInventory', 'property', xPlayerOwner.identifier, function(inventory)
        inventory.addItem(item, count)
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, _U('invalid_quantity'))
    end

  end

  if type == 'item_account' then

    local playerAccountMoney = xPlayer.getAccount(item).money

    if playerAccountMoney >= count then

      xPlayer.removeAccountMoney(item, count)

      TriggerEvent('esx_addonaccount:getAccount', 'property_' .. item, xPlayerOwner.identifier, function(account)
        account.addMoney(count)
      end)

    else
      TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
    end

  end

  if type == 'item_weapon' then

    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayerOwner.identifier, function(store)

      local storeWeapons = store.get('weapons')

      if storeWeapons == nil then
        storeWeapons = {}
      end

      table.insert(storeWeapons, {
        name = item,
        ammo = count
      })

      store.set('weapons', storeWeapons)

      xPlayer.removeWeapon(item)

    end)

  end

end)

ESX.RegisterServerCallback('esx_property:getProperties', function(source, cb)
  cb(Config.Properties)
end)

ESX.RegisterServerCallback('esx_property:getOwnedProperties', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll(
    'SELECT * FROM owned_properties WHERE owner = @owner',
    {
      ['@owner'] = xPlayer.identifier
    },
    function(ownedProperties)

      local properties = {}

      for i=1, #ownedProperties, 1 do
        table.insert(properties, ownedProperties[i].name)
      end

      cb(properties)
    end
  )

end)

ESX.RegisterServerCallback('esx_property:getLastProperty', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll(
    'SELECT * FROM users WHERE identifier = @identifier',
    {
      ['@identifier'] = xPlayer.identifier
    },
    function(users)
      cb(users[1].last_property)
    end
  )

end)

ESX.RegisterServerCallback('esx_property:getPropertyInventory', function(source, cb, owner)

  local xPlayer    = ESX.GetPlayerFromIdentifier(owner)
  local blackMoney = 0
  local items      = {}
  local weapons    = {}

  TriggerEvent('esx_addonaccount:getAccount', 'property_black_money', xPlayer.identifier, function(account)
    blackMoney = account.money
  end)

  TriggerEvent('esx_addoninventory:getInventory', 'property', xPlayer.identifier, function(inventory)
    items = inventory.items
  end)

  TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)

    local storeWeapons = store.get('weapons')

    if storeWeapons ~= nil then
      weapons = storeWeapons
    end

  end)

  cb({
    blackMoney = blackMoney,
    items      = items,
    weapons    = weapons
  })

end)

ESX.RegisterServerCallback('esx_property:getPlayerInventory', function(source, cb)

  local xPlayer    = ESX.GetPlayerFromId(source)
  local blackMoney = xPlayer.getAccount('black_money').money
  local items      = xPlayer.inventory

  cb({
    blackMoney = blackMoney,
    items      = items
  })

end)

ESX.RegisterServerCallback('esx_property:getPlayerDressing', function(source, cb)

  local xPlayer  = ESX.GetPlayerFromId(source)
  local dressing = {}

  TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)

    local storeDressing = store.get('dressing')

    if storeDressing ~= nil then
      dressing = storeDressing
    end

  end)

  cb(dressing)

end)

function PayRent(d, h, m)

  MySQL.Async.fetchAll(
    'SELECT * FROM users',
    {},
    function(_users)

      local prevMoney = {}
      local newMoney  = {}

      for i=1, #_users, 1 do
        prevMoney[_users[i].identifier] = _users[i].money
        newMoney[_users[i].identifier]  = _users[i].money
      end

      MySQL.Async.fetchAll(
        'SELECT * FROM owned_properties WHERE rented = 1',
        {},
        function(result)

          local xPlayers = ESX.GetPlayers()

          for i=1, #result, 1 do

            local foundPlayer = false
            local xPlayer     = nil

            for j=1, #xPlayers, 1 do

              local xPlayer2 = ESX.GetPlayerFromId(xPlayers[j])

              if xPlayer2.identifier == result[i].owner then
                foundPlayer = true
                xPlayer     = xPlayer2
              end
            end

            if foundPlayer then

              xPlayer.removeMoney(result[i].price)
              TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_rent') .. result[i].price)

            else
              newMoney[result[i].owner] = newMoney[result[i].owner] - result[i].price
            end

            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_realestateagent', function(account)
              account.addMoney(result[i].price)
            end)

          end

          for k,v in pairs(prevMoney) do
            if v ~= newMoney[k] then

              MySQL.Async.execute(
                'UPDATE users SET money = @money WHERE identifier = @identifier',
                {
                  ['@money']      = newMoney[k],
                  ['@identifier'] = k
                }
              )

            end
          end

        end
      )

    end
  )

end

TriggerEvent('cron:runAt', 22, 0, PayRent)
