MySQL.ready(function()
  MySQL.Async.store('SELECT `is_dead` FROM `users` WHERE `identifier` = ?', function(storeId) GetDeathStatus = storeId end)
  MySQL.Async.store('SELECT `health`, `armour` FROM `users` WHERE `identifier` = ?', function(storeId) LoadHealthNArmour = storeId end)
  MySQL.Async.store("UPDATE `users` SET `health` = ?, `armour` = ? WHERE `identifier` = ?", function(storeId) UpdateHealthNArmour = storeId end)
end)

RegisterNetEvent('esx:onPlayerSpawn')
AddEventHandler('esx:onPlayerSpawn', function()
  local playerId = source
  local xPlayer = ESX.GetPlayerFromId(playerId)

  if xPlayer ~= nil then
    MySQL.Async.fetchScalar(GetDeathStatus, {xPlayer.identifier}, function(isDead)
      if not isDead then 
        MySQL.Async.fetchAll(LoadHealthNArmour, {xPlayer.identifier}, function(data)
          if data[1].health ~= nil and data[1].armour ~= nil then
            TriggerClientEvent('esx_healthnarmour:set', playerId, data[1].health, data[1].armour)
          end
        end)
      end
    end)
  end
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
  local xPlayer = ESX.GetPlayerFromId(playerId)
  
  if xPlayer ~= nil then
    local health = GetEntityHealth(GetPlayerPed(xPlayer.source))
    local armour = GetPedArmour(GetPlayerPed(xPlayer.source))
    MySQL.Sync.execute(UpdateHealthNArmour, {health, armour, xPlayer.identifier})
  end
end)
