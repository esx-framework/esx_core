---@class ESXAccount
---@field name string               # Account name (e.g., "bank", "money").
---@field money number              # Current balance in this account.
---@field label string              # Human-readable label for the account.
---@field round boolean             # Whether amounts are rounded for display.
---@field index number              # Index of the account in the player's accounts list.

---@class ESXItem
---@field name string               # Item identifier (internal name).
---@field label string              # Display name of the item.
---@field weight number             # Weight of a single unit of the item.
---@field usable boolean            # Whether the item can be used.
---@field rare boolean              # Whether the item is rare.
---@field canRemove boolean         # Whether the item can be removed from inventory.

---@class ESXInventoryItem:ESXItem
---@field count number              # Number of this item in the player's inventory.

---@class ESXJob
---@field id number                 # Job ID.
---@field name string               # Job internal name.
---@field label string              # Job display label.
---@field grade number              # Current grade/rank number.
---@field grade_name string         # Name of the current grade.
---@field grade_label string        # Label of the current grade.
---@field grade_salary number       # Salary for the current grade.
---@field skin_male table           # Skin configuration for male characters.
---@field skin_female table         # Skin configuration for female characters.
---@field onDuty boolean?           # Whether the player is currently on duty.

---@class ESXWeapon
---@field name string               # Weapon identifier (internal name).
---@field label string              # Weapon display name.

---@class ESXInventoryWeapon:ESXWeapon
---@field ammo number               # Amount of ammo in the weapon.
---@field components string[]       # List of components attached to the weapon.
---@field tintIndex number          # Current weapon tint index.

---@class ESXWeaponComponent
---@field name string               # Component identifier (internal name).
---@field label string              # Component display name.
---@field hash string|number        # Component hash or identifier.

