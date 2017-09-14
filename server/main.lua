ESX              = nil
local Categories = {}
local Vehicles   = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', 'cardealer', _U('dealer_customers'), false, false)
TriggerEvent('esx_society:registerSociety', 'cardealer', 'Concessionnaire', 'society_cardealer', 'society_cardealer', 'society_cardealer', {type = 'private'})

function RemoveOwnedVehicle (plate)
  MySQL.Async.fetchAll(
    'SELECT * FROM owned_vehicles',
    {},
    function (result)
      for i=1, #result, 1 do
        local vehicleProps = json.decode(result[i].vehicle)

        if vehicleProps.plate == plate then
          MySQL.Async.execute(
            'DELETE FROM owned_vehicles WHERE id = @id',
            { ['@id'] = result[i].id }
          )
        end
      end
    end
  )
end

AddEventHandler('onMySQLReady', function ()
  Categories       = MySQL.Sync.fetchAll('SELECT * FROM vehicle_categories')
  local vehicles   = MySQL.Sync.fetchAll('SELECT * FROM vehicles')

  for i=1, #vehicles, 1 do
    local vehicle = vehicles[i]

    for j=1, #Categories, 1 do
      if Categories[j].name == vehicle.category then
        vehicle.categoryLabel = Categories[j].label
      end
    end

    table.insert(Vehicles, vehicle)
  end
end)

RegisterServerEvent('esx_vehicleshop:setVehicleOwned')
AddEventHandler('esx_vehicleshop:setVehicleOwned', function (vehicleProps)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.execute(
    'INSERT INTO owned_vehicles (vehicle, owner) VALUES (@vehicle, @owner)',
    {
      ['@vehicle'] = json.encode(vehicleProps),
      ['@owner']   = xPlayer.identifier,
    },
    function (rowsChanged)
      TriggerClientEvent('esx:showNotification', _source, _U('vehicle').. vehicleProps.plate .. _('belongs'))
    end
  )
end)

RegisterServerEvent('esx_vehicleshop:setVehicleOwnedPlayerId')
AddEventHandler('esx_vehicleshop:setVehicleOwnedPlayerId', function (playerId, vehicleProps)
  local xPlayer = ESX.GetPlayerFromId(playerId)

  MySQL.Async.execute(
    'INSERT INTO owned_vehicles (vehicle, owner) VALUES (@vehicle, @owner)',
    {
      ['@vehicle'] = json.encode(vehicleProps),
      ['@owner']   = xPlayer.identifier,
    },
    function (rowsChanged)
      TriggerClientEvent('esx:showNotification', playerId, _U('vehicle') .. vehicleProps.plate .. _('belongs'))
    end
  )
end)

RegisterServerEvent('esx_vehicleshop:setVehicleOwnedSociety')
AddEventHandler('esx_vehicleshop:setVehicleOwnedSociety', function (society, vehicleProps)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.execute(
    'INSERT INTO owned_vehicles (vehicle, owner) VALUES (@vehicle, @owner)',
    {
      ['@vehicle'] = json.encode(vehicleProps),
      ['@owner']   = 'society:' .. society,
    },
    function (rowsChanged)

    end
  )
end)

RegisterServerEvent('esx_vehicleshop:sellVehicle')
AddEventHandler('esx_vehicleshop:sellVehicle', function (vehicle)
  MySQL.Async.fetchAll(
    'SELECT * FROM cardealer_vehicles WHERE vehicle = @vehicle LIMIT 1',
    { ['@vehicle'] = vehicle },
    function (result)
      local id    = result[1].id
      local price = result[1].price

      MySQL.Async.execute(
        'DELETE FROM cardealer_vehicles WHERE id = @id',
        { ['@id'] = id }
      )
    end
  )
end)

RegisterServerEvent('esx_vehicleshop:rentVehicle')
AddEventHandler('esx_vehicleshop:rentVehicle', function (vehicle, plate, playerName, basePrice, rentPrice, target)
  local xPlayer = ESX.GetPlayerFromId(target)

  MySQL.Async.fetchAll(
    'SELECT * FROM cardealer_vehicles WHERE vehicle = @vehicle LIMIT 1',
    { ['@vehicle'] = vehicle },
    function (result)
      local id     = result[1].id
      local price  = result[1].price
      local owner  = xPlayer.identifier

      MySQL.Async.execute(
        'DELETE FROM cardealer_vehicles WHERE id = @id',
        { ['@id'] = id }
      )

      MySQL.Async.execute(
        'INSERT INTO rented_vehicles (vehicle, plate, player_name, base_price, rent_price, owner) VALUES (@vehicle, @plate, @player_name, @base_price, @rent_price, @owner)',
        {
          ['@vehicle']     = vehicle,
          ['@plate']       = plate,
          ['@player_name'] = playerName,
          ['@base_price']  = basePrice,
          ['@rent_price']  = rentPrice,
          ['@owner']       = owner,
        }
      )
    end
  )
end)

