-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local playerId = PlayerId()

---@param ped integer
---@param vehicle integer
---@return integer|false
local function getSeat(ped, vehicle)
    for seat = -1, 16 do
        if GetPedInVehicleSeat(vehicle, seat) == ped then
            return seat
        end
    end
    return false
end

---@param ped integer
---@return integer|false
local function getVehicle(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    return vehicle ~= 0 and vehicle or false
end

---@param ped integer
---@return integer|false
local function getWeapon(ped)
    local weapon = GetSelectedPedWeapon(ped)
    return weapon ~= `WEAPON_UNARMED` and weapon or false
end

local initialPed = PlayerPedId()
local initialVehicle = getVehicle(initialPed)

local cache = setmetatable({
    playerId = playerId,
    ped = initialPed,
    vehicle = initialVehicle,
    seat = initialVehicle and getSeat(initialPed, initialVehicle) or false,
    weapon = getWeapon(initialPed),
}, {
    __index = function(self, key)
        if key == "coords" then
            return GetEntityCoords(self.ped)
        elseif key == "serverId" then
            -- resolved lazily: GetPlayerServerId can return -1 before the network
            -- session is ready, so only cache it once it is valid.
            local id = GetPlayerServerId(playerId)
            if id and id ~= -1 then
                rawset(self, "serverId", id)
            end
            return id
        end
    end,
})

local TRACKED_KEYS <const> = { "ped", "vehicle", "seat", "weapon" }

if GetCurrentResourceName() ~= xLib.name then
    for i = 1, #TRACKED_KEYS do
        local key = TRACKED_KEYS[i]
        AddEventHandler(("xLib:cache:%s"):format(key), function(value)
            rawset(cache, key, value)
        end)
    end

    return cache
end

for i = 1, #TRACKED_KEYS do
    rawset(cache, TRACKED_KEYS[i], nil)
end

---@param key string
---@param value any
local function set(key, value)
    if cache[key] == value then
        return
    end

    local previous = cache[key]
    rawset(cache, key, value)
    TriggerEvent(("xLib:cache:%s"):format(key), value, previous)
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if ped ~= cache.ped then
            set("ped", ped)
        end

        local vehicle = getVehicle(ped)

        if vehicle ~= cache.vehicle then
            set("vehicle", vehicle)
            set("seat", vehicle and getSeat(ped, vehicle) or false)
        elseif vehicle then
            local seat = getSeat(ped, vehicle)
            if seat ~= cache.seat then
                set("seat", seat)
            end
        end

        local weapon = getWeapon(ped)
        if weapon ~= cache.weapon then
            set("weapon", weapon)
        end

        Wait(100)
    end
end)

return cache
