---@param items string | table The item(s) to search for
---@param count? boolean Whether to return the count of the item as well
---@return table | number
function ESX.SearchInventory(items, count)
    local item
    if type(items) == 'string' then
        item, items = items, { items }
    end

    local data = {}
    for i = 1, #ESX.PlayerData.inventory do
        local e = ESX.PlayerData.inventory[i]
        for ii = 1, #items do
            if e.name == items[ii] then
                data[table.remove(items, ii)] = count and e.count or e
                break
            end
        end
        if #items == 0 then
            break
        end
    end

    return not item and data or data[item]
end

if not Config.EnableDefaultInventory then
    function ESX.ShowInventory()
        error("Default Inventory is disabled.")
    end
    -- Dont continue if the default inventory is disabled
    return
end

---@return nil
function ESX.ShowInventory()
    if not Config.EnableDefaultInventory then
        return
    end

    local playerPed = ESX.PlayerData.ped
    local elements = {
        { unselectable = true, icon = "fas fa-box" },
    }
    local currentWeight = 0

    for i = 1, #ESX.PlayerData.accounts do
        if ESX.PlayerData.accounts[i].money > 0 then
            local formattedMoney = TranslateCap("locale_currency", ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money))
            local canDrop = ESX.PlayerData.accounts[i].name ~= "bank"

            elements[#elements + 1] = {
                icon = "fas fa-money-bill-wave",
                title = ('%s: <span style="color:green;">%s</span>'):format(ESX.PlayerData.accounts[i].label, formattedMoney),
                count = ESX.PlayerData.accounts[i].money,
                type = "item_account",
                value = ESX.PlayerData.accounts[i].name,
                usable = false,
                rare = false,
                canRemove = canDrop,
            }
        end
    end

    for i = 1, #ESX.PlayerData.inventory do
        local v = ESX.PlayerData.inventory[i]
        if v.count > 0 then
            currentWeight = currentWeight + (v.weight * v.count)

            elements[#elements + 1] = {
                icon = "fas fa-box",
                title = ("%s x%s"):format(v.label, v.count),
                count = v.count,
                type = "item_standard",
                value = v.name,
                usable = v.usable,
                rare = v.rare,
                canRemove = v.canRemove,
            }
        end
    end

    elements[1].title = TranslateCap("inventory", currentWeight, Config.MaxWeight)

    for i = 1, #Config.Weapons do
        local v = Config.Weapons[i]
        local weaponHash = joaat(v.name)

        if HasPedGotWeapon(playerPed, weaponHash, false) then
            local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)

            elements[#elements + 1] = {
                icon = "fas fa-gun",
                title = v.ammo and ("%s - %s %s"):format(v.label, ammo, v.ammo.label) or v.label,
                count = 1,
                type = "item_weapon",
                value = v.name,
                usable = false,
                rare = false,
                ammo = ammo,
                canGiveAmmo = (v.ammo ~= nil),
                canRemove = true,
            }
        end
    end

    ESX.CloseContext()

    ESX.OpenContext("right", elements, function(_, element)
        local player, distance = ESX.Game.GetClosestPlayer()

        local elements2 = {}

        if element.usable then
            elements2[#elements2 + 1] = {
                icon = "fas fa-utensils",
                title = TranslateCap("use"),
                action = "use",
                type = element.type,
                value = element.value,
            }
        end

        if element.canRemove then
            if player ~= -1 and distance <= 3.0 then
                elements2[#elements2 + 1] = {
                    icon = "fas fa-hands",
                    title = TranslateCap("give"),
                    action = "give",
                    type = element.type,
                    value = element.value,
                }
            end

            elements2[#elements2 + 1] = {
                icon = "fas fa-trash",
                title = TranslateCap("remove"),
                action = "remove",
                type = element.type,
                value = element.value,
            }
        end

        if element.type == "item_weapon" and element.canGiveAmmo and element.ammo > 0 and player ~= -1 and distance <= 3.0 then
            elements2[#elements2 + 1] = {
                icon = "fas fa-gun",
                title = TranslateCap("giveammo"),
                action = "give_ammo",
                type = element.type,
                value = element.value,
            }
        end

        elements2[#elements2 + 1] = {
            icon = "fas fa-arrow-left",
            title = TranslateCap("return"),
            action = "return",
        }

        ESX.OpenContext("right", elements2, function(_, element2)
            local item, itemType = element2.value, element2.type

            if element2.action == "give" then
                local playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)

                if #playersNearby > 0 then
                    local players = {}
                    local elements3 = {
                        { unselectable = true, icon = "fas fa-users", title = "Nearby Players" },
                    }

                    for currentNearbyPlayerIndex = 1, #playersNearby do
                        players[GetPlayerServerId(playersNearby[currentNearbyPlayerIndex])] = true
                    end

                    ESX.TriggerServerCallback("esx:getPlayerNames", function(returnedPlayers)
                        for playerId, playerName in pairs(returnedPlayers) do
                            elements3[#elements3 + 1] = {
                                icon = "fas fa-user",
                                title = playerName,
                                playerId = playerId,
                            }
                        end

                        ESX.OpenContext("right", elements3, function(_, element3)
                            local selectedPlayer, selectedPlayerId = GetPlayerFromServerId(element3.playerId), element3.playerId
                            playersNearby = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
                            playersNearby = ESX.Table.Set(playersNearby)

                            if playersNearby[selectedPlayer] then
                                local selectedPlayerPed = GetPlayerPed(selectedPlayer)

                                if IsPedOnFoot(selectedPlayerPed) and not IsPedFalling(selectedPlayerPed) then
                                    if itemType == "item_weapon" then
                                        TriggerServerEvent("esx:giveInventoryItem", selectedPlayerId, itemType, item, nil)
                                        ESX.CloseContext()
                                    else
                                        local elementsG = {
                                            { unselectable = true,          icon = "fas fa-trash", title = element.title },
                                            { icon = "fas fa-tally",        title = "Amount.",     input = true,         inputType = "number", inputPlaceholder = "Amount to give..", inputMin = 1, inputMax = 1000 },
                                            { icon = "fas fa-check-double", title = "Confirm",     val = "confirm" },
                                        }

                                        ESX.OpenContext("right", elementsG, function(menuG, _)
                                            local quantity = tonumber(menuG.eles[2].inputValue)

                                            if quantity and quantity > 0 and element.count >= quantity then
                                                TriggerServerEvent("esx:giveInventoryItem", selectedPlayerId, itemType, item, quantity)
                                                ESX.CloseContext()
                                            else
                                                ESX.ShowNotification(TranslateCap("amount_invalid"))
                                            end
                                        end)
                                    end
                                else
                                    ESX.ShowNotification(TranslateCap("in_vehicle"))
                                end
                            else
                                ESX.ShowNotification(TranslateCap("players_nearby"))
                                ESX.CloseContext()
                            end
                        end)
                    end, players)
                end
            elseif element2.action == "remove" then
                if IsPedOnFoot(playerPed) and not IsPedFalling(playerPed) then
                    local dict, anim = "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@", "plant_floor"
                    ESX.Streaming.RequestAnimDict(dict)

                    if itemType == "item_weapon" then
                        ESX.CloseContext()
                        TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                        RemoveAnimDict(dict)
                        Wait(1000)
                        TriggerServerEvent("esx:removeInventoryItem", itemType, item)
                    else
                        local elementsR = {
                            { unselectable = true,          icon = "fas fa-trash", title = element.title },
                            { icon = "fas fa-tally",        title = "Amount.",     input = true,         inputType = "number", inputPlaceholder = "Amount to remove..", inputMin = 1, inputMax = 1000 },
                            { icon = "fas fa-check-double", title = "Confirm",     val = "confirm" },
                        }

                        ESX.OpenContext("right", elementsR, function(menuR, _)
                            local quantity = tonumber(menuR.eles[2].inputValue)

                            if quantity and quantity > 0 and element.count >= quantity then
                                ESX.CloseContext()
                                TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
                                RemoveAnimDict(dict)
                                Wait(1000)
                                TriggerServerEvent("esx:removeInventoryItem", itemType, item, quantity)
                            else
                                ESX.ShowNotification(TranslateCap("amount_invalid"))
                            end
                        end)
                    end
                end
            elseif element2.action == "use" then
                ESX.CloseContext()
                TriggerServerEvent("esx:useItem", item)
            elseif element2.action == "return" then
                ESX.CloseContext()
                ESX.ShowInventory()
            elseif element2.action == "give_ammo" then
                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                local closestPed = GetPlayerPed(closestPlayer)
                local pedAmmo = GetAmmoInPedWeapon(playerPed, joaat(item))

                if IsPedOnFoot(closestPed) and not IsPedFalling(closestPed) then
                    if closestPlayer ~= -1 and closestDistance < 3.0 then
                        if pedAmmo > 0 then
                            local elementsGA = {
                                { unselectable = true,          icon = "fas fa-trash", title = element.title },
                                { icon = "fas fa-tally",        title = "Amount.",     input = true,         inputType = "number", inputPlaceholder = "Amount to give..", inputMin = 1, inputMax = 1000 },
                                { icon = "fas fa-check-double", title = "Confirm",     val = "confirm" },
                            }

                            ESX.OpenContext("right", elementsGA, function(menuGA, _)
                                local quantity = tonumber(menuGA.eles[2].inputValue)

                                if quantity and quantity > 0 then
                                    if pedAmmo >= quantity then
                                        TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(closestPlayer), "item_ammo", item, quantity)
                                        ESX.CloseContext()
                                    else
                                        ESX.ShowNotification(TranslateCap("noammo"))
                                    end
                                else
                                    ESX.ShowNotification(TranslateCap("amount_invalid"))
                                end
                            end)
                        else
                            ESX.ShowNotification(TranslateCap("noammo"))
                        end
                    else
                        ESX.ShowNotification(TranslateCap("players_nearby"))
                    end
                else
                    ESX.ShowNotification(TranslateCap("in_vehicle"))
                end
            end
        end)
    end)
