--[[
    Generic client-side player state cache, modelled on ox_lib cache.
    Framework agnostic: natives only, no ESX coupling.

    Loaded per-resource VM through the lazy loader. PlayerPedId() and friends
    return the same value in every client VM, so the cached values are correct
    in each resource that requires it.

    Exposes the live values as xLib.cache and emits `xLib:cache:<key>` (value, previous)
    whenever a tracked value changes. `coords` is read on demand from the live ped
    and never stored.
]]

local playerId = PlayerId()

local cache = setmetatable({
    playerId = playerId,
    ped = PlayerPedId(),
    vehicle = false,
    seat = false,
    weapon = false,
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

local function set(key, value)
    if cache[key] == value then
        return
    end

    local previous = cache[key]
    rawset(cache, key, value)
    TriggerEvent(("xLib:cache:%s"):format(key), value, previous)
end

local function getSeat(ped, vehicle)
    for seat = -1, 16 do
        if GetPedInVehicleSeat(vehicle, seat) == ped then
            return seat
        end
    end
    return false
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if ped ~= cache.ped then
            set("ped", ped)
        end

        ---@type integer|false
        local vehicle = GetVehiclePedIsIn(ped, false)
        vehicle = vehicle ~= 0 and vehicle or false

        if vehicle ~= cache.vehicle then
            set("vehicle", vehicle)
            set("seat", vehicle and getSeat(ped, vehicle) or false)
        elseif vehicle then
            local seat = getSeat(ped, vehicle)
            if seat ~= cache.seat then
                set("seat", seat)
            end
        end

        ---@type integer|false
        local weapon = GetSelectedPedWeapon(ped)
        weapon = weapon ~= `WEAPON_UNARMED` and weapon or false
        if weapon ~= cache.weapon then
            set("weapon", weapon)
        end

        Wait(100)
    end
end)

return cache
