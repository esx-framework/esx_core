---@param msg string
---@return nil
function ESX.Trace(msg)
    if Config.EnableDebug then
        print(("[^2TRACE^7] %s^7"):format(msg))
    end
end

--- Triggers an event for one or more clients.
---@param eventName string The name of the event to trigger.
---@param playerIds table|number If a number, represents a single player ID. If a table, represents an array of player IDs.
---@param ... any Additional arguments to pass to the event handler.
function ESX.TriggerClientEvent(eventName, playerIds, ...)
    if type(playerIds) == "number" then
        TriggerClientEvent(eventName, playerIds, ...)
        return
    end

    local payload = msgpack.pack_args(...)
    local payloadLength = #payload

    for i = 1, #playerIds do
        TriggerClientEventInternal(eventName, playerIds[i], payload, payloadLength)
    end
end

---@param name string | table
---@param group string | table
---@param cb function
---@param allowConsole? boolean
---@param suggestion? table
function ESX.RegisterCommand(name, group, cb, allowConsole, suggestion)
    if type(name) == "table" then
        for _, v in ipairs(name) do
            ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
        end
        return
    end

    if Core.RegisteredCommands[name] then
        print(('[^3WARNING^7] Command ^5"%s" ^7already registered, overriding command'):format(name))

        if Core.RegisteredCommands[name].suggestion then
            TriggerClientEvent("chat:removeSuggestion", -1, ("/%s"):format(name))
        end
    end

    if suggestion then
        if not suggestion.arguments then
            suggestion.arguments = {}
        end
        if not suggestion.help then
            suggestion.help = ""
        end

        TriggerClientEvent("chat:addSuggestion", -1, ("/%s"):format(name), suggestion.help, suggestion.arguments)
    end

    Core.RegisteredCommands[name] = { group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion }

    RegisterCommand(name, function(playerId, args)
        local command = Core.RegisteredCommands[name]

        if not command.allowConsole and playerId == 0 then
            print(("[^3WARNING^7] ^5%s^0"):format(TranslateCap("commanderror_console")))
        else
            local xPlayer, err = ESX.Players[playerId], nil

            if command.suggestion then
                if command.suggestion.validate then
                    if #args ~= #command.suggestion.arguments then
                        err = TranslateCap("commanderror_argumentmismatch", #args, #command.suggestion.arguments)
                    end
                end

                if not err and command.suggestion.arguments then
                    local newArgs = {}

                    for k, v in ipairs(command.suggestion.arguments) do
                        if v.type then
                            if v.type == "number" then
                                local newArg = tonumber(args[k])

                                if newArg then
                                    newArgs[v.name] = newArg
                                else
                                    err = TranslateCap("commanderror_argumentmismatch_number", k)
                                end
                            elseif v.type == "player" or v.type == "playerId" then
                                local targetPlayer = tonumber(args[k])

                                if args[k] == "me" then
                                    targetPlayer = playerId
                                end

                                if targetPlayer then
                                    local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

                                    if xTargetPlayer then
                                        if v.type == "player" then
                                            newArgs[v.name] = xTargetPlayer
                                        else
                                            newArgs[v.name] = targetPlayer
                                        end
                                    else
                                        err = TranslateCap("commanderror_invalidplayerid")
                                    end
                                else
                                    err = TranslateCap("commanderror_argumentmismatch_number", k)
                                end
                            elseif v.type == "string" then
                                local newArg = tonumber(args[k])
                                if not newArg then
                                    newArgs[v.name] = args[k]
                                else
                                    err = TranslateCap("commanderror_argumentmismatch_string", k)
                                end
                            elseif v.type == "item" then
                                if ESX.Items[args[k]] then
                                    newArgs[v.name] = args[k]
                                else
                                    err = TranslateCap("commanderror_invaliditem")
                                end
                            elseif v.type == "weapon" then
                                if ESX.GetWeapon(args[k]) then
                                    newArgs[v.name] = string.upper(args[k])
                                else
                                    err = TranslateCap("commanderror_invalidweapon")
                                end
                            elseif v.type == "any" then
                                newArgs[v.name] = args[k]
                            elseif v.type == "merge" then
                                local length = 0
                                for i = 1, k - 1 do
                                    length = length + string.len(args[i]) + 1
                                end
                                local merge = table.concat(args, " ")

                                newArgs[v.name] = string.sub(merge, length)
                            elseif v.type == "coordinate" then
                                local coord = tonumber(args[k]:match("(-?%d+%.?%d*)"))
                                if not coord then
                                    err = TranslateCap("commanderror_argumentmismatch_number", k)
                                else
                                    newArgs[v.name] = coord
                                end
                            end
                        end
                        
                        if ESX.IsFunctionReference(v.Validator?.validate) and not err then
                            local candidate = newArgs[v.name]
                            local ok, res = pcall(v.Validator.validate, candidate)
                            if not ok or res ~= true then
                                err = v.Validator.err or TranslateCap("commanderror_argumentmismatch")
                            end
                        end

                        --backwards compatibility
                        if v.validate ~= nil and not v.validate then
                            err = nil
                        end

                        if err then
                            break
                        end
                    end

                    args = newArgs
                end
            end

            if err then
                if playerId == 0 then
                    print(("[^3WARNING^7] %s^7"):format(err))
                else
                    xPlayer.showNotification(err)
                end
            else
                cb(xPlayer or false, args, function(msg)
                    if playerId == 0 then
                        print(("[^3WARNING^7] %s^7"):format(msg))
                    else
                        xPlayer.showNotification(msg)
                    end
                end)
            end
        end
    end, true)

    if type(group) == "table" then
        for _, v in ipairs(group) do
            ExecuteCommand(("add_ace group.%s command.%s allow"):format(v, name))
        end
    else
        ExecuteCommand(("add_ace group.%s command.%s allow"):format(group, name))
    end
end

local function updateHealthAndArmorInMetadata(xPlayer)
    local ped = GetPlayerPed(xPlayer.source)
    xPlayer.setMeta("health", GetEntityHealth(ped))
    xPlayer.setMeta("armor", GetPedArmour(ped))
    xPlayer.setMeta("lastPlaytime", xPlayer.getPlayTime())
end

---@param xPlayer table
---@param cb? function
---@return nil
function Core.SavePlayer(xPlayer, cb)
    if not xPlayer.spawned then
        return cb and cb()
    end

    updateHealthAndArmorInMetadata(xPlayer)
    local parameters <const> = {
        json.encode(xPlayer.getAccounts(true)),
        xPlayer.job.name,
        xPlayer.job.grade,
        xPlayer.group,
        json.encode(xPlayer.getCoords(false, true)),
        json.encode(xPlayer.getInventory(true)),
        json.encode(xPlayer.getLoadout(true)),
        json.encode(xPlayer.getMeta()),
        xPlayer.identifier,
    }

    MySQL.prepare(
        "UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ?, `metadata` = ? WHERE `identifier` = ?",
        parameters,
        function(affectedRows)
            if affectedRows == 1 then
                print(('[^2INFO^7] Saved player ^5"%s^7"'):format(xPlayer.name))
                TriggerEvent("esx:playerSaved", xPlayer.playerId, xPlayer)
            end
            if cb then
                cb()
            end
        end
    )
end

---@param cb? function
---@return nil
function Core.SavePlayers(cb)
    local xPlayers <const> = ESX.Players
    if not next(xPlayers) then
        return
    end

    local startTime <const> = os.time()
    local parameters = {}

    for _, xPlayer in pairs(ESX.Players) do
        updateHealthAndArmorInMetadata(xPlayer)
        parameters[#parameters + 1] = {
            json.encode(xPlayer.getAccounts(true)),
            xPlayer.job.name,
            xPlayer.job.grade,
            xPlayer.group,
            json.encode(xPlayer.getCoords(false, true)),
            json.encode(xPlayer.getInventory(true)),
            json.encode(xPlayer.getLoadout(true)),
            json.encode(xPlayer.getMeta()),
            xPlayer.identifier,
        }
    end

    MySQL.prepare(
        "UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ?, `metadata` = ? WHERE `identifier` = ?",
        parameters,
        function(results)
            if not results then
                return
            end

            if type(cb) == "function" then
                return cb()
            end

            print(("[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms"):format(#parameters,
                #parameters > 1 and "players" or "player", ESX.Math.Round((os.time() - startTime) / 1000000, 2)))
        end
    )
end

ESX.GetPlayers = GetPlayers

local function checkTable(key, val, xPlayer, xPlayers, minimal)
    for valIndex = 1, #val do
        local value = val[valIndex]
        if not xPlayers[value] then
            xPlayers[value] = {}
        end

        if (key == "job" and xPlayer.job.name == value) or xPlayer[key] == value then
            xPlayers[value][#xPlayers[value] + 1] = (minimal and xPlayer.source or xPlayer)
        end
    end
end

---@param key? string
---@param val? string|table
---@param minimal? boolean
---@return xPlayer[]|number[]|table<any, xPlayer[]>|table<any, number[]>
function ESX.GetExtendedPlayers(key, val, minimal)
    if not key then
        if not minimal then
            return ESX.Table.ToArray(ESX.Players)
        end

        local xPlayers = {}
        local index = 1
        for src, _ in pairs(ESX.Players) do
            xPlayers[index] = src
            index += 1
        end

        return xPlayers
    end

    local xPlayers = {}
    if type(val) == "table" then
        for _, xPlayer in pairs(ESX.Players) do
            checkTable(key, val, xPlayer, xPlayers, minimal)
        end

        return xPlayers
    end

    for _, xPlayer in pairs(ESX.Players) do
        if (key == "job" and xPlayer.job.name == val) or xPlayer[key] == val then
            xPlayers[#xPlayers + 1] = (minimal and xPlayer.source or xPlayer)
        end
    end

    return xPlayers
end

---@param key? string
---@param val? string|table
---@return number | table
function ESX.GetNumPlayers(key, val)
    if not key then
        return #GetPlayers()
    end

    if type(val) == "table" then
        local numPlayers = {}
        if key == "job" then
            for _, v in ipairs(val) do
                numPlayers[v] = (Core.JobsPlayerCount[v] or 0)
            end
            return numPlayers
        end

        local filteredPlayers = ESX.GetExtendedPlayers(key, val)
        for i, v in pairs(filteredPlayers) do
            numPlayers[i] = (#v or 0)
        end
        return numPlayers
    end

    if key == "job" then
        return (Core.JobsPlayerCount[val] or 0)
    end

    return #ESX.GetExtendedPlayers(key, val)
end

---@param source number
---@return xPlayer?
function ESX.GetPlayerFromId(source)
    return ESX.Players[tonumber(source)]
end

---@param identifier string
---@return xPlayer?
function ESX.GetPlayerFromIdentifier(identifier)
    return Core.playersByIdentifier[identifier]
end

---@param identifier string
---@return number playerId
function ESX.GetPlayerIdFromIdentifier(identifier)
    return Core.playersByIdentifier[identifier]?.source
end

---@param source number
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function ESX.IsPlayerLoaded(source)
    return ESX.Players[source] ~= nil
end

---@param playerId number | string
---@return string, number
function ESX.GetIdentifier(playerId)
    local fxDk = GetConvarInt("sv_fxdkMode", 0)
    if fxDk == 1 then
        return "ESX-DEBUG-LICENCE", 0
    end

    playerId = tostring(playerId)

    local identifierType = Config.Identifier
    local identifier = GetPlayerIdentifierByType(playerId, identifierType)

    assert(identifier, ("[ESX] GetIdentifier failed: no identifier found for playerId %s with type '%s'"):format(playerId, identifierType))

    return identifier:gsub(("%s:"):format(identifierType), "")
end

---@param model string|number
---@param player number
---@param cb function?
---@return string?
---@diagnostic disable-next-line: duplicate-set-field
function ESX.GetVehicleType(model, player, cb)
    if cb and not ESX.IsFunctionReference(cb) then
        error("Invalid callback function")
    end

    local promise = not cb and promise.new()
    local function resolve(result)
        if promise then
            promise:resolve(result)
        elseif cb then
            cb(result)
        end

        return result
    end

    model = type(model) == "string" and joaat(model) or model

    if Core.vehicleTypesByModel[model] then
        return resolve(Core.vehicleTypesByModel[model])
    end

    ESX.TriggerClientCallback(player, "esx:GetVehicleType", function(vehicleType)
        Core.vehicleTypesByModel[model] = vehicleType
        resolve(vehicleType)
    end, model)

    if promise then
        return Citizen.Await(promise)
    end
end

---@param name string
---@param title string
---@param color string
---@param message string
---@return nil
function ESX.DiscordLog(name, title, color, message)
    local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
    local embedData = {
        {
            ["title"] = title,
            ["color"] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
            ["footer"] = {
                ["text"] = "| ESX Logs | " .. os.date(),
                ["icon_url"] =
                "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png",
            },
            ["description"] = message,
            ["author"] = {
                ["name"] = "ESX Framework",
                ["icon_url"] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless",
            },
        },
    }
    PerformHttpRequest(
        webHook,
        function()
            return
        end,
        "POST",
        json.encode({
            username = "Logs",
            embeds = embedData,
        }),
        {
            ["Content-Type"] = "application/json",
        }
    )
end

---@param name string
---@param title string
---@param color string
---@param fields table
---@return nil
function ESX.DiscordLogFields(name, title, color, fields)
    for i = 1, #fields do
        local field = fields[i]
        field.value = tostring(field.value)
    end

    local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
    local embedData = {
        {
            ["title"] = title,
            ["color"] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
            ["footer"] = {
                ["text"] = "| ESX Logs | " .. os.date(),
                ["icon_url"] =
                "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png",
            },
            ["fields"] = fields,
            ["description"] = "",
            ["author"] = {
                ["name"] = "ESX Framework",
                ["icon_url"] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless",
            },
        },
    }
    PerformHttpRequest(
        webHook,
        function()
            return
        end,
        "POST",
        json.encode({
            username = "Logs",
            embeds = embedData,
        }),
        {
            ["Content-Type"] = "application/json",
        }
    )
end

---@return nil
function ESX.RefreshJobs()
    Core.JobsLoaded = false

    local Jobs = {}
    local jobs = MySQL.query.await("SELECT * FROM jobs")

    for _, v in ipairs(jobs) do
        Jobs[v.name] = v
        Jobs[v.name].grades = {}
    end

    local jobGrades = MySQL.query.await("SELECT * FROM job_grades")

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
        ESX.Jobs["unemployed"] = { name = "unemployed", label = "Unemployed", whitelisted = false, grades = { ["0"] = { grade = 0, name = "unemployed", label = "Unemployed", salary = 200, skin_male = {}, skin_female = {} } } }
    else
        ESX.Jobs = Jobs
    end

    TriggerEvent("esx:jobsRefreshed")
    Core.JobsLoaded = true
end

---@param item string
---@param cb function
---@return nil
function ESX.RegisterUsableItem(item, cb)
    Core.UsableItemsCallbacks[item] = cb
end

---@param source number
---@param item string
---@param ... any
---@return nil
function ESX.UseItem(source, item, ...)
    if ESX.Items[item] then
        local itemCallback = Core.UsableItemsCallbacks[item]

        if itemCallback then
            local success, result = pcall(itemCallback, source, item, ...)

            if not success then
                return result and print(result) or
                print(('[^3WARNING^7] An error occured when using item ^5"%s"^7! This was not caused by ESX.'):format(
                item))
            end
        end
    else
        print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(item))
    end
end

---@param index string
---@param overrides table
---@return nil
function ESX.RegisterPlayerFunctionOverrides(index, overrides)
    Core.PlayerFunctionOverrides[index] = overrides
end

---@param index string
---@return nil
function ESX.SetPlayerFunctionOverride(index)
    if not index or not Core.PlayerFunctionOverrides[index] then
        return print("[^3WARNING^7] No valid index provided.")
    end

    Config.PlayerFunctionOverride = index
end

---@param item string
---@return string?
---@diagnostic disable-next-line: duplicate-set-field
function ESX.GetItemLabel(item)
    if ESX.Items[item] then
        return ESX.Items[item].label
    else
        print(("[^3WARNING^7] Attemting to get invalid Item -> ^5%s^7"):format(item))
    end
end

---@return table
function ESX.GetJobs()
    while not Core.JobsLoaded do
        Citizen.Wait(200)
    end

    return ESX.Jobs
end

---@return table
function ESX.GetItems()
    return ESX.Items
end

---@return table
function ESX.GetUsableItems()
    local Usables = {}
    for k in pairs(Core.UsableItemsCallbacks) do
        Usables[k] = true
    end
    return Usables
end

if not Config.CustomInventory then
    ---@param itemType string
    ---@param name string
    ---@param count integer
    ---@param label string
    ---@param playerId number
    ---@param components? string | table
    ---@param tintIndex? integer
    ---@param coords? table | vector3
    ---@return nil
    function ESX.CreatePickup(itemType, name, count, label, playerId, components, tintIndex, coords)
        local pickupId = (Core.PickupId == 65635 and 0 or Core.PickupId + 1)
        local xPlayer = ESX.Players[playerId]
        coords = ((type(coords) == "vector3" or type(coords) == "vector4") and coords.xyz or xPlayer.getCoords(true))

        Core.Pickups[pickupId] = { type = itemType, name = name, count = count, label = label, coords = coords }

        if itemType == "item_weapon" then
            Core.Pickups[pickupId].components = components
            Core.Pickups[pickupId].tintIndex = tintIndex
        end

        TriggerClientEvent("esx:createPickup", -1, pickupId, label, coords, itemType, name, components, tintIndex)
        Core.PickupId = pickupId
    end

    local function refreshPlayerInventories()
        local xPlayers = ESX.GetExtendedPlayers()
        for i = 1, #xPlayers do
            local xPlayer = xPlayers[i]
            local minimalInv = xPlayer.getInventory(true)

            for itemName, _ in pairs(minimalInv) do
                if not ESX.Items[itemName] then
                    xPlayer.setInventoryItem(itemName, 0)
                    minimalInv[itemName] = nil
                end
            end

            xPlayer.inventory = {}
            local playerInvIndex = 1
            for itemName, itemData in pairs(ESX.Items) do
                xPlayer.inventory[playerInvIndex] = {
                    name = itemName,
                    count = minimalInv[itemName] or 0,
                    label = itemData.label,
                    weight = itemData.weight,
                    usable = Core.UsableItemsCallbacks[itemName] ~= nil,
                    rare = itemData.rare,
                    canRemove = itemData.canRemove,
                }
                playerInvIndex += 1
            end

            TriggerClientEvent("esx:setInventory", xPlayer.source, xPlayer.inventory)
        end
    end

    ---@return number newItemCount
    function ESX.RefreshItems()
        ESX.Items = {}

        local items = MySQL.query.await("SELECT * FROM items")
        local itemCount = #items
        for i = 1, itemCount do
            local item = items[i]
            ESX.Items[item.name] = { label = item.label, weight = item.weight, rare = item.rare, canRemove = item
            .can_remove }
        end
        refreshPlayerInventories()

        return itemCount
    end

    ---@param items { name: string, label: string, weight?: number, rare?: boolean, canRemove?: boolean }[]
    function ESX.AddItems(items)
        local toInsert = {}
        local toInsertIndex = 1

        for i = 1, #items do
            local item = items[i]
            local name = item.name
            local label = item.label
            local weight = item.weight or 1
            local rare = item.rare or false
            local canRemove = item.canRemove ~= false

            if type(name) ~= "string" then
                print(("^1[AddItems]^0 Invalid item name: %s"):format(name))
                goto continue
            end

            if ESX.Items[name] then
                goto continue
            end

            if type(label) ~= "string" then
                print(("^1[AddItems]^0 Invalid label for item '%s'"):format(name))
                goto continue
            end

            if type(weight) ~= "number" then
                print(("^1[AddItems]^0 Invalid weight for item '%s'"):format(name))
                goto continue
            end

            if type(rare) ~= "boolean" then
                print(("^1[AddItems]^0 Invalid rare flag for item '%s'"):format(name))
                goto continue
            end

            if type(canRemove) ~= "boolean" then
                print(("^1[AddItems]^0 Invalid canRemove flag for item '%s'"):format(name))
                goto continue
            end

            toInsert[toInsertIndex] = {
                name = name,
                label = label,
                weight = weight,
                rare = rare,
                canRemove = canRemove,
            }
            toInsertIndex += 1

            ::continue::
        end

        if #toInsert > 0 then
            MySQL.prepare.await(
            "INSERT IGNORE INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES (?, ?, ?, ?, ?)",
                toInsert)

            for i = 1, #toInsert do
                local row = toInsert[i]
                ESX.Items[row.name] = {
                    label = row.label,
                    weight = row.weight,
                    rare = row.rare,
                    canRemove = row.canRemove,
                }
            end

            refreshPlayerInventories()
        end
    end
end

---@param job string
---@param grade string
---@return boolean
function ESX.DoesJobExist(job, grade)
    while not Core.JobsLoaded do
        Citizen.Wait(200)
    end

    return (ESX.Jobs[job] and ESX.Jobs[job].grades[tostring(grade)] ~= nil) or false
end

---@param playerSrc number
---@return boolean
function Core.IsPlayerAdmin(playerSrc)
    if type(playerSrc) ~= "number" then
        return false
    end

    if IsPlayerAceAllowed(playerSrc --[[@as string]], "command") or GetConvar("sv_lan", "") == "true" then
        return true
    end

    local xPlayer = ESX.GetPlayerFromId(playerSrc)
    return xPlayer and Config.AdminGroups[xPlayer.getGroup()] or false
end

-- Generates a unique 9-digit SSN in dashed format (XXX-XX-XXXX).
---@param skipUniqueCheck boolean?
---@return string
function Core.generateSSN(skipUniqueCheck)
    local reservedSSNs = {
        ["078-05-1120"] = true,
        ["219-09-9999"] = true,
        ["123-45-6789"] = true
    }

    while true do
        -- Generate the first part (area number)
        local area = math.random(1, 899)

        -- 666 is never assigned
        if area == 666 then
            goto continue
        end

        -- Generate the second part (group number)
        local group = math.random(1, 99)

        -- Generate the last part (serial number)
        local serial = math.random(1, 9999)

        -- Skip reserved SSN range (987-65-4320..4329)
        if area == 987 and group == 65 and serial >= 4320 and serial <= 4329 then
            goto continue
        end

        local candidate = string.format("%03d-%02d-%04d", area, group, serial)

        if reservedSSNs[candidate] then
            goto continue
        end

        if skipUniqueCheck then
            return candidate
        end

        local exists = MySQL.scalar.await("SELECT 1 FROM `users` WHERE `ssn` = ? LIMIT 1", { candidate })

        if not exists then
            return candidate
        end

        ::continue::
    end
end

---@param owner string
---@param plate string
---@param coords vector4
---@return CExtendedVehicle?
function ESX.CreateExtendedVehicle(owner, plate, coords)
    return Core.vehicleClass.new(owner, plate, coords)
end

---@param plate string
---@return CExtendedVehicle?
function ESX.GetExtendedVehicleFromPlate(plate)
    return Core.vehicleClass.getFromPlate(plate)
end
