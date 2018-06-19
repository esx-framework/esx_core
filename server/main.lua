AddEventHandler('es:playerLoaded', function(source, _player)

  local _source = source
  local tasks   = {}

  local userData = {
    accounts     = {},
    inventory    = {},
    job          = {},
    loadout      = {},
    playerName   = GetPlayerName(_source),
    lastPosition = nil
  }

  TriggerEvent('es:getPlayerFromId', _source, function(player)

    -- Update user name in DB
    table.insert(tasks, function(cb)

      MySQL.Async.execute(
        'UPDATE `users` SET `name` = @name WHERE `identifier` = @identifier',
        {
          ['@identifier'] = player.getIdentifier(),
          ['@name']       = userData.playerName
        },
        function(rowsChanged)
          cb()
        end
      )

    end)

    -- Get accounts
    table.insert(tasks, function(cb)

      MySQL.Async.fetchAll(
        'SELECT * FROM `user_accounts` WHERE `identifier` = @identifier',
        {
          ['@identifier'] = player.getIdentifier()
        },
        function(accounts)

          for i=1, #Config.Accounts, 1 do
            for j=1, #accounts, 1 do
              if accounts[j].name == Config.Accounts[i] then
                table.insert(userData.accounts, {
                  name  = accounts[j].name,
                  money = accounts[j].money,
                  label = Config.AccountLabels[accounts[j].name]
                })
              end
            end

          end

          cb()
        end
      )

    end)

    -- Get Inventory
    table.insert(tasks, function(cb)

      MySQL.Async.fetchAll(
        'SELECT * FROM `user_inventory` WHERE `identifier` = @identifier',
        {
          ['@identifier'] = player.getIdentifier()
        },
        function(inventory)

          local tasks2 = {}

          for i=1, #inventory, 1 do
            table.insert(userData.inventory, {
              name      = inventory[i].item,
              count     = inventory[i].count,
              label     = ESX.Items[inventory[i].item].label,
              limit     = ESX.Items[inventory[i].item].limit,
              usable    = ESX.UsableItemsCallbacks[inventory[i].item] ~= nil,
              rare      = ESX.Items[inventory[i].item].rare,
              canRemove = ESX.Items[inventory[i].item].canRemove,
            })
          end

          for k,v in pairs(ESX.Items) do

            local found = false

            for j=1, #userData.inventory, 1 do
              if userData.inventory[j].name == k then
                found = true
                break
              end
            end

            if not found then

              table.insert(userData.inventory, {
                name      = k,
                count     = 0,
                label     = ESX.Items[k].label,
                limit     = ESX.Items[k].limit,
                usable    = ESX.UsableItemsCallbacks[k] ~= nil,
                rare      = ESX.Items[k].rare,
                canRemove = ESX.Items[k].canRemove,
              })

              local scope = function(item, identifier)

                table.insert(tasks2, function(cb2)

                  MySQL.Async.execute(
                    'INSERT INTO user_inventory (identifier, item, count) VALUES (@identifier, @item, @count)',
                    {
                      ['@identifier'] = identifier,
                      ['@item']       = item,
                      ['@count']      = 0
                    },
                    function(rowsChanged)
                      cb2()
                    end
                  )

                end)

              end

              scope(k, player.getIdentifier())

            end

          end

          Async.parallelLimit(tasks2, 5, function(results) end)

          table.sort(userData.inventory, function(a,b)
            return a.label < b.label
          end)

          cb()
        end
      )

    end)

    -- Get job and loadout
    table.insert(tasks, function(cb)

      local tasks2 = {}

      -- Get job name, grade and last position
      table.insert(tasks2, function(cb2)

        MySQL.Async.fetchAll(
          'SELECT * FROM `users` WHERE `identifier` = @identifier',
          {
            ['@identifier'] = player.getIdentifier()
          },
          function(result)

            userData.job['name']  = result[1].job
            userData.job['grade'] = result[1].job_grade

            if result[1].loadout ~= nil then
              userData.loadout = json.decode(result[1].loadout)
            end

            if result[1].position ~= nil then
              userData.lastPosition = json.decode(result[1].position)
            end

            cb2()

          end
        )

      end)

      -- Get job label
      table.insert(tasks2, function(cb2)

        MySQL.Async.fetchAll(
          'SELECT * FROM `jobs` WHERE `name` = @name',
          {
            ['@name'] = userData.job.name
          },
          function(result)

            userData.job['label'] = result[1].label

            cb2()

          end
        )

      end)

      -- Get job grade data
      table.insert(tasks2, function(cb2)

        MySQL.Async.fetchAll(
          'SELECT * FROM `job_grades` WHERE `job_name` = @job_name AND `grade` = @grade',
          {
            ['@job_name'] = userData.job.name,
            ['@grade']    = userData.job.grade
          },
          function(result)

            userData.job['grade_name']   = result[1].name
            userData.job['grade_label']  = result[1].label
            userData.job['grade_salary'] = result[1].salary

            userData.job['skin_male']   = {}
            userData.job['skin_female'] = {}

            if result[1].skin_male ~= nil then
              userData.job['skin_male'] = json.decode(result[1].skin_male)
            end

            if result[1].skin_female ~= nil then
              userData.job['skin_female'] = json.decode(result[1].skin_female)
            end

            cb2()

          end
        )

      end)

      Async.series(tasks2, cb)

    end)

    -- Run Tasks
    Async.parallel(tasks, function(results)

      local xPlayer = CreateExtendedPlayer(player, userData.accounts, userData.inventory, userData.job, userData.loadout, userData.playerName, userData.lastPosition)

      xPlayer.getMissingAccounts(function(missingAccounts)

        if #missingAccounts > 0 then

          for i=1, #missingAccounts, 1 do
            table.insert(xPlayer.accounts, {
              name  = missingAccounts[i],
              money = 0,
              label = Config.AccountLabels[missingAccounts[i]]
            })
          end

          xPlayer.createAccounts(missingAccounts)
        end

        ESX.Players[_source] = xPlayer

        TriggerEvent('esx:playerLoaded', _source)

        TriggerClientEvent('esx:playerLoaded', _source, {
          identifier   = xPlayer.identifier,
          accounts     = xPlayer.getAccounts(),
          inventory    = xPlayer.getInventory(),
          job          = xPlayer.getJob(),
          loadout      = xPlayer.getLoadout(),
          lastPosition = xPlayer.getLastPosition(),
          money        = xPlayer.get('money')
        })

        xPlayer.player.displayMoney(xPlayer.get('money'))

      end)

    end)

  end)

end)