end

ESX.RegisterInput("showinv", TranslateCap("keymap_showinventory"), "keyboard", "F2", function()
    if not ESX.PlayerData.dead then
        ESX.ShowInventory()
    end
end)

ESX.SecureNetEvent("esx:addInventoryItem", function(item, count, showNotification)
    for k, v in ipairs(ESX.PlayerData.inventory) do
        if v.name == item then
            ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
            ESX.PlayerData.inventory[k].count = count
            break
        end
    end

    if showNotification then
        ESX.UI.ShowInventoryItemNotification(true, item, count)
    end
end)

ESX.SecureNetEvent("esx:removeInventoryItem", function(item, count, showNotification)
    for i = 1, #ESX.PlayerData.inventory do
        if ESX.PlayerData.inventory[i].name == item then
            ESX.UI.ShowInventoryItemNotification(false, ESX.PlayerData.inventory[i].label, ESX.PlayerData.inventory[i].count - count)
            ESX.PlayerData.inventory[i].count = count
            break
        end
    end

    if showNotification then
        ESX.UI.ShowInventoryItemNotification(false, item, count)
    end
end)

RegisterNetEvent("esx:addWeapon", function()
    error("event ^5'esx:addWeapon'^1 Has Been Removed. Please use ^5xPlayer.addWeapon^1 Instead!")
end)


RegisterNetEvent("esx:addWeaponComponent", function()
    error("event ^5'esx:addWeaponComponent'^1 Has Been Removed. Please use ^5xPlayer.addWeaponComponent^1 Instead!")
end)

RegisterNetEvent("esx:setWeaponAmmo", function()
    error("event ^5'esx:setWeaponAmmo'^1 Has Been Removed. Please use ^5xPlayer.addWeaponAmmo^1 Instead!")
end)

ESX.SecureNetEvent("esx:setWeaponTint", function(weapon, weaponTintIndex)
    SetPedWeaponTintIndex(ESX.PlayerData.ped, joaat(weapon), weaponTintIndex)
end)

RegisterNetEvent("esx:removeWeapon", function()
    error("event ^5'esx:removeWeapon'^1 Has Been Removed. Please use ^5xPlayer.removeWeapon^1 Instead!")
end)

ESX.SecureNetEvent("esx:removeWeaponComponent", function(weapon, weaponComponent)
    local componentHash = ESX.GetWeaponComponent(weapon, weaponComponent).hash
    RemoveWeaponComponentFromPed(ESX.PlayerData.ped, joaat(weapon), componentHash)
end)
