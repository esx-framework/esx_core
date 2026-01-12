if Config.CustomInventory ~= "tgianninventory" then return end

Core.PlayerFunctionOverrides.TGIANNInventory = {

    setAccountMoney = function(self)
        return function(accountName, money, reason)
            reason = reason or "unknown"
            if not tonumber(money) then
                error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(
                    accountName, self.playerId, money))
                return
            end
            if money >= 0 then
                local account = self.getAccount(accountName)

                if account then
                    money = account.round and ESX.Math.Round(money) or money
                    self.accounts[account.index].money = money
                    if not forInventory then
                        local isMoneyItem, moneyItemName = exports["tgiann-inventory"]:IsMoneyItem(accountName)
                        if isMoneyItem then
                            exports["tgiann-inventory"]:SetItem(self.source, moneyItemName, money)
                        end
                    end

                    self.triggerEvent("esx:setAccountMoney", account)
                    TriggerEvent("esx:setAccountMoney", self.source, accountName, money, reason)
                else
                    error(("Tried To Set Invalid Account ^5%s^1 For Player ^5%s^1!"):format(accountName, self.playerId))
                end
            else
                error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(
                    accountName, self.playerId, money))
            end
        end
    end,

    addAccountMoney = function(self)
        return function(accountName, money, reason)
            reason = reason or "Unknown"
            if not tonumber(money) then
                error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(
                    accountName, self.playerId, money))
                return
            end
            if money > 0 then
                local account = self.getAccount(accountName)
                if account then
                    money = account.round and ESX.Math.Round(money) or money
                    self.accounts[account.index].money = self.accounts[account.index].money + money
                    local isMoneyItem, moneyItemName = exports["tgiann-inventory"]:IsMoneyItem(accountName)
                    if isMoneyItem then
                        exports["tgiann-inventory"]:SetItem(self.source, moneyItemName,
                            self.accounts[account.index].money)
                    end

                    self.triggerEvent("esx:setAccountMoney", account)
                    TriggerEvent("esx:addAccountMoney", self.source, accountName, money, reason)
                else
                    error(("Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!"):format(accountName,
                        self.playerId))
                end
            else
                error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(
                    accountName, self.playerId, money))
            end
        end
    end,

    removeAccountMoney = function(self)
        return function(accountName, money, reason)
            reason = reason or "Unknown"
            if not tonumber(money) then
                error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(
                    accountName, self.playerId, money))
                return
            end
            if money > 0 then
                local account = self.getAccount(accountName)

                if account then
                    money = account.round and ESX.Math.Round(money) or money
                    if self.accounts[account.index].money - money > self.accounts[account.index].money then
                        error(("Tried To Underflow Account ^5%s^1 For Player ^5%s^1!"):format(accountName, self.playerId))
                        return
                    end
                    self.accounts[account.index].money = self.accounts[account.index].money - money
                    local isMoneyItem, moneyItemName = exports["tgiann-inventory"]:IsMoneyItem(accountName)
                    if isMoneyItem then
                        exports["tgiann-inventory"]:SetItem(self.source, moneyItemName,
                            self.accounts[account.index].money)
                    end
                    self.triggerEvent("esx:setAccountMoney", account)
                    TriggerEvent("esx:removeAccountMoney", self.source, accountName, money, reason)
                else
                    error(("Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!"):format(accountName,
                        self.playerId))
                end
            else
                error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(
                    accountName, self.playerId, money))
            end
        end
    end,

    SetPlayerInventoryItems = function(self)
        return function(itemType, items)
            self[itemType] = items
            local stateBag = Player(self.source).state
            stateBag:set(itemType, items, true)
        end
    end,

    getInventory = function(self)
        return function(minimal)
            local inventory = exports["tgiann-inventory"]:GetPlayerItems(self.source)
            if not inventory then return {} end
            for _, v in pairs(inventory) do
                v.count = v.amount
            end
            return inventory
        end
    end,

    getLoadout = function(self)
        return function()
            return {}
        end
    end,

    getInventoryItem = function(self)
        return function(name, metadata)
            local item = exports["tgiann-inventory"]:GetItemByName(self.source, name, metadata)
            if not item then return { count = 0 } end
            item.count = item.amount
            return item
        end
    end,

    addInventoryItem = function(self)
        return function(name, count, metadata, slot)
            return exports["tgiann-inventory"]:AddItem(self.source, name, count or 1, slot, metadata)
        end
    end,

    removeInventoryItem = function(self)
        return function(name, count, metadata, slot)
            return exports["tgiann-inventory"]:RemoveItem(self.source, name, count, slot, metadata)
        end
    end,

    setInventoryItem = function(self)
        return function(name, count, metadata)
            return exports["tgiann-inventory"]:SetItem(self.source, name, count)
        end
    end,

    canCarryItem = function(self)
        return function(name, count, metadata)
            return exports["tgiann-inventory"]:CanCarryItem(self.source, name, count)
        end
    end,

    canSwapItem = function(self)
        return function(firstItem, firstItemCount, testItem, testItemCount)
            return true
        end
    end,

    setMaxWeight = function(self)
        return function(newWeight)
            self.maxWeight = newWeight
            self.triggerEvent("esx:setMaxWeight", self.maxWeight)
            exports["tgiann-inventory"]:SetMaxWeight(self.source, newWeight)
        end
    end,

    addWeapon = function(self)
        return function() end
    end,

    addWeaponComponent = function(self)
        return function() end
    end,

    addWeaponAmmo = function(self)
        return function() end
    end,

    updateWeaponAmmo = function(self)
        return function() end
    end,

    setWeaponTint = function(self)
        return function() end
    end,

    getWeaponTint = function(self)
        return function() end
    end,

    removeWeapon = function(self)
        return function() end
    end,

    removeWeaponComponent = function(self)
        return function() end
    end,

    removeWeaponAmmo = function(self)
        return function() end
    end,

    hasWeaponComponent = function(self)
        return function()
            return false
        end
    end,

    hasWeapon = function(self)
        return function()
            return false
        end
    end,

    hasItem = function(self)
        return function(name, metadata)
            return exports["tgiann-inventory"]:HasItem(self.source, name)
        end
    end,

    getWeapon = function(self)
        return function() end
    end
}