---@class StaticPlayer
---@field src number                                              # Player's server ID.
--- Money Functions
---@field setMoney fun(money: number)                             # Set player's cash balance.
---@field getMoney fun(): number                                   # Get player's current cash balance.
---@field addMoney fun(money: number, reason: string)             # Add money to the player's cash balance.
---@field removeMoney fun(money: number, reason: string)          # Remove money from the player's cash balance.
---@field setAccountMoney fun(accountName: string, money: number, reason?: string)  # Set specific account balance.
---@field addAccountMoney fun(accountName: string, money: number, reason?: string)  # Add money to an account.
---@field removeAccountMoney fun(accountName: string, money: number, reason?: string) # Remove money from an account.
---@field getAccount fun(account: string): ESXAccount?            # Get account data by name.
---@field getAccounts fun(minimal?: boolean): ESXAccount[]|table<string,number>  # Get all accounts, optionally minimal.
--- Inventory Functions
---@field getInventory fun(minimal?: boolean): ESXInventoryItem[]|table<string,number>  # Get inventory, optionally minimal.
---@field getInventoryItem fun(itemName: string): ESXInventoryItem? # Get a specific item from inventory.
---@field addInventoryItem fun(itemName: string, count: number)     # Add items to inventory.
---@field removeInventoryItem fun(itemName: string, count: number)  # Remove items from inventory.
---@field setInventoryItem fun(itemName: string, count: number)     # Set item count in inventory.
---@field getWeight fun(): number                                   # Get current carried weight.
---@field getMaxWeight fun(): number                                # Get maximum carry weight.
---@field setMaxWeight fun(newWeight: number)                       # Set maximum carry weight.
---@field canCarryItem fun(itemName: string, count: number): boolean # Check if player can carry more of an item.
---@field canSwapItem fun(firstItem: string, firstItemCount: number, testItem: string, testItemCount: number): boolean # Check if items can be swapped.
---@field hasItem fun(item: string): ESXInventoryItem|false, number? # Check if player has an item.
---@field getLoadout fun(minimal?: boolean): ESXInventoryWeapon[]|table<string, {ammo:number, tintIndex?:number, components?:string[]}> # Get player's weapon loadout.
--- Job Functions
---@field getJob fun(): ESXJob                                         # Get player's current job.
---@field setJob fun(newJob: string, grade: string, onDuty?: boolean)  # Set player's job and grade.
---@field setGroup fun(newGroup: string)                               # Set player's permission group.
---@field getGroup fun(): string                                       # Get player's permission group.
--- Weapon Functions
---@field addWeapon fun(weaponName: string, ammo: number)                 # Give player a weapon.
---@field removeWeapon fun(weaponName: string)                             # Remove weapon from player.
---@field hasWeapon fun(weaponName: string): boolean                       # Check if player has a weapon.
---@field getWeapon fun(weaponName: string): number?, table?               # Get weapon ammo & components.
---@field addWeaponAmmo fun(weaponName: string, ammoCount: number)        # Add ammo to a weapon.
---@field removeWeaponAmmo fun(weaponName: string, ammoCount: number)     # Remove ammo from a weapon.
---@field updateWeaponAmmo fun(weaponName: string, ammoCount: number)     # Update ammo count for a weapon.
---@field addWeaponComponent fun(weaponName: string, weaponComponent: string)    # Add component to weapon.
---@field removeWeaponComponent fun(weaponName: string, weaponComponent: string) # Remove component from weapon.
---@field hasWeaponComponent fun(weaponName: string, weaponComponent: string): boolean # Check if weapon has component.
---@field setWeaponTint fun(weaponName: string, weaponTintIndex: number) # Set weapon tint.
---@field getWeaponTint fun(weaponName: string): number                  # Get weapon tint.
--- Player State Functions
---@field getIdentifier fun(): string                              # Get player's unique identifier.
---@field getSSN fun(): string                                      # Get player's social security number.
---@field getSource fun(): number                                  # Get player source/server ID.
---@field getPlayerId fun(): number                                # Alias for getSource.
---@field getName fun(): string                                     # Get player's name.
---@field setName fun(newName: string)                              # Set player's name.
---@field setCoords fun(coordinates: vector4|vector3|table)        # Teleport player to coordinates.
---@field getCoords fun(vector?: boolean, heading?: boolean): vector3|vector4|table # Get player's coordinates.
---@field isAdmin fun(): boolean                                    # Check if player is admin.
---@field kick fun(reason: string)                                  # Kick player from server.
---@field getPlayTime fun(): number                                  # Get total playtime in seconds.
---@field set fun(k: string, v: any)                                # Set custom variable.
---@field get fun(k: string): any                                    # Get custom variable.
--- Metadata Functions
---@field getMeta fun(index?: string, subIndex?: string|table): any   # Get metadata value(s).
---@field setMeta fun(index: string, value: any, subValue?: any)      # Set metadata value(s).
---@field clearMeta fun(index: string, subValues?: string|table)      # Clear metadata value(s).
--- Notification Functions
---@field showNotification fun(msg: string, notifyType?: string, length?: number, title?: string, position?: string) # Show a simple notification.
---@field showAdvancedNotification fun(sender: string, subject: string, msg: string, textureDict: string, iconType: string, flash: boolean, saveToBrief: boolean, hudColorIndex: number) # Show advanced notification.
---@field showHelpNotification fun(msg: string, thisFrame?: boolean, beep?: boolean, duration?: number) # Show help notification.
--- Misc Functions
---@field togglePaycheck fun(toggle: boolean)     # Enable/disable paycheck.
---@field isPaycheckEnabled fun(): boolean       # Check if paycheck is enabled.
---@field executeCommand fun(command: string)    # Execute a server command.
---@field triggerEvent fun(eventName: string, ...) # Trigger client event for this player.


---@class xPlayer:StaticPlayer
--- Properties
---@field accounts ESXAccount[]     # Array of the player's accounts.
---@field coords table              # Player's coordinates {x, y, z, heading}.
---@field group string              # Player permission group.
---@field identifier string         # Unique identifier (usually Steam or license).
---@field license string            # Player license string.
---@field inventory ESXInventoryItem[] # Player's inventory items.
---@field job ESXJob                # Player's current job.
---@field loadout ESXInventoryWeapon[] # Player's current weapons.
---@field name string               # Player's display name.
---@field playerId number           # Player's ID (server ID).
---@field source number             # Player's source (alias for playerId).
---@field variables table           # Custom player variables.
---@field weight number             # Current carried weight.
---@field maxWeight number          # Maximum carry weight.
---@field metadata table            # Custom metadata table.
---@field lastPlaytime number       # Last recorded playtime in seconds.
---@field paycheckEnabled boolean   # Whether paycheck is enabled.
---@field admin boolean             # Whether the player is an admin.

