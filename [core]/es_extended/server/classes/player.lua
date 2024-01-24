local _GetPlayerPed = GetPlayerPed
local _GetEntityCoords = GetEntityCoords
local _ExecuteCommand = ExecuteCommand
local _SetEntityCoords = SetEntityCoords
local _SetEntityHeading = SetEntityHeading
local _TriggerClientEvent = TriggerClientEvent
local _DropPlayer = DropPlayer
local _TriggerEvent = TriggerEvent
local _GiveWeaponToPed = GiveWeaponToPed
local _SetPedAmmo = SetPedAmmo
local _RemoveWeaponFromPed = RemoveWeaponFromPed
local _assert = assert

---@param playerId number
---@param identifier string
---@param group string
---@param accounts table
---@param inventory table
---@param weight number
---@param job table
---@param loadout table
---@param name string
---@param coords table | vector4
---@param metadata table
function CreateExtendedPlayer(playerId, identifier, group, accounts, inventory, weight, job, loadout, name, coords, metadata)
    local targetOverrides = Config.PlayerFunctionOverride and Core.PlayerFunctionOverrides[Config.PlayerFunctionOverride] or {}

    local self = {}

    self.accounts = accounts
    self.coords = coords
    self.group = group
    self.identifier = identifier
    self.inventory = inventory
    self.job = job
    self.loadout = loadout
    self.name = name
    self.playerId = playerId
    self.source = playerId
    self.variables = {}
    self.weight = weight
    self.maxWeight = Config.MaxWeight
    self.metadata = metadata
    self.admin = Core.IsPlayerAdmin(playerId)
    if Config.Multichar then
        self.license = "license" .. identifier:sub(identifier:find(":"), identifier:len())
    else
        self.license = "license:" .. identifier
    end

    _ExecuteCommand(("add_principal identifier.%s group.%s"):format(self.license, self.group))

    local stateBag = Player(self.source).state
    stateBag:set("identifier", self.identifier, true)
    stateBag:set("license", self.license, true)
    stateBag:set("job", self.job, true)
    stateBag:set("group", self.group, true)
    stateBag:set("name", self.name, true)
    stateBag:set("metadata", self.metadata, true)

    ---@param eventName string
    ---@param ... any
    ---@return void
    function self.triggerEvent(eventName, ...)
        _assert(type(eventName) == "string", "eventName should be string!")
        _TriggerClientEvent(eventName, self.source, ...)
    end

    ---@param coordinates vector4 | vector3 | table
    ---@return void
    function self.setCoords(coordinates)
        local ped <const> = _GetPlayerPed(self.source)
        local vector = type(coordinates) == "vector4" and coordinates or type(coordinates) == "vector3" and vector4(coordinates, 0.0) or vec(coordinates.x, coordinates.y, coordinates.z, coordinates.heading or 0.0)
        _SetEntityCoords(ped, vector.xyz, false, false, false, false)
        _SetEntityHeading(ped, vector.w)
    end

    ---@param vector boolean
    ---@return vector3 | table
    function self.getCoords(vector)
        local ped <const> = _GetPlayerPed(self.source)
        local coordinates <const> = _GetEntityCoords(ped)

        return vector and coordinates or { x = coordinates.x, y = coordinates.y, z = coordinates.z }
    end

    ---@param reason string
    ---@return void
    function self.kick(reason)
        _DropPlayer(self.source, reason)
    end

    ---@param money number
    ---@return void
    function self.setMoney(money)
        _assert(type(money) == "number", "money should be number!")
        money = ESX.Math.Round(money)
        self.setAccountMoney("money", money)
    end

    ---@return number
    function self.getMoney()
        return self.getAccount("money").money
    end

    ---@param money number
    ---@param reason string
    ---@return void
    function self.addMoney(money, reason)
        money = ESX.Math.Round(money)
        self.addAccountMoney("money", money, reason)
    end

    ---@param money number
    ---@param reason string
    ---@return void
    function self.removeMoney(money, reason)
        money = ESX.Math.Round(money)
        self.removeAccountMoney("money", money, reason)
    end

    ---@return string
    function self.getIdentifier()
        return self.identifier
    end

    ---@param newGroup string
    ---@return void
    function self.setGroup(newGroup)
        _ExecuteCommand(("remove_principal identifier.%s group.%s"):format(self.license, self.group))
        self.group = newGroup
        Player(self.source).state:set("group", self.group, true)
        _ExecuteCommand(("add_principal identifier.%s group.%s"):format(self.license, self.group))
    end

    ---@return string
    function self.getGroup()
        return self.group
    end

    ---@param k string
    ---@param v any
    ---@return void
    function self.set(k, v)
        self.variables[k] = v
        Player(self.source).state:set(k, v, true)
    end

    ---@param k string
    ---@return any
    function self.get(k)
        return self.variables[k]
    end

    ---@param minimal boolean
    ---@return table
    function self.getAccounts(minimal)
        if not minimal then
            return self.accounts
        end

        local minimalAccounts = {}

        for i = 1, #self.accounts do
            minimalAccounts[self.accounts[i].name] = self.accounts[i].money
        end

        return minimalAccounts
    end

    ---@param account string
    ---@return table | nil
    function self.getAccount(account)
        for i = 1, #self.accounts do
            if self.accounts[i].name == account then
                return self.accounts[i]
            end
        end
        return nil
    end

    ---@param minimal boolean
    ---@return table
    function self.getInventory(minimal)
        if minimal then
            local minimalInventory = {}

            for _, v in ipairs(self.inventory) do
                if v.count > 0 then
                    minimalInventory[v.name] = v.count
                end
            end

            return minimalInventory
        end

        return self.inventory
    end

    ---@return table
    function self.getJob()
        return self.job
    end

    ---@param minimal boolean
    ---@return table
    function self.getLoadout(minimal)
        if not minimal then
            return self.loadout
        end
        local minimalLoadout = {}

        for _, v in ipairs(self.loadout) do
            minimalLoadout[v.name] = { ammo = v.ammo }
            if v.tintIndex > 0 then
                minimalLoadout[v.name].tintIndex = v.tintIndex
            end

            if #v.components > 0 then
                local components = {}

                for _, component in ipairs(v.components) do
                    if component ~= "clip_default" then
                        components[#components + 1] = component
                    end
                end

                if #components > 0 then
                    minimalLoadout[v.name].components = components
                end
            end
        end

        return minimalLoadout
    end

    ---@return string
    function self.getName()
        return self.name
    end

    ---@param newName string
    ---@return void
    function self.setName(newName)
        self.name = newName
        Player(self.source).state:set("name", self.name, true)
    end

    ---@param accountName string
    ---@param money number
    ---@param reason string
    ---@return void
    function self.setAccountMoney(accountName, money, reason)
        reason = reason or "unknown"
        if not tonumber(money) then
            print(("[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7"):format(accountName, self.playerId, money))
            return
        end
        if money >= 0 then
            local account = self.getAccount(accountName)

            if account then
                money = account.round and ESX.Math.Round(money) or money
                self.accounts[account.index].money = money

                self.triggerEvent("esx:setAccountMoney", account)
                _TriggerEvent("esx:setAccountMoney", self.source, accountName, money, reason)
            else
                print(("[^1ERROR^7] Tried To Set Invalid Account ^5%s^0 For Player ^5%s^0!"):format(accountName, self.playerId))
            end
        else
            print(("[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7"):format(accountName, self.playerId, money))
        end
    end

    ---@param accountName string
    ---@param money number
    ---@param reason string
    ---@return void
    function self.addAccountMoney(accountName, money, reason)
        reason = reason or "Unknown"
        if not tonumber(money) then
            print(("[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7"):format(accountName, self.playerId, money))
            return
        end
        if money > 0 then
            local account = self.getAccount(accountName)
            if account then
                money = account.round and ESX.Math.Round(money) or money
                self.accounts[account.index].money = self.accounts[account.index].money + money

                self.triggerEvent("esx:setAccountMoney", account)
                _TriggerEvent("esx:addAccountMoney", self.source, accountName, money, reason)
            else
                print(("[^1ERROR^7] Tried To Set Add To Invalid Account ^5%s^0 For Player ^5%s^0!"):format(accountName, self.playerId))
            end
        else
            print(("[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7"):format(accountName, self.playerId, money))
        end
    end

    ---@param accountName string
    ---@param money number
    ---@param reason string
    ---@return void
    function self.removeAccountMoney(accountName, money, reason)
        reason = reason or "Unknown"
        if not tonumber(money) then
            print(("[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7"):format(accountName, self.playerId, money))
            return
        end
        if money > 0 then
            local account = self.getAccount(accountName)

            if account then
                money = account.round and ESX.Math.Round(money) or money
                if self.accounts[account.index].money - money > self.accounts[account.index].money then
                    print(("[^1ERROR^7] Tried To Underflow Account ^5%s^0 For Player ^5%s^0!"):format(accountName, self.playerId))
                    return
                end
                self.accounts[account.index].money = self.accounts[account.index].money - money

                self.triggerEvent("esx:setAccountMoney", account)
                _TriggerEvent("esx:removeAccountMoney", self.source, accountName, money, reason)
            else
                print(("[^1ERROR^7] Tried To Set Add To Invalid Account ^5%s^0 For Player ^5%s^0!"):format(accountName, self.playerId))
            end
        else
            print(("[^1ERROR^7] Tried To Set Account ^5%s^0 For Player ^5%s^0 To An Invalid Number -> ^5%s^7"):format(accountName, self.playerId, money))
        end
    end

    ---@param itemName string
    ---@return table | nil
    function self.getInventoryItem(itemName)
        for _, v in ipairs(self.inventory) do
            if v.name == itemName then
                return v
            end
        end
        return nil
    end

    ---@param itemName string
    ---@param count number
    ---@return void
    function self.addInventoryItem(itemName, count)
        local item = self.getInventoryItem(itemName)

        if item then
            count = ESX.Math.Round(count)
            item.count = item.count + count
            self.weight = self.weight + (item.weight * count)

            _TriggerEvent("esx:onAddInventoryItem", self.source, item.name, item.count)
            self.triggerEvent("esx:addInventoryItem", item.name, item.count)
        end
    end

    ---@param itemName string
    ---@param count number
    ---@return void
    function self.removeInventoryItem(itemName, count)
        local item = self.getInventoryItem(itemName)

        if item then
            count = ESX.Math.Round(count)
            if count > 0 then
                local newCount = item.count - count

                if newCount >= 0 then
                    item.count = newCount
                    self.weight = self.weight - (item.weight * count)

                    _TriggerEvent("esx:onRemoveInventoryItem", self.source, item.name, item.count)
                    self.triggerEvent("esx:removeInventoryItem", item.name, item.count)
                end
            else
                print(("[^1ERROR^7] Player ID:^5%s Tried remove a Invalid count -> %s of %s"):format(self.playerId, count, itemName))
            end
        end
    end

    ---@param itemName string
    ---@param count number
    ---@return void
    function self.setInventoryItem(itemName, count)
        local item = self.getInventoryItem(itemName)

        if item and count >= 0 then
            count = ESX.Math.Round(count)

            if count > item.count then
                self.addInventoryItem(item.name, count - item.count)
            else
                self.removeInventoryItem(item.name, item.count - count)
            end
        end
    end

    ---@return number
    function self.getWeight()
        return self.weight
    end

    ---@return number
    function self.getMaxWeight()
        return self.maxWeight
    end

    ---@param itemName string
    ---@param count number
    ---@return boolean
    function self.canCarryItem(itemName, count)
        if ESX.Items[itemName] then
            local currentWeight, itemWeight = self.weight, ESX.Items[itemName].weight
            local newWeight = currentWeight + (itemWeight * count)

            return newWeight <= self.maxWeight
        else
            print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(itemName))
        end
    end

    ---@param firstItem string
    ---@param firstItemCount number
    ---@param testItem string
    ---@param testItemCount number
    ---@return boolean
    function self.canSwapItem(firstItem, firstItemCount, testItem, testItemCount)
        local firstItemObject = self.getInventoryItem(firstItem)
        local testItemObject = self.getInventoryItem(testItem)

        if firstItemObject.count >= firstItemCount then
            local weightWithoutFirstItem = ESX.Math.Round(self.weight - (firstItemObject.weight * firstItemCount))
            local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

            return weightWithTestItem <= self.maxWeight
        end

        return false
    end

    ---@param newWeight number
    ---@return void
    function self.setMaxWeight(newWeight)
        self.maxWeight = newWeight
        self.triggerEvent("esx:setMaxWeight", self.maxWeight)
    end

    ---@param newJob string
    ---@param grade string
    ---@return void
    function self.setJob(newJob, grade)
        grade = tostring(grade)
        local lastJob = self.job

        if not ESX.DoesJobExist(newJob, grade) then
            return print(("[es_extended] [^3WARNING^7] Ignoring invalid ^5.setJob()^7 usage for ID: ^5%s^7, Job: ^5%s^7"):format(self.source, job))
        end

        local jobObject, gradeObject = ESX.Jobs[newJob], ESX.Jobs[newJob].grades[grade]

        self.job = {
            id = jobObject.id,
            name = jobObject.name,
            label = jobObject.label,

            grade = tonumber(grade),
            grade_name = gradeObject.name,
            grade_label = gradeObject.label,
            grade_salary = gradeObject.salary,

            skin_male = gradeObject.skin_male and json.decode(gradeObject.skin_male) or {},
            skin_female = gradeObject.skin_female and json.decode(gradeObject.skin_female) or {},
        }

        TriggerEvent("esx:setJob", self.source, self.job, lastJob)
        self.triggerEvent("esx:setJob", self.job, lastJob)
        Player(self.source).state:set("job", self.job, true)
    end

    ---@param weaponName string
    ---@param ammo number
    ---@return void
    function self.addWeapon(weaponName, ammo)
        if not self.hasWeapon(weaponName) then
            local weaponLabel <const> = ESX.GetWeaponLabel(weaponName)

            table.insert(self.loadout, {
                name = weaponName,
                ammo = ammo,
                label = weaponLabel,
                components = {},
                tintIndex = 0,
            })

            _GiveWeaponToPed(_GetPlayerPed(self.source), joaat(weaponName), ammo, false, false)
            self.triggerEvent("esx:addInventoryItem", weaponLabel, false, true)
        end
    end

    ---@param weaponName string
    ---@param weaponComponent string
    ---@return void
    function self.addWeaponComponent(weaponName, weaponComponent)
        local loadoutNum <const>, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

            if component then
                if not self.hasWeaponComponent(weaponName, weaponComponent) then
                    self.loadout[loadoutNum].components[#self.loadout[loadoutNum].components + 1] = weaponComponent
                    local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash
                    GiveWeaponComponentToPed(GetPlayerPed(self.source), joaat(weaponName), componentHash)
                    self.triggerEvent("esx:addInventoryItem", component.label, false, true)
                end
            end
        end
    end

    ---@param weaponName string
    ---@param ammoCount number
    ---@return void
    function self.addWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo + ammoCount
            _SetPedAmmo(GetPlayerPed(self.source), joaat(weaponName), weapon.ammo)
        end
    end

    ---@param weaponName string
    ---@param ammoCount number
    ---@return void
    function self.updateWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if weapon then
            weapon.ammo = ammoCount
        end
    end

    ---@param weaponName string
    ---@param weaponTintIndex number
    ---@return void
    function self.setWeaponTint(weaponName, weaponTintIndex)
        local loadoutNum <const>, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            local _, weaponObject <const> = ESX.GetWeapon(weaponName)

            if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
                self.loadout[loadoutNum].tintIndex = weaponTintIndex
                self.triggerEvent("esx:setWeaponTint", weaponName, weaponTintIndex)
                self.triggerEvent("esx:addInventoryItem", weaponObject.tints[weaponTintIndex], false, true)
            end
        end
    end

    ---@param weaponName string
    ---@return number
    function self.getWeaponTint(weaponName)
        local _, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            return weapon.tintIndex
        end

        return 0
    end

    ---@param weaponName string
    ---@return void
    function self.removeWeapon(weaponName)
        local weaponLabel, playerPed <const> = nil, _GetPlayerPed(self.source)

        if not playerPed then
            return print("[^1ERROR^7] xPlayer.removeWeapon ^5invalid^7 player ped!")
        end

        for k, v in ipairs(self.loadout) do
            if v.name == weaponName then
                weaponLabel = v.label

                for _, v2 in ipairs(v.components) do
                    self.removeWeaponComponent(weaponName, v2)
                end

                local weaponHash = joaat(v.name)
                _RemoveWeaponFromPed(playerPed, weaponHash)
                _SetPedAmmo(playerPed, weaponHash, 0)

                table.remove(self.loadout, k)
                break
            end
        end

        if weaponLabel then
            self.triggerEvent("esx:removeInventoryItem", weaponLabel, false, true)
        end
    end

    ---@param weaponName string
    ---@param weaponComponent string
    ---@return void
    function self.removeWeaponComponent(weaponName, weaponComponent)
        local loadoutNum <const>, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            ---@type table
            local component <const> = ESX.GetWeaponComponent(weaponName, weaponComponent)

            if component then
                if self.hasWeaponComponent(weaponName, weaponComponent) then
                    for k, v in ipairs(self.loadout[loadoutNum].components) do
                        if v == weaponComponent then
                            table.remove(self.loadout[loadoutNum].components, k)
                            break
                        end
                    end

                    self.triggerEvent("esx:removeWeaponComponent", weaponName, weaponComponent)
                    self.triggerEvent("esx:removeInventoryItem", component.label, false, true)
                end
            end
        end
    end

    ---@param weaponName string
    ---@param ammoCount number
    ---@return void
    function self.removeWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo - ammoCount
            _SetPedAmmo(GetPlayerPed(self.source), joaat(weaponName), weapon.ammo)
        end
    end

    ---@param weaponName string
    ---@param weaponComponent string
    ---@return boolean
    function self.hasWeaponComponent(weaponName, weaponComponent)
        local _, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            for _, v in ipairs(weapon.components) do
                if v == weaponComponent then
                    return true
                end
            end

            return false
        end

        return false
    end

    ---@param weaponName string
    ---@return boolean
    function self.hasWeapon(weaponName)
        for _, v in ipairs(self.loadout) do
            if v.name == weaponName then
                return true
            end
        end

        return false
    end

    ---@param item string
    ---@return table, number | false
    function self.hasItem(item)
        for _, v in ipairs(self.inventory) do
            if v.name == item and v.count >= 1 then
                return v, v.count
            end
        end

        return false
    end

    ---@param weaponName string
    ---@return number, table | nil
    function self.getWeapon(weaponName)
        for k, v in ipairs(self.loadout) do
            if v.name == weaponName then
                return k, v
            end
        end

        return nil
    end

    ---@param msg string
    ---@param type string
    ---@param length number
    ---@return void
    function self.showNotification(msg, notifyType, length)
        self.triggerEvent("esx:showNotification", msg, notifyType, length)
    end

    ---@param sender string
    ---@param subject string
    ---@param msg string
    ---@param textureDict string
    ---@param iconType string
    ---@param flash boolean
    ---@param saveToBrief boolean
    ---@param hudColorIndex number
    ---@return void
    function self.showAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
        self.triggerEvent("esx:showAdvancedNotification", sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    end

    ---@param msg string
    ---@param thisFrame boolean
    ---@param beep boolean
    ---@param duration number
    ---@return void
    function self.showHelpNotification(msg, thisFrame, beep, duration)
        self.triggerEvent("esx:showHelpNotification", msg, thisFrame, beep, duration)
    end

    ---@param index any
    ---@param subIndex any
    ---@return table
    function self.getMeta(index, subIndex)
        if not index then
            return self.metadata
        end

        if type(index) ~= "string" then
            return print("[^1ERROR^7] xPlayer.getMeta ^5index^7 should be ^5string^7!")
        end

        local metaData = self.metadata[index]
        if metaData == nil then
            return Config.EnableDebug and print(("[^1ERROR^7] xPlayer.getMeta ^5%s^7 not exist!"):format(index)) or nil
        end

        if subIndex and type(metaData) == "table" then
            local _type = type(subIndex)

            if _type == "string" then
                local value = metaData[subIndex]
                return value
            end

            if _type == "table" then
                local returnValues = {}

                for i = 1, #subIndex do
                    local key = subIndex[i]
                    if type(key) == "string" then
                        returnValues[key] = self.getMeta(index, key)
                    else
                        print(("[^1ERROR^7] xPlayer.getMeta subIndex should be ^5string^7 or ^5table^7! that contains ^5string^7, received ^5%s^7!, skipping..."):format(type(key)))
                    end
                end

                return returnValues
            end

            return print(("[^1ERROR^7] xPlayer.getMeta subIndex should be ^5string^7 or ^5table^7!, received ^5%s^7!"):format(_type))
        end

        return metaData
    end

    ---@param index any
    ---@param value any
    ---@param subValue any
    ---@return void
    function self.setMeta(index, value, subValue)
        if not index then
            return print("[^1ERROR^7] xPlayer.setMeta ^5index^7 is Missing!")
        end

        if type(index) ~= "string" then
            return print("[^1ERROR^7] xPlayer.setMeta ^5index^7 should be ^5string^7!")
        end

        if value == nil then
            return print("[^1ERROR^7] xPlayer.setMeta value is missing!")
        end

        local _type = type(value)

        if not subValue then
            if _type ~= "number" and _type ~= "string" and _type ~= "table" then
                return print(("[^1ERROR^7] xPlayer.setMeta ^5%s^7 should be ^5number^7 or ^5string^7 or ^5table^7!"):format(value))
            end

            self.metadata[index] = value
        else
            if _type ~= "string" then
                return print(("[^1ERROR^7] xPlayer.setMeta ^5value^7 should be ^5string^7 as a subIndex!"):format(value))
            end

            if not self.metadata[index] or type(self.metadata[index]) ~= "table" then
                self.metadata[index] = {}
            end

            self.metadata[index] = type(self.metadata[index]) == "table" and self.metadata[index] or {}
            self.metadata[index][value] = subValue
        end

        Player(self.source).state:set("metadata", self.metadata, true)
    end

    function self.clearMeta(index, subValues)
        if not index then
            return print("[^1ERROR^7] xPlayer.clearMeta ^5index^7 is Missing!")
        end

        if type(index) ~= "string" then
            return print("[^1ERROR^7] xPlayer.clearMeta ^5index^7 should be ^5string^7!")
        end

        local metaData = self.metadata[index]
        if metaData == nil then
            return Config.EnableDebug and print(("[^1ERROR^7] xPlayer.clearMeta ^5%s^7 does not exist!"):format(index)) or nil
        end

        if not subValues then
            -- If no subValues is provided, we will clear the entire value in the metaData table
            self.metadata[index] = nil
        elseif type(subValues) == "string" then
            -- If subValues is a string, we will clear the specific subValue within the table
            if type(metaData) == "table" then
                metaData[subValues] = nil
            else
                return print(("[^1ERROR^7] xPlayer.clearMeta ^5%s^7 is not a table! Cannot clear subValue ^5%s^7."):format(index, subValues))
            end
        elseif type(subValues) == "table" then
            -- If subValues is a table, we will clear multiple subValues within the table
            for i = 1, #subValues do
                local subValue = subValues[i]
                if type(subValue) == "string" then
                    if type(metaData) == "table" then
                        metaData[subValue] = nil
                    else
                        print(("[^1ERROR^7] xPlayer.clearMeta ^5%s^7 is not a table! Cannot clear subValue ^5%s^7."):format(index, subValue))
                    end
                else
                    print(("[^1ERROR^7] xPlayer.clearMeta subValues should contain ^5string^7, received ^5%s^7, skipping..."):format(type(subValue)))
                end
            end
        else
            return print(("[^1ERROR^7] xPlayer.clearMeta ^5subValues^7 should be ^5string^7 or ^5table^7, received ^5%s^7!"):format(type(subValues)))
        end

        Player(self.source).state:set("metadata", self.metadata, true)
    end

    for fnName, fn in pairs(targetOverrides) do
        self[fnName] = fn(self)
    end

    return self
end