AddEventHandler('playerDropped', function(reason)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  if xPlayer ~= nil then

    TriggerEvent('esx:playerDropped', _source, reason)

    ESX.SavePlayer(xPlayer, function()
      ESX.Players[_source]        = nil
      ESX.LastPlayerData[_source] = nil
    end)

  end

end)

RegisterServerEvent('esx:updateLoadout')
AddEventHandler('esx:updateLoadout', function(loadout)
  local xPlayer   = ESX.GetPlayerFromId(source)
  xPlayer.loadout = loadout
end)

RegisterServerEvent('esx:updateLastPosition')
AddEventHandler('esx:updateLastPosition', function(position)
  local xPlayer        = ESX.GetPlayerFromId(source)
  xPlayer.lastPosition = position
end)


RegisterServerEvent('esx:giveInventoryItem')
AddEventHandler('esx:giveInventoryItem', function(target, type, itemName, itemCount)

  local _source = source

  local sourceXPlayer = ESX.GetPlayerFromId(_source)
  local targetXPlayer = ESX.GetPlayerFromId(target)

  if type == 'item_standard' then

    local sourceItem    = sourceXPlayer.getInventoryItem(itemName)
    local targetItem    = targetXPlayer.getInventoryItem(itemName)

    if itemCount > 0 and sourceItem.count >= itemCount then

      if targetItem.limit ~= -1 and (targetItem.count + itemCount) > targetItem.limit then
        TriggerClientEvent('esx:showNotification', _source, _U('ex_inv_lim', targetXPlayer.name))
      else
        sourceXPlayer.removeInventoryItem(itemName, itemCount)
        targetXPlayer.addInventoryItem   (itemName, itemCount)
        
        TriggerClientEvent('esx:showNotification', _source, _U('gave_item', itemCount, ESX.Items[itemName].label, targetXPlayer.name))
        TriggerClientEvent('esx:showNotification', target,  _U('received_item', itemCount, ESX.Items[itemName].label, sourceXPlayer.name))
      end

    else
      TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_quantity'))
    end

  elseif type == 'item_money' then

    if itemCount > 0 and sourceXPlayer.player.get('money') >= itemCount then

      sourceXPlayer.removeMoney(itemCount)
      targetXPlayer.addMoney   (itemCount)

      TriggerClientEvent('esx:showNotification', _source, _U('gave_money', itemCount, targetXPlayer.name))
      TriggerClientEvent('esx:showNotification', target,  _U('received_money', itemCount, sourceXPlayer.name))

    else
      TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
    end

  elseif type == 'item_account' then

    if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then

      sourceXPlayer.removeAccountMoney(itemName, itemCount)
      targetXPlayer.addAccountMoney   (itemName, itemCount)

      TriggerClientEvent('esx:showNotification', _source, _U('gave_account_money', itemCount, Config.AccountLabels[itemName], targetXPlayer.name))
      TriggerClientEvent('esx:showNotification', target,  _U('received_account_money', itemCount, Config.AccountLabels[itemName], sourceXPlayer.name))

    else
      TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
    end

  elseif type == 'item_weapon' then
    
    sourceXPlayer.removeWeapon(itemName)
    targetXPlayer.addWeapon(itemName, itemCount)
    
    local weaponLabel = ESX.GetWeaponLabel(itemName)
    TriggerClientEvent('esx:showNotification', _source, _U('gave_weapon', weaponLabel, itemCount, targetXPlayer.name))
    TriggerClientEvent('esx:showNotification', target,  _U('received_weapon', weaponLabel, itemCount, sourceXPlayer.name))
  end

end)

RegisterServerEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(type, itemName, itemCount)

  local _source = source

  if type == 'item_standard' then

    if itemCount == nil or itemCount <= 0 then
      TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_quantity'))
    else

      local xPlayer   = ESX.GetPlayerFromId(source)
      local foundItem = nil

      for i=1, #xPlayer.inventory, 1 do
        if xPlayer.inventory[i].name == itemName then
          foundItem = xPlayer.inventory[i]
        end
      end

      if itemCount > foundItem.count then
        TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_quantity'))
      else

        TriggerClientEvent('esx:showNotification', _source, _U('delete_five_min'))

        SetTimeout(Config.RemoveInventoryItemDelay, function()

          local remainingCount = xPlayer.getInventoryItem(itemName).count
          local total          = itemCount

          if remainingCount < itemCount then
            total = remainingCount
          end

          if total > 0 then
            xPlayer.removeInventoryItem(itemName, total)
            ESX.CreatePickup('item_standard', itemName, total, foundItem.label .. ' [' .. itemCount .. ']', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('threw') .. ' ' .. foundItem.label .. ' x' .. total)
          end

        end)

      end

    end

  elseif type == 'item_money' then

    if itemCount == nil or itemCount <= 0 then
      TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
    else

      local xPlayer = ESX.GetPlayerFromId(source)

      if itemCount > xPlayer.player.get('money') then
        TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
      else

        TriggerClientEvent('esx:showNotification', _source, _U('delete_five_min'))

        SetTimeout(Config.RemoveInventoryItemDelay, function()

          local remainingCount = xPlayer.player.get('money')
          local total          = itemCount

          if remainingCount < itemCount then
            total = remainingCount
          end

          if total > 0 then
            xPlayer.removeMoney(total)
            ESX.CreatePickup('item_money', 'money', total, 'Cash' .. ' [' .. itemCount .. ']', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('threw') .. ' [Cash] $' .. total)
          end

        end)

      end

    end

  elseif type == 'item_account' then

    if itemCount == nil or itemCount <= 0 then
      TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
    else

      local xPlayer = ESX.GetPlayerFromId(source)

      if itemCount > xPlayer.getAccount(itemName).money then
        TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
      else

        TriggerClientEvent('esx:showNotification', _source, _U('delete_five_min'))

        SetTimeout(Config.RemoveInventoryItemDelay, function()

          local remainingCount = xPlayer.getAccount(itemName).money
          local total          = itemCount

          if remainingCount < itemCount then
            total = remainingCount
          end

          if total > 0 then
            xPlayer.removeAccountMoney(itemName, total)
            ESX.CreatePickup('item_account', itemName, total, Config.AccountLabels[itemName] .. ' [' .. itemCount .. ']', _source)
            TriggerClientEvent('esx:showNotification', _source, _U('threw') .. ' [Cash] $' .. total)
          end

        end)

      end

    end

  elseif type == 'item_weapon' then

    local xPlayer      = ESX.GetPlayerFromId(source)
    local weaponName   = itemName
    local weaponLabel  = ESX.GetWeaponLabel(weaponName)
    local weaponPickup = 'PICKUP_' .. weaponName
    
    TriggerClientEvent('esx:showNotification', _source, _U('delete_five_min'))
    
    SetTimeout(Config.RemoveInventoryItemDelay, function()

      xPlayer.removeWeapon(itemName)
      if Config.EnableWeaponPickup then
        TriggerClientEvent('esx:pickupWeapon', _source, weaponPickup, weaponName, itemCount)
      end

      TriggerClientEvent('esx:showNotification', _source, _U('threw_weapon', weaponLabel, itemCount))

    end)

  end