RegisterServerEvent('esx_vehicleshop:setVehicleForAllPlayers')
AddEventHandler('esx_vehicleshop:setVehicleForAllPlayers', function (props, x, y, z, radius)
  TriggerClientEvent('esx_vehicleshop:setVehicle', -1, props, x, y, z, radius)
end)

RegisterServerEvent('esx_vehicleshop:getStockItem')
AddEventHandler('esx_vehicleshop:getStockItem', function (itemName, count)
  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cardealer', function (inventory)
    local item = inventory.getItem(itemName)

    if item.count >= count then
      inventory.removeItem(itemName, count)
      xPlayer.addInventoryItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, 'Quantité invalide')
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. ' x' .. count .. ' ' .. item.label)
  end)
end)

RegisterServerEvent('esx_vehicleshop:putStockItems')
AddEventHandler('esx_vehicleshop:putStockItems', function (itemName, count)
  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cardealer', function (inventory)
    local item = inventory.getItem(itemName)

    if item.count >= 0 then
      xPlayer.removeInventoryItem(itemName, count)
      inventory.addItem(itemName, count)
    else
      TriggerClientEvent('esx:showNotification', xPlayer.source, 'Quantité invalide')
    end

    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('added') .. ' x' .. count .. ' ' .. item.label)
  end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getCategories', function (source, cb)
  cb(Categories)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getVehicles', function (source, cb)
  cb(Vehicles)
end)

ESX.RegisterServerCallback('esx_vehicleshop:buyVehicle', function (source, cb, vehicleModel)
  local xPlayer     = ESX.GetPlayerFromId(source)
  local vehicleData = nil

  for i=1, #Vehicles, 1 do
    if Vehicles[i].model == vehicleModel then
      vehicleData = Vehicles[i]
      break
    end
  end

  if xPlayer.get('money') >= vehicleData.price then
    xPlayer.removeMoney(vehicleData.price)
    cb(true)
  else
    cb(false)
  end
end)

ESX.RegisterServerCallback('esx_vehicleshop:buyVehicleSociety', function (source, cb, society, vehicleModel)
  local vehicleData = nil

  for i=1, #Vehicles, 1 do
    if Vehicles[i].model == vehicleModel then
      vehicleData = Vehicles[i]
      break
    end
  end

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function (account)
    if account.money >= vehicleData.price then

      account.removeMoney(vehicleData.price)

      MySQL.Async.execute(
        'INSERT INTO cardealer_vehicles (vehicle, price) VALUES (@vehicle, @price)',
        {
          ['@vehicle'] = vehicleData.model,
          ['@price']   = vehicleData.price,
        }
      )

      cb(true)
    else
      cb(false)
    end
  end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getPersonnalVehicles', function (source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)

  MySQL.Async.fetchAll(
    'SELECT * FROM owned_vehicles WHERE owner = @owner',
    { ['@owner'] = xPlayer.identifier },
    function (result)
      local vehicles = {}

      for i=1, #result, 1 do
        local vehicleData = json.decode(result[i].vehicle)
        table.insert(vehicles, vehicleData)
      end

      cb(vehicles)
    end
  )
end)

ESX.RegisterServerCallback('esx_vehicleshop:getCommercialVehicles', function (source, cb)
  MySQL.Async.fetchAll(
    'SELECT * FROM cardealer_vehicles ORDER BY vehicle ASC',
    {},
    function (result)
      local vehicles = {}

      for i=1, #result, 1 do
        table.insert(vehicles, {
          name  = result[i].vehicle,
          price = result[i].price
        })
      end

      cb(vehicles)
    end
  )
end)

ESX.RegisterServerCallback('esx_vehicleshop:getRentedVehicles', function (source, cb)
  MySQL.Async.fetchAll(
    'SELECT * FROM rented_vehicles ORDER BY player_name ASC',
    {},
    function (result)
      local vehicles = {}

      for i=1, #result, 1 do
        table.insert(vehicles, {
          name       = result[i].vehicle,
          plate      = result[i].plate,
          playerName = result[i].player_name
        })
      end

      cb(vehicles)
    end
  )
end)

