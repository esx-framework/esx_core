local OxInventory

if Config.CustomInventory ~= "ox" then
    return
end

local requiredMethods = {
    "GetItem",
    "AddItem",
    "RemoveItem",
    "SetItem",
    "CanCarryItem",
    "CanSwapItem",
    "SetMaxWeight",
}

---Parses the inventory:accounts convar to build a lookup table.
---Uses the same default and JSON format as ox_inventory ["money", "black_money"].
---@return table<string, boolean>
local function getAccountList()
    local convar = GetConvar("inventory:accounts", '["money", "black_money"]')
    local ok, list = pcall(json.decode, convar)

    if not ok or type(list) ~= "table" then
        error(
            ("[es_extended] Invalid inventory:accounts convar: %s")
                :format(tostring(convar)),
            2
        )
    end

    local accounts = {}

    for i = 1, #list do
        local account = list[i]

        if type(account) == "string" and account ~= "" then
            accounts[account] = true
        end
    end

    return accounts
end

---Safely resolves an ox_inventory export without executing it.
---@param resourceExports table
---@param method string
---@return function
local function resolveExport(resourceExports, method)
    local ok, exportFn = pcall(function()
        return resourceExports[method]
    end)

    if not ok then
        error(
            ("[es_extended] Missing required ox_inventory export '%s': %s")
                :format(method, tostring(exportFn)),
            2
        )
    end

    if type(exportFn) ~= "function" then
        error(
            ("[es_extended] Invalid ox_inventory export '%s' (expected function, got %s)")
                :format(method, type(exportFn)),
            2
        )
    end

    return exportFn
end

---Creates a proxy table that routes method calls to public ox_inventory exports.
---@return table
local function createOxInventoryProxy()
    local proxy = {}
    local resourceExports = exports.ox_inventory

    print("^3[es_extended] ox_inventory: using direct export proxy (Inventory() interface unavailable or incomplete)^7")

    for i = 1, #requiredMethods do
        local method = requiredMethods[i]
        local exportFn = resolveExport(resourceExports, method)

        proxy[method] = function(...)
            return exportFn(resourceExports, ...)
        end
    end

    proxy.accounts = getAccountList()

    return proxy
end

---Checks if an Inventory() module provides everything ESX requires.
---@param module table
---@return boolean
local function isValidModule(module)
    if type(module) ~= "table" then
        return false
    end

    for i = 1, #requiredMethods do
        if type(module[requiredMethods[i]]) ~= "function" then
            return false
        end
    end

    if type(module.accounts) ~= "table" then
        return false
    end

    return true
end

---Returns the ox_inventory interface.
---Uses Inventory() when available, otherwise falls back to public exports.
---@return table
local function getOxInventory()
    if OxInventory then
        return OxInventory
    end

    local state = GetResourceState("ox_inventory")

    if state ~= "started" then
        error(
            ("[es_extended] ox_inventory not started; current status: %s")
                :format(tostring(state)),
            2
        )
    end

    local success, module = pcall(function()
        return exports.ox_inventory:Inventory()
    end)

    if success and isValidModule(module) then
        OxInventory = module
    else
        OxInventory = createOxInventoryProxy()
    end

    return OxInventory
end

-- Standard method used when ox_inventory finishes loading.
AddEventHandler("ox_inventory:loadInventory", function(module)
    if isValidModule(module) then
        OxInventory = module
    else
        OxInventory = createOxInventoryProxy()
    end
end)

-- Standard method used when ox_inventory is stopped.
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == "ox_inventory" then
        OxInventory = nil
    end
end)

local function emptyMethod()
    return function() end
end

local function falseMethod()
    return function()
        return false
    end
end