end)

RegisterServerEvent('esx:useItem')
AddEventHandler('esx:useItem', function(itemName)

  local xPlayer = ESX.GetPlayerFromId(source)
  local count   = xPlayer.getInventoryItem(itemName).count

  if count > 0 then
    ESX.UseItem(source, itemName)
  else
    TriggerClientEvent('esx:showNotification', xPlayer.source, _U('act_imp'))
  end

end)

RegisterServerEvent('esx:onPickup')
AddEventHandler('esx:onPickup', function(id)

  local _source = source
  local pickup  = ESX.Pickups[id]
  local xPlayer = ESX.GetPlayerFromId(_source)

  if pickup.type == 'item_standard' then

    local item      = xPlayer.getInventoryItem(pickup.name)
    local canTake   = ((item.limit == -1) and (pickup.count)) or ((item.limit - item.count > 0) and (item.limit - item.count)) or 0
    local total     = pickup.count < canTake and pickup.count or canTake
    local remaining = pickup.count - total

    TriggerClientEvent('esx:removePickup', -1, id)

    if total > 0 then
      xPlayer.addInventoryItem(pickup.name, total)
    end

    if remaining > 0 then
      TriggerClientEvent('esx:showNotification', _source, _U('cannot_pickup_room', item.label))
      ESX.CreatePickup('item_standard', pickup.name, remaining, item.label .. ' [' .. remaining .. ']', _source)
    end

  elseif pickup.type == 'item_money' then
    TriggerClientEvent('esx:removePickup', -1, id)
    xPlayer.addMoney(pickup.count)
  elseif pickup.type == 'item_account' then
    TriggerClientEvent('esx:removePickup', -1, id)
    xPlayer.addAccountMoney(pickup.name, pickup.count)
  end

end)

ESX.RegisterServerCallback('esx:getPlayerData', function(source, cb)

  local xPlayer = ESX.GetPlayerFromId(source)

  cb({
    identifier   = xPlayer.identifier,
    accounts     = xPlayer.getAccounts(),
    inventory    = xPlayer.getInventory(),
    job          = xPlayer.getJob(),
    loadout      = xPlayer.getLoadout(),
    lastPosition = xPlayer.getLastPosition(),
    money        = xPlayer.get('money')
  })

end)

ESX.RegisterServerCallback('esx:getOtherPlayerData', function(source, cb, target)

  local xPlayer = ESX.GetPlayerFromId(target)

  cb({
    identifier   = xPlayer.identifier,
    accounts     = xPlayer.getAccounts(),
    inventory    = xPlayer.getInventory(),
    job          = xPlayer.getJob(),
    loadout      = xPlayer.getLoadout(),
    lastPosition = xPlayer.getLastPosition(),
    money        = xPlayer.get('money')
  })

end)

TriggerEvent("es:addGroup", "jobmaster", "user", function(group) end)

ESX.StartDBSync()
ESX.StartPayCheck()