ESX.RegisterServerCallback('esx_vehicleshop:giveBackVehicle', function (source, cb, plate)
  MySQL.Async.fetchAll(
    'SELECT * FROM rented_vehicles WHERE plate = @plate LIMIT 1',
    { ['@plate'] = plate },
    function (result)
      if #result > 0 then
        local id        = result[1].id
        local vehicle   = result[1].vehicle
        local plate     = result[1].plate
        local basePrice = result[1].base_price

        MySQL.Async.execute(
          'INSERT INTO cardealer_vehicles (vehicle, price) VALUES (@vehicle, @price)',
          {
            ['@vehicle'] = vehicle,
            ['@price']   = basePrice,
          }
        )

        MySQL.Async.execute(
          'DELETE FROM rented_vehicles WHERE id = @id',
          { ['@id'] = id }
        )

        RemoveOwnedVehicle(plate)

        cb(true)
      else
        cb(false)
      end
    end
  )
end)

ESX.RegisterServerCallback('esx_vehicleshop:resellVehicle', function (source, cb, plate, price)
  MySQL.Async.fetchAll(
    'SELECT * FROM rented_vehicles WHERE plate = @plate LIMIT 1',
    { ['@plate'] = plate },
    function (result)
      if #result > 0 then
        cb(false)
      else
        local xPlayer = ESX.GetPlayerFromId(source)

        MySQL.Async.fetchAll(
          'SELECT * FROM owned_vehicles WHERE owner = @owner',
          { ['@owner'] = xPlayer.identifier },
          function (result)
            local found = false

            for i=1, #result, 1 do
              local vehicleProps = json.decode(result[i].vehicle)

              if vehicleProps.plate == plate then
                found = true
                break
              end
            end

            if found then
              xPlayer.addMoney(price)
              RemoveOwnedVehicle(plate)

              cb(true)
            else
              if xPlayer.job.grade_name == 'boss' then
                MySQL.Async.fetchAll(
                  'SELECT * FROM owned_vehicles WHERE owner = @owner',
                  { ['@owner'] = 'society:' .. xPlayer.job.name },
                  function (result)
                    local found = false

                    for i=1, #result, 1 do
                      local vehicleProps = json.decode(result[i].vehicle)

                      if vehicleProps.plate == plate then
                        found = true
                        break
                      end
                    end

                    if found then
                      xPlayer.addMoney(price)
                      RemoveOwnedVehicle(plate)

                      cb(true)
                    else
                      cb(false)
                    end
                  end
                )
              else
                cb(false)
              end
            end
          end
        )
      end
    end
  )
end)


ESX.RegisterServerCallback('esx_vehicleshop:getStockItems', function (source, cb)
  TriggerEvent('esx_addoninventory:getSharedInventory', 'society_cardealer', function(inventory)
    cb(inventory.items)
  end)
end)

ESX.RegisterServerCallback('esx_vehicleshop:getPlayerInventory', function (source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  local items   = xPlayer.inventory

  cb({ items = items })
end)

if Config.EnablePvCommand then
  TriggerEvent('es:addCommand', 'pv', function (source, args, user)
    TriggerClientEvent('esx_vehicleshop:openPersonnalVehicleMenu', source)
  end, {help = _U('leaving')})
end

function PayRent (d, h, m)
  MySQL.Async.fetchAll(
    'SELECT * FROM users',
    {},
    function (_users)
      local prevMoney = {}
      local newMoney  = {}

      for i=1, #_users, 1 do
        prevMoney[_users[i].identifier] = _users[i].money
        newMoney[_users[i].identifier]  = _users[i].money
      end

      MySQL.Async.fetchAll(
        'SELECT * FROM rented_vehicles',
        {},
        function (result)
          local xPlayers = ESX.GetPlayers()

          for i=1, #result, 1 do
            local foundPlayer = false
            local xPlayer     = nil

            for i=1, #xPlayers, 1 do
              local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])

              if xPlayer2.identifier == result[i].owner then
                foundPlayer = true
                xPlayer     = xPlayer2
              end
            end

            if foundPlayer then
              xPlayer.removeMoney(result[i].rent_price)
              TriggerClientEvent('esx:showNotification', xPlayer.source, _U('paid_rental') .. result[i].rent_price)
            else
              newMoney[result[i].owner] = newMoney[result[i].owner] - result[i].rent_price
            end

            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
              account.addMoney(result[i].rent_price)
            end)
          end

          for k,v in pairs(prevMoney) do
            if v ~= newMoney[k] then
              MySQL.Async.execute(
                'UPDATE users SET money = @money WHERE identifier = @identifier',
                {
                  ['@money']      = newMoney[k],
                  ['@identifier'] = k,
                }
              )
            end
          end
        end
      )
    end
  )
end

TriggerEvent('cron:runAt', 22, 00, PayRent)
