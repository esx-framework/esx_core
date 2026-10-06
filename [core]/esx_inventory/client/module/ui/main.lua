-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Inventory = ESXInventory

local uiReady = false

function Inventory.useItem(itemType, name)
    if not ESX.PlayerLoaded then
        return false
    end

    if ESX.PlayerData.dead or type(name) ~= 'string' then
        return false
    end

    local item = Inventory.getOwnedItem(itemType, name)

    if not item then
        return false
    end

    if itemType == 'item_standard' then
        if item.count > 0 and item.usable then
            TriggerServerEvent('esx:useItem', name)
            return true
        end
    elseif itemType == 'item_weapon' then
        local ped = PlayerPedId()
        local weaponHash = joaat(name)

        if not HasPedGotWeapon(ped, weaponHash, false) then
            return false
        end

        local selected = GetSelectedPedWeapon(ped)
        local target = selected == weaponHash and joaat('WEAPON_UNARMED') or weaponHash

        SetCurrentPedWeapon(ped, target, true)
        return true
    end

    return false
end

---@return nil
function Inventory.pushState()
    local items = Inventory.buildItems()

    xLib.nui.send({
        action = 'state',
        items = items,
        slotCount = Inventory.computeSlotCount(items),
        maxWeight = ESX.PlayerData.maxWeight or 0,
        storage = Inventory.currentStorage,
    })
end

---@return nil
function Inventory.open()
    if
        Inventory.isOpen
        or not uiReady
        or not ESX.PlayerLoaded
        or ESX.PlayerData.dead
        or IsPauseMenuActive()
    then
        return
    end

    Inventory.isOpen = true

    xLib.nui.send({
        action = 'open',
        locale = Inventory.buildLocale(),
        theme = Inventory.buildTheme(),
        hotbarSlots = Config.HotbarSlots,
    })
    Inventory.pushState()
    xLib.nui.focus(true, true)
end

---@param fromNui boolean?
---@return nil
function Inventory.close(fromNui)
    if not Inventory.isOpen then
        return
    end

    Inventory.isOpen = false
    local hadStorage = Inventory.currentStorage ~= nil
    Inventory.currentStorage = nil

    xLib.nui.focus(false, false)

    if not fromNui then
        xLib.nui.send({ action = 'close' })
    end

    if hadStorage then
        TriggerServerEvent('esx_inventory:storageClosed')
    end
end

exports('ShowInventory', Inventory.open)

xLib.nui.register('ready', function()
    uiReady = true

    if Inventory.isOpen then
        Inventory.close(true)
    end

    return {}
end)

xLib.nui.register('close', function()
    if Inventory.isOpen then
        Inventory.close(true)
    else
        xLib.nui.focus(false, false)
    end

    return {}
end)

xLib.nui.register('saveSlots', function(data, reply)
    reply({})

    if type(data) ~= 'table' or type(data.slots) ~= 'table' then
        return xLib.nui.defer
    end

    for key, slot in pairs(data.slots) do
        if type(key) == 'string' and type(slot) == 'number' and slot >= 0 then
            Inventory.setSlot(key, math.floor(slot))
        end
    end

    Inventory.saveSlotMap()
    return xLib.nui.defer
end)

xLib.nui.register('useItem', function(data, reply)
    reply({})

    if type(data) ~= 'table' then
        return xLib.nui.defer
    end

    Inventory.useItem(data.type, data.name)
    return xLib.nui.defer
end)

xLib.nui.register('giveItem', function(data, reply)
    reply({})

    if
        type(data) ~= 'table'
        or type(data.name) ~= 'string'
        or not Inventory.ITEM_TYPES[data.type]
    then
        return xLib.nui.defer
    end

    local target = tonumber(data.target)
    local count = tonumber(data.count)

    if not target or not count or count < 1 then
        return xLib.nui.defer
    end

    TriggerServerEvent(
        'esx:giveInventoryItem',
        math.floor(target),
        data.type,
        data.name,
        math.floor(count)
    )
    return xLib.nui.defer
end)

xLib.nui.register('giveAmmo', function(data, reply)
    reply({})

    if type(data) ~= 'table' or type(data.name) ~= 'string' then
        return xLib.nui.defer
    end

    local target = tonumber(data.target)
    local count = tonumber(data.count)

    if not target or not count or count < 1 then
        return xLib.nui.defer
    end

    count = math.floor(count)

    if count > GetAmmoInPedWeapon(PlayerPedId(), joaat(data.name)) then
        ESX.ShowNotification(TranslateCap('noammo'))
        return xLib.nui.defer
    end

    TriggerServerEvent('esx:giveInventoryItem', math.floor(target), 'item_ammo', data.name, count)
    return xLib.nui.defer
end)

xLib.nui.register('dropItem', function(data, reply)
    reply({})

    if
        type(data) ~= 'table'
        or type(data.name) ~= 'string'
        or not Inventory.ITEM_TYPES[data.type]
    then
        return xLib.nui.defer
    end

    local count = tonumber(data.count)

    if not count or count < 1 then
        return xLib.nui.defer
    end

    TriggerServerEvent('esx:removeInventoryItem', data.type, data.name, math.floor(count))
    return xLib.nui.defer
end)

xLib.nui.register('getNearbyPlayers', function()
    local players = {}
    local myId = PlayerId()
    local myCoords = GetEntityCoords(PlayerPedId())

    for _, playerId in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(playerId)

        if playerId ~= myId and ped ~= 0 then
            local distance = #(myCoords - GetEntityCoords(ped))

            if distance <= Config.NearbyPlayerDistance then
                players[#players + 1] = {
                    id = GetPlayerServerId(playerId),
                    name = GetPlayerName(playerId),
                    distance = math.floor(distance * 10) / 10,
                }
            end
        end
    end

    table.sort(players, function(a, b)
        return a.distance < b.distance
    end)

    return players
end)

xLib.nui.register('storagePut', function(data, reply)
    reply({})

    if
        not Inventory.currentStorage
        or type(data) ~= 'table'
        or type(data.name) ~= 'string'
        or data.type ~= 'item_standard'
    then
        return xLib.nui.defer
    end

    local count = tonumber(data.count)

    if not count or count < 1 then
        return xLib.nui.defer
    end

    TriggerServerEvent('esx_inventory:storagePut', data.name, math.floor(count))
    return xLib.nui.defer
end)

xLib.nui.register('storageTake', function(data, reply)
    reply({})

    if not Inventory.currentStorage or type(data) ~= 'table' or type(data.name) ~= 'string' then
        return xLib.nui.defer
    end

    local count = tonumber(data.count)

    if not count or count < 1 then
        return xLib.nui.defer
    end

    TriggerServerEvent('esx_inventory:storageTake', data.name, math.floor(count))
    return xLib.nui.defer
end)

xLib.nui.register('uiError', function(data, reply)
    reply({})
    print('^1[esx_inventory:ui]^7', json.encode(data or {}))
    return xLib.nui.defer
end)
