IsAuthorized = {}

local hookIdGeneratorRadius = 1e5
local hookableFunctions <const> = setmetatable({
    'kick',
    'setMoney',
    'getMoney',
    'addMoney',
    'removeMoney',
    'addAccountMoney',
    'setAccountMoney',
    'removeAccountMoney',
    'getInventoryItem',
    'addInventoryItem',
    'removeInventoryItem',
    'setInventoryItem',
    'hasItem',
    'hasWeapon',
    'hasWeaponComponent',
    'getWeaponTint',
    'setWeaponTint',
    'addWeaponAmmo',
    'getInventory',
    'getLoadout',
    'canCarryItem',
    'canSwapItem',
    'setMaxWeight',
    'addWeapon',
    'addWeaponComponent',
    'updateWeaponAmmo',
    'removeWeapon',
    'removeWeaponComponent',
    'removeWeaponAmmo',
    'getWeapon',
    'showNotification',
    'showAdvancedNotification',
    'showHelpNotification'
}, {
    __call = function(self, functionName)
        for i=1, #self do
            if self[i] == functionName then
                return true
            end
        end

        return false
    end
})

-- Local Functions

local otherResCheck = function()
    return GetInvokingResource() ~= 'es_extended' and not IsAuthorized[#IsAuthorized]
end

---@param hooks { hookId: string, functionName: string, invokingRes: string, isJustAddition: boolean, functionReference: fun(xPlayer: xPlayer, ...: any): any }[]
---@return string
local generateHookId = function(hooks)
    local idText = ('xPlayerHook_%s'):format(math.random(-hookIdGeneratorRadius, hookIdGeneratorRadius))

    if hooks('hookId', idText) then
        local timesExecuted = 0 --2*hookIdGeneratorRadius
        while hooks('hookId', idText) do
            Wait(0)

            if timesExecuted < 2*hookIdGeneratorRadius then
                idText = ('xPlayerHook_%s'):format(math.random(-hookIdGeneratorRadius, hookIdGeneratorRadius))
                timesExecuted += 1
            else
                idText = ('xPlayerHook_%s'):format(hookIdGeneratorRadius + 1)

                hookIdGeneratorRadius *= 1e2

                break
            end
        end
    end

    return idText
end

-- Main Code

XPlayerClass = setmetatable({
    hooks = setmetatable({}, {
        __call = function(self, compareField, compareValue, returnIndex)
            if compareField ~= 'hookId' and compareField ~= 'functionName' and compareField ~= 'invokerRes' and compareField ~= 'functionReference' then return error(('Resource %s tried to compare unexisting field in ESX\'s xPlayer hooks.\nStopped the code to prevent other errors.'):format(GetInvokingResource())) end

            for i=1, #self do
                if self[i][compareField] == compareValue then
                    if returnIndex then
                        return true, i
                    else
                        return true
                    end
                end
            end
        end
    }),

    addHook = function(self, functionName, isJustAddition, functionReference)
        IsAuthorized[#IsAuthorized+1] = true

        if not self[functionName] or not ESX.IsFunctionReference(functionReference) then
            warn(('Resource %s tried to\n%s!'):format(GetInvokingResource(), not self[functionName] and 'add a hook function to missing xPlayer function' or 'add a hook function by providing a non-function for the hook\'s function reference'))

            return false
        elseif not hookableFunctions(functionName) then
            warn(('Resource %s tried to add a hook for a function which does not support hooks!'):format(GetInvokingResource()))
        end

        if not isJustAddition then
            if #self.hooks > 0 then
                for i=1, #self.hooks do
                    if self.hooks[i].functionName == functionName then
                        table.remove(self.hooks, i)
                    end
                end
            end
        end

        local hookId <const> = generateHookId(self.hooks)

        self.hooks[#self.hooks+1] = {
            hookId = hookId,
            functionName = functionName,
            invokerRes = GetInvokingResource(),
            isJustAddition = true,
            functionReference = functionReference
        }

        table.remove(IsAuthorized, #IsAuthorized)

        return hookId
    end,

    removeHook = function(self, hookId)
        IsAuthorized[#IsAuthorized+1] = true

        local found <const>, index <const> = self.hooks('hookId', hookId, true)

        if found then
            table.remove(self.hooks, index)
        end

        table.remove(IsAuthorized, #IsAuthorized)

        return found
    end,

    triggerEvent = function(xPlayer, eventName, ...)
        assert(type(eventName) == 'string', 'eventName should be string!')
        TriggerClientEvent(eventName, xPlayer.source, ...)
    end,

    togglePaycheck = function(xPlayer, toggle)
        xPlayer.paycheckEnabled = toggle
    end,

    isPaycheckEnabled = function(xPlayer)
        return xPlayer.paycheckEnabled
    end,

    isAdmin = function(xPlayer)
        return Core.IsPlayerAdmin(xPlayer.source)
    end,

    setCoords = function(xPlayer, coordinates)
        local ped <const> = GetPlayerPed(xPlayer.source)

        SetEntityCoords(ped, coordinates.x, coordinates.y, coordinates.z, false, false, false, false)
        SetEntityHeading(ped, coordinates.w or coordinates.heading or 0.0)
    end,

    getCoords = function(xPlayer, vector, heading)
        local ped <const> = GetPlayerPed(xPlayer.source)
        local entityCoords <const> = GetEntityCoords(ped)
        local entityHeading <const> = GetEntityHeading(ped)

        local coordinates = { x = entityCoords.x, y = entityCoords.y, z = entityCoords.z }

        if vector then
            coordinates = (heading and vector4(entityCoords.x, entityCoords.y, entityCoords.z, entityHeading) or entityCoords)
        elseif heading then
            coordinates.heading = entityHeading
        end

        return coordinates
    end,

    kick = function(xPlayer, reason)
        DropPlayer(tostring(xPlayer.source), reason)
    end,

    getPlayTime = function(xPlayer)
        return xPlayer.lastPlaytime + GetPlayerTimeOnline(xPlayer.source --[[@as string]])
    end,

    setMoney = function(xPlayer, money)
        assert(type(money) == 'number', 'money should be number!')

        xPlayer.setAccountMoney('money', ESX.Math.Round(money))
    end,

    getMoney = function(xPlayer)
        return xPlayer.getAccount('money').money
    end,

    addMoney = function(xPlayer, money, reason)
        xPlayer.addAccountMoney('money', ESX.Math.Round(money), reason)
    end,

    removeMoney = function(xPlayer, money, reason)
        xPlayer.removeAccountMoney('money', ESX.Math.Round(money), reason)
    end,

    ---@deprecated use xPlayer.identifier instead
    getIdentifier = function(xPlayer) return xPlayer.identifier end,

    ---@deprecated use xPlayer.ssn instead
    getSSN = function(xPlayer) return xPlayer.ssn end,

    setGroup = function(xPlayer, newGroup)
        local lastGroup <const> = xPlayer.group
        xPlayer.group = newGroup

        xPlayer.triggerEvent('esx:setGroup', xPlayer.group, lastGroup)
        Player(xPlayer.source).state:set('group', xPlayer.group, true)
        TriggerEvent('esx:setGroup', xPlayer.source, xPlayer.group, lastGroup)
        ExecuteCommand(('remove_principal identifier.%s group.%s'):format(xPlayer.license, lastGroup))
        ExecuteCommand(('add_principal identifier.%s group.%s'):format(xPlayer.license, xPlayer.group))
    end,

    ---@deprecated use xPlayer.group instead
    getGroup = function(xPlayer) return xPlayer.group end,

    set = function(xPlayer, k, v)
        xPlayer.variables[k] = v

        xPlayer.triggerEvent('esx:updatePlayerData', 'variables', xPlayer.variables)
    end,

    get = function(xPlayer, k)
        return xPlayer.variables[k]
    end,

    getAccounts = function(xPlayer, minimal)
        if not minimal then
            return xPlayer.accounts
        end

        local minimalAccounts = {}

        for i = 1, #xPlayer.accounts do
            minimalAccounts[xPlayer.accounts[i].name] = xPlayer.accounts[i].money
        end

        return minimalAccounts
    end,

    getAccount = function(xPlayer, account)
        account = string.lower(account)
        for i = 1, #xPlayer.accounts do
            local accountName = string.lower(xPlayer.accounts[i].name)
            if accountName == account then
                return xPlayer.accounts[i]
            end
        end

        return nil
    end,

    getInventory = function(xPlayer, minimal)
        if minimal then
            local minimalInventory = {}

            for _, v in ipairs(xPlayer.inventory) do
                if v.count > 0 then
                    minimalInventory[v.name] = v.count
                end
            end

            return minimalInventory
        end

        return xPlayer.inventory
    end,

    ---@deprecated use xPlayer.job instead
    getJob = function(xPlayer)
        return xPlayer.job
    end,

    getLoadout = function(xPlayer, minimal)
        if not minimal then
            return xPlayer.loadout
        end
        local minimalLoadout = {}

        for _, v in ipairs(xPlayer.loadout) do
            minimalLoadout[v.name] = { ammo = v.ammo }
            if v.tintIndex > 0 then
                minimalLoadout[v.name].tintIndex = v.tintIndex
            end

            if #v.components > 0 then
                local components = {}

                for _, component in ipairs(v.components) do
                    if component ~= 'clip_default' then
                        components[#components + 1] = component
                    end
                end

                if #components > 0 then
                    minimalLoadout[v.name].components = components
                end
            end
        end

        return minimalLoadout
    end,

    ---@deprecated use xPlayer.name instead
    getName = function(xPlayer) return xPlayer.name end,

    setName = function(xPlayer, newName)
        xPlayer.name = newName
        Player(xPlayer.source).state:set('name', xPlayer.name, true)
    end,

    setAccountMoney = function(xPlayer, accountName, money, reason)
        reason = reason or 'unknown'
        if not tonumber(money) then
            return error(('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(accountName, xPlayer.playerId, money))
        end
        if money >= 0 then
            local account = xPlayer.getAccount(accountName)

            if account then
                money = account.round and ESX.Math.Round(money) or money
                xPlayer.accounts[account.index].money = money

                xPlayer.triggerEvent('esx:setAccountMoney', account)
                TriggerEvent('esx:setAccountMoney', xPlayer.source, accountName, money, reason)
            else
                error(('Tried To Set Invalid Account ^5%s^1 For Player ^5%s^1!'):format(accountName, xPlayer.playerId))
            end
        else
            error(('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(accountName, xPlayer.playerId, money))
        end
    end,

    addAccountMoney = function(xPlayer, accountName, money, reason)
        reason = reason or 'Unknown'
        if not tonumber(money) then
            error(('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(accountName, xPlayer.playerId, money))
            return
        end
        if money > 0 then
            local account = xPlayer.getAccount(accountName)
            if account then
                money = account.round and ESX.Math.Round(money) or money
                xPlayer.accounts[account.index].money = xPlayer.accounts[account.index].money + money

                xPlayer.triggerEvent('esx:setAccountMoney', account)
                TriggerEvent('esx:addAccountMoney', xPlayer.source, accountName, money, reason)
            else
                error(('Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!'):format(accountName, xPlayer.playerId))
            end
        else
            error(('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(accountName, xPlayer.playerId, money))
        end
    end,

    removeAccountMoney = function(xPlayer, accountName, money, reason)
        reason = reason or 'Unknown'
        if not tonumber(money) then
            error(('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(accountName, xPlayer.playerId, money))
            return
        end
        if money > 0 then
            local account = xPlayer.getAccount(accountName)

            if account then
                money = account.round and ESX.Math.Round(money) or money
                if xPlayer.accounts[account.index].money - money > xPlayer.accounts[account.index].money then
                    error(('Tried To Underflow Account ^5%s^1 For Player ^5%s^1!'):format(accountName, xPlayer.playerId))
                    return
                end
                xPlayer.accounts[account.index].money = xPlayer.accounts[account.index].money - money

                xPlayer.triggerEvent('esx:setAccountMoney', account)
                TriggerEvent('esx:removeAccountMoney', xPlayer.source, accountName, money, reason)
            else
                error(('Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!'):format(accountName, xPlayer.playerId))
            end
        else
            error(('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(accountName, xPlayer.playerId, money))
        end
    end,

    getInventoryItem = function(xPlayer, itemName)
        for _, v in ipairs(xPlayer.inventory) do
            if v.name == itemName then
                return v
            end
        end
        return nil
    end,

    addInventoryItem = function(xPlayer, itemName, count)
        local item = xPlayer.getInventoryItem(itemName)

        if item then
            count = ESX.Math.Round(count)
            item.count = item.count + count
            xPlayer.weight = xPlayer.weight + (item.weight * count)

            TriggerEvent('esx:onAddInventoryItem', xPlayer.source, item.name, item.count)
            xPlayer.triggerEvent('esx:addInventoryItem', item.name, item.count)
        end
    end,

    removeInventoryItem = function(xPlayer, itemName, count)
        local item = xPlayer.getInventoryItem(itemName)

        if item then
            count = ESX.Math.Round(count)
            if count > 0 then
                local newCount = item.count - count

                if newCount >= 0 then
                    item.count = newCount
                    xPlayer.weight = xPlayer.weight - (item.weight * count)

                    TriggerEvent('esx:onRemoveInventoryItem', xPlayer.source, item.name, item.count)
                    xPlayer.triggerEvent('esx:removeInventoryItem', item.name, item.count)
                end
            else
                error(('Player ID:^5%s Tried remove a Invalid count -> %s of %s'):format(xPlayer.playerId, count, itemName))
            end
        end
    end,

    setInventoryItem = function(xPlayer, itemName, count)
        local item = xPlayer.getInventoryItem(itemName)

        if item and count >= 0 then
            count = ESX.Math.Round(count)

            if count > item.count then
                xPlayer.addInventoryItem(item.name, count - item.count)
            else
                xPlayer.removeInventoryItem(item.name, item.count - count)
            end
        end
    end,

    ---@deprecated use xPlayer.weight instead
    getWeight = function(xPlayer) return xPlayer.weight end,

    ---@deprecated use xPlayer.source instead
    getSource = function(xPlayer) return xPlayer.source end,

    ---@deprecated use xPlayer.source instead
    getPlayerId = function(xPlayer) return xPlayer.source end,

    ---@deprecated use xPlayer.maxWeight instead
    getMaxWeight = function(xPlayer) return xPlayer.maxWeight end,

    canCarryItem = function(xPlayer, itemName, count)
        if ESX.Items[itemName] then
            local currentWeight, itemWeight = xPlayer.weight, ESX.Items[itemName].weight
            local newWeight = currentWeight + (itemWeight * count)

            return newWeight <= xPlayer.maxWeight
        else
            print(('[^3WARNING^7] Item ^5\'%s\'^7 was used but does not exist!'):format(itemName))
            return false
        end
    end,

    canSwapItem = function(xPlayer, firstItem, firstItemCount, testItem, testItemCount)
        local firstItemObject = xPlayer.getInventoryItem(firstItem)
        if not firstItemObject then
            return false
        end
        local testItemObject = xPlayer.getInventoryItem(testItem)
        if not testItemObject then
            return false
        end

        if firstItemObject.count >= firstItemCount then
            local weightWithoutFirstItem = ESX.Math.Round(xPlayer.weight - (firstItemObject.weight * firstItemCount))
            local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

            return weightWithTestItem <= xPlayer.maxWeight
        end

        return false
    end,

    setMaxWeight = function(xPlayer, newWeight)
        xPlayer.maxWeight = newWeight

        xPlayer.triggerEvent('esx:setMaxWeight', xPlayer.maxWeight)
    end,

    setJob = function(xPlayer, newJob, grade, onDuty)
        grade = tostring(grade)
        local lastJob = xPlayer.job

        if not ESX.DoesJobExist(newJob, grade) then
            return print(('[ESX] [^3WARNING^7] Ignoring invalid ^5.setJob()^7 usage for ID: ^5%s^7, Job: ^5%s^7'):format(xPlayer.source, newJob))
        end

        if newJob == 'unemployed' then
            onDuty = false
        end

        if type(onDuty) ~= 'boolean' then
            onDuty = Config.DefaultJobDuty
        end

        local jobObject, gradeObject = ESX.Jobs[newJob], ESX.Jobs[newJob].grades[grade]

        xPlayer.job = {
            id = jobObject.id,
            name = jobObject.name,
            label = jobObject.label,
            onDuty = onDuty,

            grade = tonumber(grade) or 0,
            grade_name = gradeObject.name,
            grade_label = gradeObject.label,
            grade_salary = gradeObject.salary,

            skin_male = gradeObject.skin_male and json.decode(gradeObject.skin_male) or {},
            skin_female = gradeObject.skin_female and json.decode(gradeObject.skin_female) or {},
        }

        xPlayer.metadata.jobDuty = onDuty
        TriggerEvent('esx:setJob', xPlayer.source, xPlayer.job, lastJob)
        xPlayer.triggerEvent('esx:setJob', xPlayer.job, lastJob)
        Player(xPlayer.source).state:set('job', xPlayer.job, true)
    end,

    addWeapon = function(xPlayer, weaponName, ammo)
        if not xPlayer.hasWeapon(weaponName) then
            local weaponLabel <const> = ESX.GetWeaponLabel(weaponName)

            table.insert(xPlayer.loadout, {
                name = weaponName,
                ammo = ammo,
                label = weaponLabel,
                components = {},
                tintIndex = 0,
            })

            GiveWeaponToPed(GetPlayerPed(xPlayer.source), joaat(weaponName), ammo, false, false)
            xPlayer.triggerEvent('esx:addInventoryItem', weaponLabel, false, true)
            xPlayer.triggerEvent('esx:addLoadoutItem', weaponName, weaponLabel, ammo)
        end
    end,

    addWeaponComponent = function(xPlayer, weaponName, weaponComponent)
        local loadoutNum <const>, weapon <const> = xPlayer.getWeapon(weaponName)

        if weapon then
            local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

            if component then
                if not xPlayer.hasWeaponComponent(weaponName, weaponComponent) then
                    xPlayer.loadout[loadoutNum].components[#xPlayer.loadout[loadoutNum].components + 1] = weaponComponent
                    local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash
                    GiveWeaponComponentToPed(GetPlayerPed(xPlayer.source), joaat(weaponName), componentHash)
                    xPlayer.triggerEvent('esx:addInventoryItem', component.label, false, true)
                end
            end
        end
    end,

    addWeaponAmmo = function(xPlayer, weaponName, ammoCount)
        local _, weapon = xPlayer.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo + ammoCount
            SetPedAmmo(GetPlayerPed(xPlayer.source), joaat(weaponName), weapon.ammo)
        end
    end,

    updateWeaponAmmo = function(xPlayer, weaponName, ammoCount)
        local _, weapon = xPlayer.getWeapon(weaponName)

        if not weapon then
            return
        end

        weapon.ammo = ammoCount

        if weapon.ammo <= 0 then
            local _, weaponConfig = ESX.GetWeapon(weaponName)
            if weaponConfig.throwable then
                xPlayer.removeWeapon(weaponName)
            end
        end
    end,

    setWeaponTint = function(xPlayer, weaponName, weaponTintIndex)
        local loadoutNum <const>, weapon <const> = xPlayer.getWeapon(weaponName)

        if weapon then
            local _, weaponObject <const> = ESX.GetWeapon(weaponName)

            if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
                xPlayer.loadout[loadoutNum].tintIndex = weaponTintIndex
                xPlayer.triggerEvent('esx:setWeaponTint', weaponName, weaponTintIndex)
                xPlayer.triggerEvent('esx:addInventoryItem', weaponObject.tints[weaponTintIndex], false, true)
            end
        end
    end,

    getWeaponTint = function(xPlayer, weaponName)
        local _, weapon <const> = xPlayer.getWeapon(weaponName)

        if weapon then
            return weapon.tintIndex
        end

        return 0
    end,

    removeWeapon = function(xPlayer, weaponName)
        local weaponLabel, playerPed <const> = nil, GetPlayerPed(xPlayer.source)

        if not playerPed then
            return error('xPlayer.removeWeapon ^5invalid^1 player ped!')
        end

        for k, v in ipairs(xPlayer.loadout) do
            if v.name == weaponName then
                weaponLabel = v.label

                for _, v2 in ipairs(v.components) do
                    xPlayer.removeWeaponComponent(weaponName, v2)
                end

                local weaponHash = joaat(v.name)
                RemoveWeaponFromPed(playerPed, weaponHash)
                SetPedAmmo(playerPed, weaponHash, 0)

                table.remove(xPlayer.loadout, k)
                break
            end
        end

        if weaponLabel then
            xPlayer.triggerEvent('esx:removeInventoryItem', weaponLabel, false, true)
            xPlayer.triggerEvent('esx:removeLoadoutItem', weaponName, weaponLabel)
        end
    end,

    removeWeaponComponent = function(xPlayer, weaponName, weaponComponent)
        local loadoutNum <const>, weapon <const> = xPlayer.getWeapon(weaponName)

        if weapon then
            local component <const> = ESX.GetWeaponComponent(weaponName, weaponComponent)

            if component then
                if xPlayer.hasWeaponComponent(weaponName, weaponComponent) then
                    for k, v in ipairs(xPlayer.loadout[loadoutNum].components) do
                        if v == weaponComponent then
                            table.remove(xPlayer.loadout[loadoutNum].components, k)
                            break
                        end
                    end

                    xPlayer.triggerEvent('esx:removeWeaponComponent', weaponName, weaponComponent)
                    xPlayer.triggerEvent('esx:removeInventoryItem', component.label, false, true)
                end
            end
        end
    end,

    removeWeaponAmmo = function(xPlayer, weaponName, ammoCount)
        local _, weapon = xPlayer.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo - ammoCount
            SetPedAmmo(GetPlayerPed(xPlayer.source), joaat(weaponName), weapon.ammo)
        end
    end,

    hasWeaponComponent = function(xPlayer, weaponName, weaponComponent)
        local _, weapon <const> = xPlayer.getWeapon(weaponName)

        if weapon then
            for _, v in ipairs(weapon.components) do
                if v == weaponComponent then
                    return true
                end
            end

            return false
        end

        return false
    end,

    hasWeapon = function(xPlayer, weaponName)
        for _, v in ipairs(xPlayer.loadout) do
            if v.name == weaponName then
                return true
            end
        end

        return false
    end,

    hasItem = function(xPlayer, item)
        for _, v in ipairs(xPlayer.inventory) do
            if v.name == item and v.count >= 1 then
                return v, v.count
            end
        end

        return false
    end,

    getWeapon = function(xPlayer, weaponName)
        for k, v in ipairs(xPlayer.loadout) do
            if v.name == weaponName then
                return k, v
            end
        end

        return nil, nil
    end,

    showNotification = function(xPlayer, msg, notifyType, length, title, position)
        xPlayer.triggerEvent('esx:showNotification', msg, notifyType, length, title, position)
    end,

    showAdvancedNotification = function(xPlayer, sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
        xPlayer.triggerEvent('esx:showAdvancedNotification', sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    end,

    showHelpNotification = function(xPlayer, msg, thisFrame, beep, duration)
        xPlayer.triggerEvent('esx:showHelpNotification', msg, thisFrame, beep, duration)
    end,

    getMeta = function(xPlayer, index, subIndex)
        if not index then
            return xPlayer.metadata
        end

        if type(index) ~= 'string' then
            error('xPlayer.getMeta ^5index^1 should be ^5string^1!')
            return
        end

        local metaData = xPlayer.metadata[index]
        if metaData == nil then
            return Config.EnableDebug and error(('xPlayer.getMeta ^5%s^1 not exist!'):format(index)) or nil
        end

        if subIndex and type(metaData) == 'table' then
            local _type = type(subIndex)

            if _type == 'string' then
                local value = metaData[subIndex]
                return value
            end

            if _type == 'table' then
                local returnValues = {}

                for i = 1, #subIndex do
                    local key = subIndex[i]
                    if type(key) == 'string' then
                        returnValues[key] = xPlayer.getMeta(index, key)
                    else
                        error(('xPlayer.getMeta subIndex should be ^5string^1 or ^5table^1! that contains ^5string^1, received ^5%s^1!, skipping...'):format(type(key)))
                    end
                end

                return returnValues
            end

            error(('xPlayer.getMeta subIndex should be ^5string^1 or ^5table^1!, received ^5%s^1!'):format(_type))
            return
        end

        return metaData
    end,

    setMeta = function(xPlayer, index, value, subValue)
        if not index then
            return error('xPlayer.setMeta ^5index^1 is Missing!')
        end

        if type(index) ~= 'string' then
            return error('xPlayer.setMeta ^5index^1 should be ^5string^1!')
        end

        if value == nil then
            return error('xPlayer.setMeta value is missing!')
        end

        local _type = type(value)

        if not subValue then
            if _type ~= 'number' and _type ~= 'string' and _type ~= 'table' then
                return error(('xPlayer.setMeta ^5%s^1 should be ^5number^1 or ^5string^1 or ^5table^1!'):format(value))
            end

            xPlayer.metadata[index] = value
        else
            if _type ~= 'string' then
                return error(('xPlayer.setMeta ^5value^1 should be ^5string^1 as a subIndex!'):format(value))
            end

            if not xPlayer.metadata[index] or type(xPlayer.metadata[index]) ~= 'table' then
                xPlayer.metadata[index] = {}
            end

            xPlayer.metadata[index] = type(xPlayer.metadata[index]) == 'table' and xPlayer.metadata[index] or {}
            xPlayer.metadata[index][value] = subValue
        end
        xPlayer.triggerEvent('esx:updatePlayerData', 'metadata', xPlayer.metadata)
    end,

    clearMeta = function(xPlayer, index, subValues)
        if not index then
            return error('xPlayer.clearMeta ^5index^1 is Missing!')
        end

        if type(index) ~= 'string' then
            return error('xPlayer.clearMeta ^5index^1 should be ^5string^1!')
        end

        local metaData = xPlayer.metadata[index]
        if metaData == nil then
            if Config.EnableDebug then
                error(('xPlayer.clearMeta ^5%s^1 does not exist!'):format(index))
            end

            return
        end

        if not subValues then
            -- If no subValues is provided, we will clear the entire value in the metaData table
            xPlayer.metadata[index] = nil
        elseif type(subValues) == 'string' then
            -- If subValues is a string, we will clear the specific subValue within the table
            if type(metaData) == 'table' then
                metaData[subValues] = nil
            else
                return error(('xPlayer.clearMeta ^5%s^1 is not a table! Cannot clear subValue ^5%s^1.'):format(index, subValues))
            end
        elseif type(subValues) == 'table' then
            -- If subValues is a table, we will clear multiple subValues within the table
            for i = 1, #subValues do
                local subValue = subValues[i]
                if type(subValue) == 'string' then
                    if type(metaData) == 'table' then
                        metaData[subValue] = nil
                    else
                        error(('xPlayer.clearMeta ^5%s^1 is not a table! Cannot clear subValue ^5%s^1.'):format(index, subValue))
                    end
                else
                    error(('xPlayer.clearMeta subValues should contain ^5string^1, received ^5%s^1, skipping...'):format(type(subValue)))
                end
            end
        else
            return error(('xPlayer.clearMeta ^5subValues^1 should be ^5string^1 or ^5table^1, received ^5%s^1!'):format(type(subValues)))
        end
        xPlayer.triggerEvent('esx:updatePlayerData', 'metadata', xPlayer.metadata)
    end,

    executeCommand = function(xPlayer, command)
        if type(command) ~= 'string' then
            error('xPlayer.executeCommand must be of type string!')
            return
        end

        xPlayer.triggerEvent('esx:executeCommand', command)
    end,

    syncInventory = Config.CustomInventory == 'ox' and function(xPlayer, weight, maxWeight, items, money)
        xPlayer.weight, xPlayer.maxWeight = weight, maxWeight
        xPlayer.inventory = items

        if not money then return end
        for accountName, amount in pairs(money) do
            local account = xPlayer.getAccount(accountName)

            if account and ESX.Math.Round(account.money) ~= amount then
                account.money = amount
                xPlayer.triggerEvent('esx:setAccountMoney', account)
                TriggerEvent('esx:setAccountMoney', xPlayer.source, accountName, amount, 'Sync account with item')
            end
        end
    end or nil
}, {
    __index = function(self, k)
        if otherResCheck() and (k ~= 'addHook' or k ~= 'removeHook') then return end

        return rawget(self, k)
    end,
    __newindex = function(self, k, v)
        if otherResCheck() then return end

        rawset(self, k, v)
    end,
    __call = function(self, xPlayer, functionName)
        if otherResCheck() then return end

        return function(...)
            if self.hooks('functionName', functionName) then
                for i=1, #self.hooks do
                    if self.hooks[i].functionName == functionName then
                        local _, result <const> = pcall(self.hooks[i].functionReference, xPlayer, ...)
                        if (self.hooks[i].isJustAddition and result == false) or not self.hooks[i].isJustAddition then return end
                    end
                end
            end

            return self[functionName](xPlayer, ...)
        end
    end
})

ESX.XPlayerClass = setmetatable({
    addHook = function(functionName, isJustAddition, functionReference)
        return exports.es_extended:addXPlayerHook(functionName, isJustAddition, functionReference)
    end,
    removeHook = function(hookId)
        return exports.es_extended:removeXPlayerHook(hookId)
    end
}, {
    __newindex = nil
})

-- ox_inventory's overrides

do
    if Config.CustomInventory == 'ox' then
        local resName <const>, path <const> = 'es_extended', 'server/classes/xPlayer/oxInv_overrides.lua'
        load(LoadResourceFile(resName, path), ('@@%s/%s'):format(resName, path))() --[[@as fun(xPlayer: xPlayer) ]]
    end
end

-- Exports

exports('RunStaticPlayerMethod', function(src, method, ...)
    local xPlayer = ESX.Players[src]
    if not xPlayer then
        return
    end

    if not ESX.IsFunctionReference(xPlayer[method]) then
        error(('Attempted to call invalid method on playerId %s: %s'):format(src, method))
    end

    return xPlayer[method](...)
end)

exports('addXPlayerHook', function(functionName, isJustAddition, functionReference)
    return XPlayerClass:addHook(functionName, isJustAddition, functionReference)
end)

exports('removeXPlayerHook', function(hookId)
    return XPlayerClass:removeHook(hookId)
end)