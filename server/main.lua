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
					rented = (result[i].rented == 1 and true or false),
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
		local sourceItem = xPlayer.getInventoryItem(item)
		
		TriggerEvent('esx_addoninventory:getInventory', 'property', xPlayerOwner.identifier, function(inventory)
			local inventoryItem = inventory.getItem(item)
			
			-- is there enough in the property?
			if count > 0 and inventoryItem.count >= count then
			
				-- can the player carry the said amount of x item?
				if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
					TriggerClientEvent('esx:showNotification', _source, _U('player_cannot_hold'))
				else
					inventory.removeItem(item, count)
					xPlayer.addInventoryItem(item, count)
					TriggerClientEvent('esx:showNotification', _source, _U('have_withdrawn', count, inventoryItem.label))
				end
			else
				TriggerClientEvent('esx:showNotification', _source, _U('not_enough_in_property'))
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
     
      TriggerEvent('esx_addoninventory:getInventory', 'property', xPlayerOwner.identifier, function(inventory)
        xPlayer.removeInventoryItem(item, count)
        inventory.addItem(item, count)
        TriggerClientEvent('esx:showNotification', _source, _U('have_deposited', count, inventory.getItem(item).label))
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

  TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)

    local count    = store.count('dressing')
    local labels   = {}

    for i=1, count, 1 do
      local entry = store.get('dressing', i)
      table.insert(labels, entry.label)
    end

    cb(labels)

  end)

end)

ESX.RegisterServerCallback('esx_property:getPlayerOutfit', function(source, cb, num)

  local xPlayer  = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
    local outfit = store.get('dressing', num)
    cb(outfit.skin)
  end)

end)

RegisterServerEvent('esx_property:removeOutfit')
AddEventHandler('esx_property:removeOutfit', function(label)

    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)

        local dressing = store.get('dressing')

        if dressing == nil then
            dressing = {}
        end

        label = label
        
        table.remove(dressing, label)

        store.set('dressing', dressing)

    end)

end)

function PayRent()
	MySQL.Async.fetchAll(
	'SELECT * FROM owned_properties WHERE rented = 1', {},
	function (result)
		for i=1, #result, 1 do
			local xPlayer = ESX.GetPlayerFromIdentifier(result[i].owner)

			-- message player if connected
			if xPlayer ~= nil then
				xPlayer.removeBank(result[i].price)
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_rent', result[i].price))
			else -- pay rent either way
				MySQL.Sync.execute(
				'UPDATE users SET bank = bank - @bank WHERE identifier = @identifier',
				{
					['@bank']       = result[i].price,
					['@identifier'] = result[i].owner
				})
			end

			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_realestateagent', function(account)
				account.addMoney(result[i].price)
			end)
		end
	end)
end

TriggerEvent('cron:runAt', 22, 0, PayRent)
