function ESX.Trace(msg)
  if Config.EnableDebug then
    print(('[^2TRACE^7] %s^7'):format(msg))
  end
end

function ESX.SetTimeout(msec, cb)
  local id = Core.TimeoutCount + 1

  SetTimeout(msec, function()
    if Core.CancelledTimeouts[id] then
      Core.CancelledTimeouts[id] = nil
    else
      cb()
    end
  end)

  Core.TimeoutCount = id

  return id
end

function ESX.RegisterCommand(name, group, cb, allowConsole, suggestion)
  if type(name) == 'table' then
    for k, v in ipairs(name) do
      ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
    end

    return
  end

  if Core.RegisteredCommands[name] then
    print(('[^3WARNING^7] Command ^5"%s" ^7already registered, overriding command'):format(name))

    if Core.RegisteredCommands[name].suggestion then
      TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name))
    end
  end

  if suggestion then
    if not suggestion.arguments then
      suggestion.arguments = {}
    end
    if not suggestion.help then
      suggestion.help = ''
    end

    TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
  end

  Core.RegisteredCommands[name] = {group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion}

  RegisterCommand(name, function(playerId, args, rawCommand)
    local command = Core.RegisteredCommands[name]

    if not command.allowConsole and playerId == 0 then
      print(('[^3WARNING^7] ^5%s'):format(_U('commanderror_console')))
    else
      local xPlayer, error = ESX.Players[playerId], nil

      if command.suggestion then
        if command.suggestion.validate then
          if #args ~= #command.suggestion.arguments then
            error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
          end
        end

        if not error and command.suggestion.arguments then
          local newArgs = {}

          for k, v in ipairs(command.suggestion.arguments) do
            if v.type then
              if v.type == 'number' then
                local newArg = tonumber(args[k])

                if newArg then
                  newArgs[v.name] = newArg
                else
                  error = _U('commanderror_argumentmismatch_number', k)
                end
              elseif v.type == 'player' or v.type == 'playerId' then
                local targetPlayer = tonumber(args[k])

                if args[k] == 'me' then
                  targetPlayer = playerId
                end

                if targetPlayer then
                  local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

                  if xTargetPlayer then
                    if v.type == 'player' then
                      newArgs[v.name] = xTargetPlayer
                    else
                      newArgs[v.name] = targetPlayer
                    end
                  else
                    error = _U('commanderror_invalidplayerid')
                  end
                else
                  error = _U('commanderror_argumentmismatch_number', k)
                end
              elseif v.type == 'string' then
                newArgs[v.name] = args[k]
              elseif v.type == 'item' then
                if ESX.Items[args[k]] then
                  newArgs[v.name] = args[k]
                else
                  error = _U('commanderror_invaliditem')
                end
              elseif v.type == 'weapon' then
                if ESX.GetWeapon(args[k]) then
                  newArgs[v.name] = string.upper(args[k])
                else
                  error = _U('commanderror_invalidweapon')
                end
              elseif v.type == 'any' then
                newArgs[v.name] = args[k]
              end
            end

            if v.validate == false then
              error = nil
            end

            if error then
              break
            end
          end

          args = newArgs
        end
      end

      if error then
        if playerId == 0 then
          print(('[^3WARNING^7] %s^7'):format(error))
        else
          xPlayer.showNotification(error)
        end
      else
        cb(xPlayer or false, args, function(msg)
          if playerId == 0 then
            print(('[^3WARNING^7] %s^7'):format(msg))
          else
            xPlayer.showNotification(msg)
          end
        end)
      end
    end
  end, true)

  if type(group) == 'table' then
    for k, v in ipairs(group) do
      ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
    end
  else
    ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
  end
end

function ESX.ClearTimeout(id)
  Core.CancelledTimeouts[id] = true
end

function ESX.RegisterServerCallback(name, cb)
  Core.ServerCallbacks[name] = cb
end

function ESX.TriggerServerCallback(name, requestId, source, cb, ...)
  if Core.ServerCallbacks[name] then
    Core.ServerCallbacks[name](source, cb, ...)
  else
    print(('[^3WARNING^7] Server callback ^5"%s"^0 does not exist. ^1Please Check The Server File for Errors!'):format(name))
  end
end

function Core.SavePlayer(xPlayer, cb)
  MySQL.prepare(
    'UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ? WHERE `identifier` = ?',
    {json.encode(xPlayer.getAccounts(true)), xPlayer.job.name, xPlayer.job.grade, xPlayer.group, json.encode(xPlayer.getCoords()),
     json.encode(xPlayer.getInventory(true)), json.encode(xPlayer.getLoadout(true)), xPlayer.identifier}, function(affectedRows)
      if affectedRows == 1 then
        print(('[^2INFO^7] Saved player ^5"%s^7"'):format(xPlayer.name))
        TriggerEvent('esx:playerSaved', xPlayer.playerId, xPlayer)
      end
      if cb then
        cb()
      end
    end)
end

function Core.SavePlayers(cb)
  local xPlayers = ESX.GetExtendedPlayers()
  local count = #xPlayers
  if count > 0 then
    local parameters = {}
    local time = os.time()
    for i = 1, count do
      local xPlayer = xPlayers[i]
      parameters[#parameters + 1] = {json.encode(xPlayer.getAccounts(true)), xPlayer.job.name, xPlayer.job.grade, xPlayer.group,
                                     json.encode(xPlayer.getCoords()), json.encode(xPlayer.getInventory(true)), json.encode(xPlayer.getLoadout(true)),
                                     xPlayer.identifier}
    end
    MySQL.prepare(
      "UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ? WHERE `identifier` = ?",
      parameters, function(results)
        if results then
          if type(cb) == 'function' then
            cb()
          else
            print(('[^2INFO^7] Saved %s %s over %s ms'):format(count, count > 1 and 'players' or 'player', (os.time() - time) / 1000000))
          end
        end
      end)
  end