---@param playerId number
---@param identifier string
---@param ssn string
---@param group string
---@param accounts ESXAccount[]
---@param inventory table
---@param weight number
---@param job ESXJob
---@param loadout ESXInventoryWeapon[]
---@param name string
---@param coords vector4|{x: number, y: number, z: number, heading: number}
---@param metadata table
---@return xPlayer
function CreateExtendedPlayer(playerId, identifier, ssn, group, accounts, inventory, weight, job, loadout, name, coords, metadata)
    ---@diagnostic disable-next-line: missing-fields
    local self = {} ---@type xPlayer

    self.accounts = accounts
    self.coords = coords
    self.group = group
    self.identifier = identifier
    self.ssn = ssn
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
    self.lastPlaytime = self.metadata.lastPlaytime or 0
    self.paycheckEnabled = true
    self.admin = Core.IsPlayerAdmin(playerId)
    if Config.Multichar then
        local startIndex = identifier:find(":", 1)
        if startIndex then
            self.license = ("%s%s"):format(Config.Identifier, identifier:sub(startIndex, identifier:len()))
        end
    else
        self.license = ("%s:%s"):format(Config.Identifier, identifier)
    end

    if type(self.metadata.jobDuty) ~= "boolean" then
        self.metadata.jobDuty = self.job.name ~= "unemployed" and Config.DefaultJobDuty or false
    end
    job.onDuty = self.metadata.jobDuty

    ExecuteCommand(("add_principal identifier.%s group.%s"):format(self.license, self.group))

    local stateBag = Player(self.source).state
    stateBag:set("identifier", self.identifier, false)
    stateBag:set("license", self.license, false)
    stateBag:set("job", self.job, true)
    stateBag:set("group", self.group, true)
    stateBag:set("name", self.name, true)

    function self.triggerEvent(eventName, ...)
        assert(type(eventName) == "string", "eventName should be string!")
        TriggerClientEvent(eventName, self.source, ...)
    end

    function self.togglePaycheck(toggle)
        self.paycheckEnabled = toggle
    end

    function self.isPaycheckEnabled()
        return self.paycheckEnabled
    end

    function self.isAdmin()
        return Core.IsPlayerAdmin(self.source)
    end

    function self.setCoords(coordinates)
        local ped <const> = GetPlayerPed(self.source)

        SetEntityCoords(ped, coordinates.x, coordinates.y, coordinates.z, false, false, false, false)
        SetEntityHeading(ped, coordinates.w or coordinates.heading or 0.0)
    end

    function self.getCoords(vector, heading)
        local ped <const> = GetPlayerPed(self.source)
        local entityCoords <const> = GetEntityCoords(ped)
        local entityHeading <const> = GetEntityHeading(ped)

        local coordinates = { x = entityCoords.x, y = entityCoords.y, z = entityCoords.z }

        if vector then
            coordinates = (heading and vector4(entityCoords.x, entityCoords.y, entityCoords.z, entityHeading) or entityCoords)
        else
            if heading then
                coordinates.heading = entityHeading
            end
        end

        return coordinates
    end

    function self.kick(reason)
        DropPlayer(self.source --[[@as string]], reason)
    end

    function self.getPlayTime()
        -- luacheck: ignore
        return self.lastPlaytime + GetPlayerTimeOnline(self.source --[[@as string]])
    end

    function self.setMoney(money)
        assert(type(money) == "number", "money should be number!")
        money = ESX.Math.Round(money)
        self.setAccountMoney("money", money)
    end

    function self.getMoney()
        return self.getAccount("money").money
    end

    function self.addMoney(money, reason)
        money = ESX.Math.Round(money)
        self.addAccountMoney("money", money, reason)
    end

    function self.removeMoney(money, reason)
        money = ESX.Math.Round(money)
        self.removeAccountMoney("money", money, reason)
    end

    function self.getIdentifier()
        return self.identifier
    end

    function self.getSSN()
        return self.ssn
    end

    function self.setGroup(newGroup)
        local lastGroup = self.group

        ExecuteCommand(("remove_principal identifier.%s group.%s"):format(self.license, self.group))

        self.group = newGroup

        TriggerEvent("esx:setGroup", self.source, self.group, lastGroup)
        self.triggerEvent("esx:setGroup", self.group, lastGroup)
        Player(self.source).state:set("group", self.group, true)

        ExecuteCommand(("add_principal identifier.%s group.%s"):format(self.license, self.group))
    end

    function self.getGroup()
        return self.group
    end

    function self.set(k, v)
        self.variables[k] = v

        self.triggerEvent('esx:updatePlayerData', 'variables', self.variables)
    end

    function self.get(k)
        return self.variables[k]
    end

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

    function self.getAccount(account)
        account = string.lower(account)
        for i = 1, #self.accounts do
            local accountName = string.lower(self.accounts[i].name)
            if accountName == account then
                return self.accounts[i]
            end
        end
        return nil
    end

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

    function self.getJob()
        return self.job
    end

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

    function self.getName()
        return self.name
    end

    function self.setName(newName)
        self.name = newName
        Player(self.source).state:set("name", self.name, true)
    end

    function self.setAccountMoney(accountName, money, reason)
        reason = reason or "unknown"
        if not tonumber(money) then
            error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(accountName, self.playerId, money))
            return
        end
        if money >= 0 then
            local account = self.getAccount(accountName)

            if account then
                money = account.round and ESX.Math.Round(money) or money
                self.accounts[account.index].money = money

                self.triggerEvent("esx:setAccountMoney", account)
                TriggerEvent("esx:setAccountMoney", self.source, accountName, money, reason)
            else
                error(("Tried To Set Invalid Account ^5%s^1 For Player ^5%s^1!"):format(accountName, self.playerId))
            end
        else
            error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(accountName, self.playerId, money))
        end
    end

    function self.addAccountMoney(accountName, money, reason)
        reason = reason or "Unknown"
        if not tonumber(money) then
            error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(accountName, self.playerId, money))
            return
        end
        if money > 0 then
            local account = self.getAccount(accountName)
            if account then
                money = account.round and ESX.Math.Round(money) or money
                self.accounts[account.index].money = self.accounts[account.index].money + money

                self.triggerEvent("esx:setAccountMoney", account)
                TriggerEvent("esx:addAccountMoney", self.source, accountName, money, reason)
            else
                error(("Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!"):format(accountName, self.playerId))
            end
        else
            error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(accountName, self.playerId, money))
        end
    end

    function self.removeAccountMoney(accountName, money, reason)
        reason = reason or "Unknown"
        if not tonumber(money) then
            error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(accountName, self.playerId, money))
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

                self.triggerEvent("esx:setAccountMoney", account)
                TriggerEvent("esx:removeAccountMoney", self.source, accountName, money, reason)
            else
                error(("Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!"):format(accountName, self.playerId))
            end
        else
            error(("Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1"):format(accountName, self.playerId, money))
        end
    end

    function self.getInventoryItem(itemName)
        for _, v in ipairs(self.inventory) do
            if v.name == itemName then
                return v
            end
        end
        return nil
    end

    function self.addInventoryItem(itemName, count)
        local item = self.getInventoryItem(itemName)

        if item then
            count = ESX.Math.Round(count)
            item.count = item.count + count
            self.weight = self.weight + (item.weight * count)

            TriggerEvent("esx:onAddInventoryItem", self.source, item.name, item.count)
            self.triggerEvent("esx:addInventoryItem", item.name, item.count)
        end
    end

    function self.removeInventoryItem(itemName, count)
        local item = self.getInventoryItem(itemName)

        if item then
            count = ESX.Math.Round(count)
            if count > 0 then
                local newCount = item.count - count

                if newCount >= 0 then
                    item.count = newCount
                    self.weight = self.weight - (item.weight * count)

                    TriggerEvent("esx:onRemoveInventoryItem", self.source, item.name, item.count)
                    self.triggerEvent("esx:removeInventoryItem", item.name, item.count)
                end
            else
                error(("Player ID:^5%s Tried remove a Invalid count -> %s of %s"):format(self.playerId, count, itemName))
            end
        end
    end

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

    function self.getWeight()
        return self.weight
    end

    function self.getSource()
        return self.source
    end
    self.getPlayerId = self.getSource

    function self.getMaxWeight()
        return self.maxWeight
    end

    function self.canCarryItem(itemName, count)
        if ESX.Items[itemName] then
            local currentWeight, itemWeight = self.weight, ESX.Items[itemName].weight
            local newWeight = currentWeight + (itemWeight * count)

            return newWeight <= self.maxWeight
        else
            print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(itemName))
            return false
        end
    end

    function self.canSwapItem(firstItem, firstItemCount, testItem, testItemCount)
        local firstItemObject = self.getInventoryItem(firstItem)
        if not firstItemObject then
            return false
        end
        local testItemObject = self.getInventoryItem(testItem)
        if not testItemObject then
            return false
        end

        if firstItemObject.count >= firstItemCount then
            local weightWithoutFirstItem = ESX.Math.Round(self.weight - (firstItemObject.weight * firstItemCount))
            local weightWithTestItem = ESX.Math.Round(weightWithoutFirstItem + (testItemObject.weight * testItemCount))

            return weightWithTestItem <= self.maxWeight
        end

        return false
    end

    function self.setMaxWeight(newWeight)
        self.maxWeight = newWeight
        self.triggerEvent("esx:setMaxWeight", self.maxWeight)
    end

    function self.setJob(newJob, grade, onDuty)
        grade = tostring(grade)
        local lastJob = self.job

        if not ESX.DoesJobExist(newJob, grade) then
            return print(("[ESX] [^3WARNING^7] Ignoring invalid ^5.setJob()^7 usage for ID: ^5%s^7, Job: ^5%s^7"):format(self.source, newJob))
        end

        if newJob == "unemployed" then
            onDuty = false
        end

        if type(onDuty) ~= "boolean" then
            onDuty = Config.DefaultJobDuty
        end

        local jobObject, gradeObject = ESX.Jobs[newJob], ESX.Jobs[newJob].grades[grade]

        self.job = {
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

        self.metadata.jobDuty = onDuty
        TriggerEvent("esx:setJob", self.source, self.job, lastJob)
        self.triggerEvent("esx:setJob", self.job, lastJob)
        Player(self.source).state:set("job", self.job, true)
    end

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

            GiveWeaponToPed(GetPlayerPed(self.source), joaat(weaponName), ammo, false, false)
            self.triggerEvent("esx:addInventoryItem", weaponLabel, false, true)
            self.triggerEvent("esx:addLoadoutItem", weaponName, weaponLabel, ammo)
        end
    end

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

    function self.addWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo + ammoCount
            SetPedAmmo(GetPlayerPed(self.source), joaat(weaponName), weapon.ammo)
        end
    end

    function self.updateWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if not weapon then
            return
        end

        weapon.ammo = ammoCount

        if weapon.ammo <= 0 then
            local _, weaponConfig = ESX.GetWeapon(weaponName)
            if weaponConfig.throwable then
                self.removeWeapon(weaponName)
            end
        end
    end

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

    function self.getWeaponTint(weaponName)
        local _, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            return weapon.tintIndex
        end

        return 0
    end

    function self.removeWeapon(weaponName)
        local weaponLabel, playerPed <const> = nil, GetPlayerPed(self.source)

        if not playerPed then
            return error("xPlayer.removeWeapon ^5invalid^1 player ped!")
        end

        for k, v in ipairs(self.loadout) do
            if v.name == weaponName then
                weaponLabel = v.label

                for _, v2 in ipairs(v.components) do
                    self.removeWeaponComponent(weaponName, v2)
                end

                local weaponHash = joaat(v.name)
                RemoveWeaponFromPed(playerPed, weaponHash)
                SetPedAmmo(playerPed, weaponHash, 0)

                table.remove(self.loadout, k)
                break
            end
        end

        if weaponLabel then
            self.triggerEvent("esx:removeInventoryItem", weaponLabel, false, true)
            self.triggerEvent("esx:removeLoadoutItem", weaponName, weaponLabel)
        end
    end

    function self.removeWeaponComponent(weaponName, weaponComponent)
        local loadoutNum <const>, weapon <const> = self.getWeapon(weaponName)

        if weapon then
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

    function self.removeWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo - ammoCount
            SetPedAmmo(GetPlayerPed(self.source), joaat(weaponName), weapon.ammo)
        end
    end

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

    function self.hasWeapon(weaponName)
        for _, v in ipairs(self.loadout) do
            if v.name == weaponName then
                return true
            end
        end

        return false
    end

    function self.hasItem(item)
        for _, v in ipairs(self.inventory) do
            if v.name == item and v.count >= 1 then
                return v, v.count
            end
        end

        return false
    end

    function self.getWeapon(weaponName)
        for k, v in ipairs(self.loadout) do
            if v.name == weaponName then
                return k, v
            end
        end

        return nil, nil
    end

    function self.showNotification(msg, notifyType, length, title, position)
        self.triggerEvent("esx:showNotification", msg, notifyType, length, title, position)
    end

    function self.showAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
        self.triggerEvent("esx:showAdvancedNotification", sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    end

    function self.showHelpNotification(msg, thisFrame, beep, duration)
        self.triggerEvent("esx:showHelpNotification", msg, thisFrame, beep, duration)
    end

    function self.getMeta(index, subIndex)
        if not index then
            return self.metadata
        end

        if type(index) ~= "string" then
            error("xPlayer.getMeta ^5index^1 should be ^5string^1!")
            return
        end

        local metaData = self.metadata[index]
        if metaData == nil then
            return Config.EnableDebug and error(("xPlayer.getMeta ^5%s^1 not exist!"):format(index)) or nil
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
                        error(("xPlayer.getMeta subIndex should be ^5string^1 or ^5table^1! that contains ^5string^1, received ^5%s^1!, skipping..."):format(type(key)))
                    end
                end

                return returnValues
            end

            error(("xPlayer.getMeta subIndex should be ^5string^1 or ^5table^1!, received ^5%s^1!"):format(_type))
            return
        end

        return metaData
    end

    function self.setMeta(index, value, subValue)
        if not index then
            return error("xPlayer.setMeta ^5index^1 is Missing!")
        end

        if type(index) ~= "string" then
            return error("xPlayer.setMeta ^5index^1 should be ^5string^1!")
        end

        if value == nil then
            return error("xPlayer.setMeta value is missing!")
        end

        local _type = type(value)

        if not subValue then
            if _type ~= "number" and _type ~= "string" and _type ~= "table" then
                return error(("xPlayer.setMeta ^5%s^1 should be ^5number^1 or ^5string^1 or ^5table^1!"):format(value))
            end

            self.metadata[index] = value
        else
            if _type ~= "string" then
                return error(("xPlayer.setMeta ^5value^1 should be ^5string^1 as a subIndex!"):format(value))
            end

            if not self.metadata[index] or type(self.metadata[index]) ~= "table" then
                self.metadata[index] = {}
            end

            self.metadata[index] = type(self.metadata[index]) == "table" and self.metadata[index] or {}
            self.metadata[index][value] = subValue
        end
        self.triggerEvent('esx:updatePlayerData', 'metadata', self.metadata)
    end

    function self.clearMeta(index, subValues)
        if not index then
            return error("xPlayer.clearMeta ^5index^1 is Missing!")
        end

        if type(index) ~= "string" then
            return error("xPlayer.clearMeta ^5index^1 should be ^5string^1!")
        end

        local metaData = self.metadata[index]
        if metaData == nil then
            if Config.EnableDebug then
                error(("xPlayer.clearMeta ^5%s^1 does not exist!"):format(index))
            end

            return
        end

        if not subValues then
            -- If no subValues is provided, we will clear the entire value in the metaData table
            self.metadata[index] = nil
        elseif type(subValues) == "string" then
            -- If subValues is a string, we will clear the specific subValue within the table
            if type(metaData) == "table" then
                metaData[subValues] = nil
            else
                return error(("xPlayer.clearMeta ^5%s^1 is not a table! Cannot clear subValue ^5%s^1."):format(index, subValues))
            end
        elseif type(subValues) == "table" then
            -- If subValues is a table, we will clear multiple subValues within the table
            for i = 1, #subValues do
                local subValue = subValues[i]
                if type(subValue) == "string" then
                    if type(metaData) == "table" then
                        metaData[subValue] = nil
                    else
                        error(("xPlayer.clearMeta ^5%s^1 is not a table! Cannot clear subValue ^5%s^1."):format(index, subValue))
                    end
                else
                    error(("xPlayer.clearMeta subValues should contain ^5string^1, received ^5%s^1, skipping..."):format(type(subValue)))
                end
            end
        else
            return error(("xPlayer.clearMeta ^5subValues^1 should be ^5string^1 or ^5table^1, received ^5%s^1!"):format(type(subValues)))
        end
        self.triggerEvent('esx:updatePlayerData', 'metadata', self.metadata)
    end

    function self.executeCommand(command)
        if type(command) ~= "string" then
            error("xPlayer.executeCommand must be of type string!")
            return
        end

        self.triggerEvent("esx:executeCommand", command)
    end

    for _, funcs in pairs(Core.PlayerFunctionOverrides) do
        for fnName, fn in pairs(funcs) do
            self[fnName] = fn(self)
        end
    end

    return self
end

local function runStaticPlayerMethod(src, method, ...)
    local xPlayer = ESX.Players[src]
    if not xPlayer then
        return
    end

    if not ESX.IsFunctionReference(xPlayer[method]) then
        error(("Attempted to call invalid method on playerId %s: %s"):format(src, method))
    end

    return xPlayer[method](...)
end
exports("RunStaticPlayerMethod", runStaticPlayerMethod)
