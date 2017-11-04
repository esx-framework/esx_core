ESX                      = {}
ESX.Players              = {}
ESX.UsableItemsCallbacks = {}
ESX.Items                = {}
ESX.ServerCallbacks      = {}
ESX.TimeoutCount         = -1
ESX.CancelledTimeouts    = {}
ESX.LastPlayerData       = {}
ESX.Pickups              = {}
ESX.PickupId             = 0

AddEventHandler('esx:getSharedObject', function(cb)
  cb(ESX)
end)

function getSharedObject()
  return ESX
end

AddEventHandler('onMySQLReady', function ()

  MySQL.Async.fetchAll(
    'SELECT * FROM items',
    {},
    function(result)

      for i=1, #result, 1 do
        ESX.Items[result[i].name] = {
          label     = result[i].label,
          limit     = result[i].limit,
          rare      = (result[i].rare       == 1 and true or false),
          canRemove = (result[i].can_remove == 1 and true or false),
        }
      end

    end
  )

end)

AddEventHandler('esx:playerLoaded', function(source)

  local xPlayer         = ESX.GetPlayerFromId(source)
  local accounts        = {}
  local items           = {}
  local xPlayerAccounts = xPlayer.getAccounts()
  local xPlayerItems    = xPlayer.getInventory()

  for i=1, #xPlayerAccounts, 1 do
    accounts[xPlayerAccounts[i].name] = xPlayerAccounts[i].money
  end

  for i=1, #xPlayerItems, 1 do
    items[xPlayerItems[i].name] = xPlayerItems[i].count
  end

  ESX.LastPlayerData[source] = {
    accounts = accounts,
    items    = items
  }

end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
  RconPrint(msg .. "\n")
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)

  local _source = source

  ESX.TriggerServerCallback(name, requestID, _source, function(...)
    TriggerClientEvent('esx:serverCallback', _source, requestId, ...)
  end, ...)

end)