end

function ESX.GetPlayers()
  local sources = {}

  for k, v in pairs(ESX.Players) do
    sources[#sources + 1] = k
  end

  return sources
end

function ESX.GetExtendedPlayers(key, val)
  local xPlayers = {}
  for k, v in pairs(ESX.Players) do
    if key then
      if (key == 'job' and v.job.name == val) or v[key] == val then
        xPlayers[#xPlayers + 1] = v
      end
    else
      xPlayers[#xPlayers + 1] = v
    end
  end
  return xPlayers
end

function ESX.GetPlayerFromId(source)
  return ESX.Players[tonumber(source)]
end

function ESX.GetPlayerFromIdentifier(identifier)
  for k, v in pairs(ESX.Players) do
    if v.identifier == identifier then
      return v
    end
  end
end

function ESX.GetIdentifier(playerId)
  for k, v in ipairs(GetPlayerIdentifiers(playerId)) do
    if string.match(v, 'license:') then
      local identifier = string.gsub(v, 'license:', '')
      return identifier
    end
  end
end

function ESX.RefreshJobs()
  local Jobs = {}
  local jobs = MySQL.query.await('SELECT * FROM jobs')

  for _, v in ipairs(jobs) do
    Jobs[v.name] = v
    Jobs[v.name].grades = {}
  end

  local jobGrades = MySQL.query.await('SELECT * FROM job_grades')

  for _, v in ipairs(jobGrades) do
    if Jobs[v.job_name] then
      Jobs[v.job_name].grades[tostring(v.grade)] = v
    else
      print(('[^3WARNING^7] Ignoring job grades for ^5"%s"^0 due to missing job'):format(v.job_name))
    end
  end

  for _, v in pairs(Jobs) do
    if ESX.Table.SizeOf(v.grades) == 0 then
      Jobs[v.name] = nil
      print(('[^3WARNING^7] Ignoring job ^5"%s"^0 due to no job grades found'):format(v.name))
    end
  end

  if not Jobs then
    -- Fallback data, if no jobs exist
    ESX.Jobs['unemployed'] = {label = 'Unemployed',
                              grades = {['0'] = {grade = 0, label = 'Unemployed', salary = 200, skin_male = {}, skin_female = {}}}}
  else
    ESX.Jobs = Jobs
  end
end

function ESX.RegisterUsableItem(item, cb)
  Core.UsableItemsCallbacks[item] = cb
end

function ESX.UseItem(source, item, ...)
  if ESX.Items[item] then
    local itemCallback = Core.UsableItemsCallbacks[item]

    if itemCallback then
      local success, result = pcall(itemCallback, source, item, ...)

      if not success then
        return result and print(result) or
                 print(('[^3WARNING^7] An error occured when using item ^5"%s"^7! This was not caused by ESX.'):format(item))
      end
    end
  else
    print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(item))
  end
end

function ESX.RegisterPlayerFunctionOverrides(index, overrides)
  Core.PlayerFunctionOverrides[index] = overrides
end

function ESX.SetPlayerFunctionOverride(index)
  if not index or not Core.PlayerFunctionOverrides[index] then
    return print('[^3WARNING^7] No valid index provided.')
  end

  Config.PlayerFunctionOverride = index
end

function ESX.GetItemLabel(item)
  if Config.OxInventory then
    item = exports.ox_inventory:Items(item)
    if item then
      return item.label
    end
  end

  if ESX.Items[item] then
    return ESX.Items[item].label
  else
    print('[^3WARNING^7] Attemting to get invalid Item -> ' .. item)
  end
end

function ESX.GetJobs()
  return ESX.Jobs
end

function ESX.GetUsableItems()
  local Usables = {}
  for k in pairs(Core.UsableItemsCallbacks) do
    Usables[k] = true
  end
  return Usables
end

if not Config.OxInventory then
  function ESX.CreatePickup(type, name, count, label, playerId, components, tintIndex)
    local pickupId = (Core.PickupId == 65635 and 0 or Core.PickupId + 1)
    local xPlayer = ESX.Players[playerId]
    local coords = xPlayer.getCoords()

    Core.Pickups[pickupId] = {type = type, name = name, count = count, label = label, coords = coords}

    if type == 'item_weapon' then
      Core.Pickups[pickupId].components = components
      Core.Pickups[pickupId].tintIndex = tintIndex
    end

    TriggerClientEvent('esx:createPickup', -1, pickupId, label, coords, type, name, components, tintIndex)
    Core.PickupId = pickupId
  end
end

function ESX.DoesJobExist(job, grade)
  grade = tostring(grade)

  if job and grade then
    if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
      return true
    end
  end

  return false
end

function Core.IsPlayerAdmin(playerId)
  if (IsPlayerAceAllowed(playerId, 'command') or GetConvar('sv_lan', '') == 'true') and true or false then
    return true
  end

  local xPlayer = ESX.Players[playerId]

  if xPlayer then
    if xPlayer.group == 'admin' then
      return true
    end
  end

  return false
end
