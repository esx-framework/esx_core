TriggerEvent('es:addGroupCommand', 'tp', 'admin', function(source, args, user)

  TriggerClientEvent("esx:teleport", source, {
    x = tonumber(args[1]),
    y = tonumber(args[2]),
    z = tonumber(args[3])
  })

end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end)

TriggerEvent('es:addGroupCommand', 'setjob', 'jobmaster', function(source, args, user)
  local xPlayer = ESX.GetPlayerFromId(args[1])
  xPlayer.setJob(args[2], tonumber(args[3]))
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('setjob'), params = {{name = "id", help = _U('id_param')}, {name = "job", help = _U('setjob_param2')}, {name = "grade_id", help = _U('setjob_param3')}}})

TriggerEvent('es:addGroupCommand', 'loadipl', 'admin', function(source, args, user)
  TriggerClientEvent('esx:loadIPL', -1, args[1])
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('load_ipl')})

TriggerEvent('es:addGroupCommand', 'unloadipl', 'admin', function(source, args, user)
  TriggerClientEvent('esx:unloadIPL', -1, args[1])
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('unload_ipl')})

TriggerEvent('es:addGroupCommand', 'playanim', 'admin', function(source, args, user)
  TriggerClientEvent('esx:playAnim', -1, args[1], args[3])
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('play_anim')})

TriggerEvent('es:addGroupCommand', 'playemote', 'admin', function(source, args, user)
  TriggerClientEvent('esx:playEmote', -1, args[1])
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('play_emote')})

TriggerEvent('es:addGroupCommand', 'car', 'admin', function(source, args, user)
  TriggerClientEvent('esx:spawnVehicle', source, args[1])
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('spawn_car'), params = {{name = "car", help = _U('spawn_car_param')}}})

TriggerEvent('es:addGroupCommand', 'dv', 'admin', function(source, args, user)
  TriggerClientEvent('esx:deleteVehicle', source)
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('delete_vehicle'), params = {{name = "car", help = _U('delete_veh_param')}}})


TriggerEvent('es:addGroupCommand', 'spawnped', 'admin', function(source, args, user)
  TriggerClientEvent('esx:spawnPed', source, args[1])
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('spawn_ped'), params = {{name = "name", help = _U('spawn_ped_param')}}})

TriggerEvent('es:addGroupCommand', 'spawnobject', 'admin', function(source, args, user)
  TriggerClientEvent('esx:spawnObject', source, args[1])
end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('spawn_object'), params = {{name = "name"}}})

TriggerEvent('es:addGroupCommand', 'givemoney', 'admin', function(source, args, user)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(args[1])
  local amount  = tonumber(args[2])

  if amount ~= nil then
    xPlayer.addMoney(amount)
  else
    TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
  end

end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('givemoney'), params = {{name = "id", help = _U('id_param')}, {name = "amount", help = _U('money_amount')}}})

TriggerEvent('es:addGroupCommand', 'giveaccountmoney', 'admin', function(source, args, user)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(args[1])
  local account = args[2]
  local amount  = tonumber(args[3])

  if amount ~= nil then
    if xPlayer.getAccount(account) ~= nil then
      xPlayer.addAccountMoney(account, amount)
    else
      TriggerClientEvent('esx:showNotification', _source, _U('invalid_account'))
    end
  else
    TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
  end

end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('giveaccountmoney'), params = {{name = "id", help = _U('id_param')}, {name = "account", help = _U('account')}, {name = "amount", help = _U('money_amount')}}})

TriggerEvent('es:addGroupCommand', 'giveitem', 'admin', function(source, args, user)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(args[1])
  local item    = args[2]
  local count   = (args[3] == nil and 1 or tonumber(args[3]))

  if count ~= nil then
    if xPlayer.getInventoryItem(item) ~= nil then
      xPlayer.addInventoryItem(item, count)
    else
      TriggerClientEvent('esx:showNotification', _source, _U('invalid_item'))
    end
  else
    TriggerClientEvent('esx:showNotification', _source, _U('invalid_amount'))
  end

end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('giveitem'), params = {{name = "id", help = _U('id_param')}, {name = "item", help = _U('item')}, {name = "amount", help = _U('amount')}}})

TriggerEvent('es:addGroupCommand', 'giveweapon', 'admin', function(source, args, user)

  local xPlayer    = ESX.GetPlayerFromId(args[1])
  local weaponName = string.upper(args[2])

  xPlayer.addWeapon(weaponName, 1000)

end, function(source, args, user)
  TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficient Permissions.")
end, {help = _U('giveweapon'), params = {{name = "id", help = _U('id_param')}, {name = "weapon", help = _U('weapon')}}})
