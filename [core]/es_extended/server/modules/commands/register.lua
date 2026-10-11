-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

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

    local previousCommand = Core.RegisteredCommands[name]
    local isOverride = previousCommand ~= nil

    local function forEachGroup(commandGroup, cbForGroup)
        if type(commandGroup) == "table" then
            for _, v in ipairs(commandGroup) do
                cbForGroup(v)
            end
        else
            cbForGroup(commandGroup)
        end
    end

    if isOverride then
        print(('[^3WARNING^7] Command ^5"%s" ^7already registered, overriding command'):format(name))

        if previousCommand.suggestion then
            TriggerClientEvent("chat:removeSuggestion", -1, ("/%s"):format(name))
        end

        forEachGroup(previousCommand.group, function(v)
            ExecuteCommand(("remove_ace group.%s command.%s allow"):format(v, name))
        end)
    end

    if suggestion then
        suggestion.arguments = suggestion.arguments or {}
        suggestion.help = suggestion.help or ""

        TriggerClientEvent("chat:addSuggestion", -1, ("/%s"):format(name), suggestion.help, suggestion.arguments)
    end

    Core.RegisteredCommands[name] = { group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion }

    forEachGroup(group, function(v)
        ExecuteCommand(("add_ace group.%s command.%s allow"):format(v, name))
    end)

    if isOverride then
        return
    end

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

                                newArgs[v.name] = string.sub(merge, length + 1)
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

                        -- Backwards compatibility.
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
                command.cb(xPlayer or false, args, function(msg)
                    if playerId == 0 then
                        print(("[^3WARNING^7] %s^7"):format(msg))
                    else
                        xPlayer.showNotification(msg)
                    end
                end)
            end
        end
    end, true)
end