Core.PlayerFunctionOverrides.OxInventory = {
    getInventory = function(self)
        return function(minimal)
            if not minimal then
                return self.inventory
            end

            local result = {}

            for slot, item in pairs(self.inventory) do
                if item.count and item.count > 0 then
                    local metadata = item.metadata

                    if type(metadata) == "table" and next(metadata) == nil then
                        metadata = nil
                    end

                    result[#result + 1] = {
                        name = item.name,
                        count = item.count,
                        slot = slot,
                        metadata = metadata,
                    }
                end
            end

            return result
        end
    end,

    getLoadout = function()
        return function()
            return {}
        end
    end,

    setAccountMoney = function(self)
        return function(accountName, money, reason)
            reason = reason or "unknown"

            if money < 0 then
                return
            end

            local account = self.getAccount(accountName)

            if not account then
                return
            end

            money = account.round and ESX.Math.Round(money) or money
            self.accounts[account.index].money = money

            self.triggerEvent("esx:setAccountMoney", account)
            TriggerEvent(
                "esx:setAccountMoney",
                self.source,
                accountName,
                money,
                reason
            )

            local inventory = getOxInventory()

            if inventory.accounts[accountName] then
                inventory.SetItem(self.source, accountName, money)
            end
        end
    end,

    addAccountMoney = function(self)
        return function(accountName, money, reason)
            reason = reason or "unknown"

            if money < 1 then
                return
            end

            local account = self.getAccount(accountName)

            if not account then
                return
            end

            money = account.round and ESX.Math.Round(money) or money
            self.accounts[account.index].money =
                self.accounts[account.index].money + money

            self.triggerEvent("esx:setAccountMoney", account)
            TriggerEvent(
                "esx:addAccountMoney",
                self.source,
                accountName,
                money,
                reason
            )

            local inventory = getOxInventory()

            if inventory.accounts[accountName] then
                inventory.AddItem(self.source, accountName, money)
            end
        end
    end,

    removeAccountMoney = function(self)
        return function(accountName, money, reason)
            reason = reason or "unknown"

            if money < 1 then
                return
            end

            local account = self.getAccount(accountName)

            if not account then
                return
            end

            money = account.round and ESX.Math.Round(money) or money
            self.accounts[account.index].money =
                self.accounts[account.index].money - money

            self.triggerEvent("esx:setAccountMoney", account)
            TriggerEvent(
                "esx:removeAccountMoney",
                self.source,
                accountName,
                money,
                reason
            )

            local inventory = getOxInventory()

            if inventory.accounts[accountName] then
                inventory.RemoveItem(self.source, accountName, money)
            end
        end
    end,

    getInventoryItem = function(self)
        return function(name, metadata)
            return getOxInventory().GetItem(
                self.source,
                name,
                metadata
            )
        end
    end,

    addInventoryItem = function(self)
        return function(name, count, metadata, slot)
            return getOxInventory().AddItem(
                self.source,
                name,
                count or 1,
                metadata,
                slot
            )
        end
    end,

    removeInventoryItem = function(self)
        return function(name, count, metadata, slot)
            return getOxInventory().RemoveItem(
                self.source,
                name,
                count or 1,
                metadata,
                slot
            )
        end
    end,

    setInventoryItem = function(self)
        return function(name, count, metadata)
            return getOxInventory().SetItem(
                self.source,
                name,
                count,
                metadata
            )
        end
    end,

    canCarryItem = function(self)
        return function(name, count, metadata)
            return getOxInventory().CanCarryItem(
                self.source,
                name,
                count,
                metadata
            )
        end
    end,

    canSwapItem = function(self)
        return function(firstItem, firstItemCount, testItem, testItemCount)
            return getOxInventory().CanSwapItem(
                self.source,
                firstItem,
                firstItemCount,
                testItem,
                testItemCount
            )
        end
    end,

    setMaxWeight = function(self)
        return function(newWeight)
            self.maxWeight = newWeight
            self.triggerEvent("esx:setMaxWeight", self.maxWeight)

            return getOxInventory().SetMaxWeight(
                self.source,
                newWeight
            )
        end
    end,

    addWeapon = emptyMethod,
    addWeaponComponent = emptyMethod,
    addWeaponAmmo = emptyMethod,
    updateWeaponAmmo = emptyMethod,
    setWeaponTint = emptyMethod,
    getWeaponTint = emptyMethod,
    removeWeapon = emptyMethod,
    removeWeaponComponent = emptyMethod,
    removeWeaponAmmo = emptyMethod,

    hasWeaponComponent = falseMethod,
    hasWeapon = falseMethod,

    hasItem = function(self)
        return function(name, metadata)
            local item = getOxInventory().GetItem(
                self.source,
                name,
                metadata
            )

            if not item or not item.count or item.count < 1 then
                return false
            end

            return item, item.count
        end
    end,

    getWeapon = emptyMethod,

    syncInventory = function(self)
        return function(weight, maxWeight, items, money)
            self.weight = weight
            self.maxWeight = maxWeight
            self.inventory = items

            if not money then
                return
            end

            for accountName, amount in pairs(money) do
                local account = self.getAccount(accountName)

                if account and ESX.Math.Round(account.money) ~= amount then
                    account.money = amount

                    self.triggerEvent("esx:setAccountMoney", account)
                    TriggerEvent(
                        "esx:setAccountMoney",
                        self.source,
                        accountName,
                        amount,
                        "Sync account with item"
                    )
                end
            end
        end
    end,
}