ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(target)
  TriggerClientEvent('esx_ambulancejob:revive', target)
end)

RegisterServerEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(target, type)
  TriggerClientEvent('esx_ambulancejob:heal', target, type)
end)

TriggerEvent('esx_phone:registerNumber', 'ambulance', _U('alert_ambulance'), true, true)

TriggerEvent('esx_society:registerSociety', 'ambulance', 'Ambulance', 'society_ambulance', 'society_ambulance', 'society_ambulance', {type = 'public'})

ESX.RegisterServerCallback('esx_ambulancejob:removeItemsAfterRPDeath', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)

  if Config.RemoveCashAfterRPDeath then

    if xPlayer.getMoney() > 0 then
      xPlayer.removeMoney(xPlayer.getMoney())
    end

    if xPlayer.getAccount('black_money').money > 0 then
      xPlayer.setAccountMoney('black_money', 0)
    end

  end

  if Config.RemoveItemsAfterRPDeath then
    for i=1, #xPlayer.inventory, 1 do
      if xPlayer.inventory[i].count > 0 then
        xPlayer.setInventoryItem(xPlayer.inventory[i].name, 0)
      end
    end
  end

  if Config.RemoveWeaponsAfterRPDeath then
    for i=1, #xPlayer.loadout, 1 do
      xPlayer.removeWeapon(xPlayer.loadout[i].name)
    end
  end

  if Config.RespawnFine then
    xPlayer.removeAccountMoney('bank', Config.RespawnFineAmount)
  end

  cb()

end)

ESX.RegisterServerCallback('esx_ambulancejob:getItemAmount', function(source, cb, item)
  local xPlayer = ESX.GetPlayerFromId(source)
  local qtty = xPlayer.getInventoryItem(item).count
  cb(qtty)
end)

RegisterServerEvent('esx_ambulancejob:removeItem')
AddEventHandler('esx_ambulancejob:removeItem', function(item)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  xPlayer.removeInventoryItem(item, 1)
  if item == 'bandage' then
    TriggerClientEvent('esx:showNotification', _source, _U('used_bandage'))
  elseif item == 'medikit' then
    TriggerClientEvent('esx:showNotification', _source, _U('used_medikit'))
  end
end)

RegisterServerEvent('esx_ambulancejob:giveItem')
AddEventHandler('esx_ambulancejob:giveItem', function(item)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  local limit = xPlayer.getInventoryItem(item).limit
  local delta = 1
  local qtty = xPlayer.getInventoryItem(item).count
  if limit ~= -1 then
    delta = limit - qtty
  end
  if qtty < limit then
    xPlayer.addInventoryItem(item, delta)
  else
    TriggerClientEvent('esx:showNotification', _source, _U('max_item'))
  end
end)


TriggerEvent('es:addGroupCommand', 'revive', 'admin', function(source, args, user)
  print('revive by /revive')
  if args[1] ~= nil then
    TriggerClientEvent('esx_ambulancejob:revive', tonumber(args[1]))
  else
    TriggerClientEvent('esx_ambulancejob:revive', source)
  end
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('revive_help'), params = {{name = 'id'}}})

ESX.RegisterUsableItem('medikit', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeInventoryItem('medikit', 1)
  TriggerClientEvent('esx_ambulancejob:heal', source, 'big')
  TriggerClientEvent('esx:showNotification', source, _U('used_medikit'))
end)

ESX.RegisterUsableItem('bandage', function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  xPlayer.removeInventoryItem('bandage', 1)
  TriggerClientEvent('esx_ambulancejob:heal', source, 'small')
  TriggerClientEvent('esx:showNotification', source, _U('used_bandage'))
end)
