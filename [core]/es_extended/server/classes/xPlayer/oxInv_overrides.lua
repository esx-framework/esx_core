local Inventory

-- Event Handlers

AddEventHandler('ox_inventory:loadInventory', function(module)
    Inventory = module
end)

-- Main Code

do
    IsAuthorized[#IsAuthorized+1] = true

    XPlayerClass.getInventory = function(xPlayer, minimal)
        if not minimal then
            return xPlayer.inventory
        end

        local minimalInventory = {}

        for i=1, #xPlayer.inventory do
            local curr <const> = xPlayer.inventory[i]
            if curr.count and curr.count > 0 then
                minimalInventory[#minimalInventory + 1] = {
                    name = curr.name,
                    count = curr.count,
                    slot = i,
                }
            end
        end

        return minimalInventory
    end

    XPlayerClass.getLoadout = function()
        return {}
    end

    XPlayerClass.setAccountMoney = function(xPlayer, accountName, money, reason)
        reason = reason or 'unknown'
        if money < 0 then return end
        local account = xPlayer.getAccount(accountName)

        if not account then return end

        money = account.round and ESX.Math.Round(money) or money
        xPlayer.accounts[account.index].money = money

        xPlayer.triggerEvent('esx:setAccountMoney', account)
        TriggerEvent('esx:setAccountMoney', xPlayer.source, accountName, money, reason)
        if Inventory.accounts[accountName] then
            Inventory.SetItem(xPlayer.source, accountName, money)
        end
    end

    XPlayerClass.addAccountMoney = function(xPlayer, accountName, money, reason)
        reason = reason or 'unknown'
        if money < 1 then return end

        local account = xPlayer.getAccount(accountName)
        if not account then return end

        money = account.round and ESX.Math.Round(money) or money
        xPlayer.accounts[account.index].money = xPlayer.accounts[account.index].money + money
        xPlayer.triggerEvent('esx:setAccountMoney', account)
        TriggerEvent('esx:addAccountMoney', xPlayer.source, accountName, money, reason)
        if Inventory.accounts[accountName] then
            Inventory.AddItem(xPlayer.source, accountName, money)
        end
    end

    XPlayerClass.removeAccountMoney = function(xPlayer, accountName, money, reason)
        reason = reason or 'unknown'
        if money < 1 then return end

        local account = xPlayer.getAccount(accountName)
        if not account then return end

        money = account.round and ESX.Math.Round(money) or money
        xPlayer.accounts[account.index].money = xPlayer.accounts[account.index].money - money
        xPlayer.triggerEvent('esx:setAccountMoney', account)
        TriggerEvent('esx:removeAccountMoney', xPlayer.source, accountName, money, reason)
        if Inventory.accounts[accountName] then
            Inventory.RemoveItem(xPlayer.source, accountName, money)
        end
    end

    XPlayerClass.getInventoryItem = function(xPlayer, name, metadata)
        return Inventory.GetItem(xPlayer.source, name, metadata)
    end

    do
        local modules <const> = { 'add', 'remove', 'set' }
        for i=1, #modules do
            local curr <const> = modules[i]
            XPlayerClass[('%sInventoryItem'):format(curr)] = function(xPlayer, ...) ---@diagnostic disable-line: param-type-mismatch
                local params = { ... }

                if i ~= 3 then params[2] = params[2] or 1 end

                return Inventory[('%s%sItem'):format(curr:sub(1,1):upper(), curr:sub(2, #curr))](xPlayer.source, table.unpack(params))
            end
        end
    end

    XPlayerClass.canCarryItem = function(xPlayer, name, count, metadata)
        return Inventory.CanCarryItem(xPlayer.source, name, count, metadata)
    end

    XPlayerClass.canSwapItem = function(xPlayer, firstItem, firstItemCount, testItem, testItemCount)
        return Inventory.CanSwapItem(xPlayer.source, firstItem, firstItemCount, testItem, testItemCount)
    end

    XPlayerClass.setMaxWeight = function(xPlayer, newWeight)
        xPlayer.maxWeight = newWeight
        xPlayer.triggerEvent('esx:setMaxWeight', xPlayer.maxWeight)
        return Inventory.SetMaxWeight(xPlayer.source, newWeight)
    end

    do
        local modules <const> = { 'addWeapon', 'addWeaponComponent', 'addWeaponAmmo', 'addWeaponAmmo', 'updateWeaponAmmo', 'setWeaponTint', 'getWeaponTint', 'removeWeapon', 'removeWeaponComponent', 'removeWeaponAmmo', 'getWeapon', 'hasWeaponComponent', 'hasWeapon' }
        for i=1, #modules do
            XPlayerClass[modules[i]] = i <= (#modules - 2) and function()end or function() return false end
        end
    end

    XPlayerClass.hasItem = function(xPlayer, name, metadata)
        return Inventory.GetItem(xPlayer.source, name, metadata)
    end

    table.remove(IsAuthorized, #IsAuthorized)
end