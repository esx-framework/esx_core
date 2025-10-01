---@class InventoryElement
---@field type "item_account" | "item_standard" | "item_weapon"
---@field label string
---@field icon string
---@field count number
---@field value string
---@field usable boolean
---@field rare boolean
---@field canRemove boolean
---@field unselectable boolean?
---@field ammo number?
---@field canGiveAmmo boolean?

---@alias InventoryAction "use" | "give" | "remove" | "give_ammo" | "return"

if not ESX.GetConfig("EnableDefaultInventory") then
    error("ESX Default Inventory is disabled in config, please enable it to use this resource.")
end

--------------------------------
-- Inventory Element Builders --
--------------------------------

---@param elements InventoryElement[]
local function appendAccounts(elements)
    for i = 1, #(ESX.PlayerData.accounts) do
        local account = ESX.PlayerData.accounts[i]
        if account.money > 0 then
            local formattedMoney = TranslateCap("locale_currency", ESX.Math.GroupDigits(account.money))
            local canDrop = account.name ~= "bank"
            elements[#elements + 1] = {
                type = "item_account",
                label = ('%s: <span style="color:green;">%s</span>'):format(account.label, formattedMoney),
                icon = "fas fa-money-bill-wave",
                count = account.money,
                value = account.name,
                usable = false,
                rare = false,
                canRemove = canDrop
            }
        end
    end
end

---@param elements InventoryElement[]
---@return number
local function appendItems(elements)
    local weight = 0
    for i = 1, #ESX.PlayerData.inventory do
        local item = ESX.PlayerData.inventory[i]
        if item.count > 0 then
            weight = weight + (item.weight * item.count)
            elements[#elements + 1] = {
                type = "item_standard",
                label = ("%s x%s"):format(item.label, item.count),
                icon = "fas fa-box",
                count = item.count,
                value = item.name,
                usable = item.usable,
                rare = item.rare,
                canRemove = item.canRemove
            }
        end
    end

    return weight
end

---@param elements InventoryElement[]
---@return number
local function appendLoadout(elements)
    local weight = 0
    local playerPed = ESX.PlayerData.ped

    for i = 1, #ESX.PlayerData.loadout do
        local weapon = ESX.PlayerData.loadout[i]
        local weaponHash = joaat(weapon.name)
        local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
        local label = weapon.ammo and ("%s - %s %s"):format(weapon.label, weapon.ammo, TranslateCap("ammo_rounds")) or weapon.label
        elements[#elements + 1] = {
            type = "item_weapon",
            label = label,
            icon = "fas fa-gun",
            count = 1,
            value = weapon.name,
            usable = false,
            rare = false,
            ammo = ammo,
            canGiveAmmo = (weapon.ammo ~= nil),
            canRemove = true
        }
    end

    return weight
end

---@return InventoryElement[], number
local function buildInventoryElements()
    local elements = {} ---@type InventoryElement[]
    local totalWeight = 0
    appendAccounts(elements)
    totalWeight += appendItems(elements)
    totalWeight += appendLoadout(elements)
    ---@diagnostic disable-next-line: missing-fields
    elements[#elements + 1] = {
        label = "Current Weight: " .. totalWeight,
        icon = "fas fa-box",
        usable = false
    }
    return elements, totalWeight
end

---------------------------------
-- Item Action Menu & Handling --
---------------------------------

