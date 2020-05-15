local self = ESX.Modules['accessories']

-- BEGIN extend xPlayer stuff

  -- add properties and methods to xPlayer when bulding its instance
  AddEventHandler('esx:player:create', function(xPlayer)

    xPlayer.set('getAccessories', function()
      return xPlayer.get('accessories')
    end)

    xPlayer.set('setAccessories', function(accessories)
      xPlayer.set('accessories', accessories)
    end)

  end)

  -- add field when serializing xPlayer instance (for sending in event for example)
  AddEventHandler('esx:player:serialize', function(xPlayer, add)
    add({accessories = xPlayer.getAccessories()})
  end)

  -- add field when serializing xPlayer instance to DB
  AddEventHandler('esx:player:serialize:db', function(xPlayer, add)
    add({accessories = json.encode(xPlayer.getAccessories())})
  end)

  -- handle sql field loading from DB
  AddEventHandler('esx:player:load:accessories', function(identifier, playerId, row, userData, addTask)

    addTask(function(cb)

      local data = {}

      if row.accessories and row.accessories ~= '' then
        data = json.decode(row.accessories)
      else
        data = {}
      end

      cb({accessories = data})

    end)

  end)

-- END extend xPlayer stuff

RegisterServerEvent('esx_accessories:pay')
AddEventHandler('esx_accessories:pay', function()

  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeMoney(self.Config.Price)
  TriggerClientEvent('esx:showNotification', source, _U('accesories:you_paid', ESX.Math.GroupDigits(self.Config.Price)))

end)

RegisterServerEvent('esx_accessories:save')
AddEventHandler('esx_accessories:save', function(skin, accessory)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

  local item1 = string.lower(accessory) .. '_1'
  local item2 = string.lower(accessory) .. '_2'

  local accessories = xPlayer.getAccessories()

  accessories[accessory] = {
    [item1] = skin[item1],
    [item2] = skin[item2],
  }

  xPlayer.setAccessories(accessories)

end)

ESX.RegisterServerCallback('esx_accessories:get', function(source, cb, accessory)

  local xPlayer = ESX.GetPlayerFromId(source)

  local skin         = xPlayer.accessories[accessory]
  local hasAccessory = skin ~= nil

	cb(hasAccessory, skin)

end)

ESX.RegisterServerCallback('esx_accessories:checkMoney', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)
  cb(xPlayer.getMoney() >= self.Config.Price)

end)