---@param selected InventoryElement
---@param playerNearby boolean
---@return table
local function buildItemActionMenu(selected, playerNearby)
    local elements2 = {}
    if selected.usable then
        elements2[#elements2 + 1] = { action = "use", label = TranslateCap("use"), icon = "fas fa-utensils", type = selected.type, value = selected.value }
    end
    if selected.canRemove then
        if playerNearby then
            elements2[#elements2 + 1] = { action = "give", label = TranslateCap("give"), icon = "fas fa-hands", type = selected.type, value = selected.value }
        end
        elements2[#elements2 + 1] = { action = "remove", label = TranslateCap("remove"), icon = "fas fa-trash", type = selected.type, value = selected.value }
    end
    if selected.type == "item_weapon" and selected.canGiveAmmo and selected.ammo > 0 and playerNearby then
        elements2[#elements2 + 1] = { action = "give_ammo", label = TranslateCap("giveammo"), icon = "fas fa-gun", type = selected.type, value = selected.value }
    end
    elements2[#elements2 + 1] = { action = "return", label = TranslateCap("return"), icon = "fas fa-arrow-left", disableRightArrow = true }
    return elements2
end

---@param title string
---@param maxCount number
---@return number?
local function openQuantityDialog(title, maxCount)
    local p = promise:new()
    ESX.UI.Menu.Open("dialog", ESX.currentResourceName, "esx_inventory_quantity", {
        title = title
    }, function(data, menu)
        local qty = tonumber(data.value)
        if not qty or qty <= 0 or qty > maxCount then
            ESX.ShowNotification(TranslateCap("amount_invalid"))
            p:resolve(nil)
        else
            menu.close()
            p:resolve(qty)
        end
    end, function(_, menu)
        menu.close()
        p:resolve(nil)
    end)

    return Citizen.Await(p)
end

---@param action InventoryAction
---@param selected InventoryElement
---@param closestPlayer number
local function handleInventoryAction(action, selected, closestPlayer)
    local itemType, itemName, playerPed = selected.type, selected.value, ESX.PlayerData.ped
    if action == "give" then
        local qty = openQuantityDialog(TranslateCap("amount"), selected.count)
        if not qty then return end
        TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(closestPlayer), itemType, itemName, qty)
    elseif action == "remove" then
        local qty = openQuantityDialog(TranslateCap("amount"), selected.count)
        if not qty then return end
        TriggerServerEvent("esx:removeInventoryItem", itemType, itemName, qty)
    elseif action == "use" then
        TriggerServerEvent("esx:useItem", itemName)
    elseif action == "give_ammo" then
        local pedAmmo = GetAmmoInPedWeapon(playerPed, joaat(itemName))
        local qty = openQuantityDialog(TranslateCap("amount"), pedAmmo)
        if not qty then return end
        TriggerServerEvent("esx:giveInventoryItem", GetPlayerServerId(closestPlayer), "item_ammo", itemName, qty)
    end
end

----------------------
-- Main Inventory UI --
----------------------

local function showInventory()
    local elements, totalWeight = buildInventoryElements()
    ESX.UI.Menu.Open("default", ESX.currentResourceName, "esx_inventory_main", {
        title = TranslateCap("inventory", totalWeight, ESX.PlayerData.maxWeight),
        elements = elements,
    }, function(data, menu)
        local selected = data.current --[[@as InventoryElement]]
        if selected.unselectable then return end

        local closestPlayer, dist = ESX.Game.GetClosestPlayer()
        local playerNearby = closestPlayer ~= -1 and dist <= 3.0

        ESX.UI.Menu.Open("default", ESX.currentResourceName, "esx_inventory_actions", {
            title = selected.label,
            elements = buildItemActionMenu(selected, playerNearby),
        }, function(data2, menu2)
            local action = data2.current.action
            if action == "return" then
                menu2.close()
                return
            end
            handleInventoryAction(action, selected, closestPlayer)
        end, function(_, menu2) menu2.close() end)
    end, function(_, menu) menu.close() end)
end
exports("ShowInventory", showInventory)

ESX.RegisterInput("showinv", TranslateCap("keymap_showinventory"), "keyboard", "F2", function()
    if not ESX.PlayerData.dead then
        showInventory()
    end
end)

local function refreshInventory()
    if not ESX.UI.Menu.IsOpen("default", ESX.currentResourceName, "esx_inventory_main") and
        not ESX.UI.Menu.IsOpen("default", ESX.currentResourceName, "esx_inventory_actions") and
        not ESX.UI.Menu.IsOpen("dialog", ESX.currentResourceName, "esx_inventory_quantity") then
        return
    end
    Citizen.Wait(0)
    ESX.UI.Menu.CloseAll()
    showInventory()
end
RegisterNetEvent("esx:addInventoryItem", refreshInventory)
RegisterNetEvent("esx:removeInventoryItem", refreshInventory)
