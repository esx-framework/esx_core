-- track down what we've added to global state
local sentState = {}

-- money system
local ms = exports['money']

-- get the fountain content from storage
local function getMoneyForId(fountainId)
    return GetResourceKvpInt(('money:%s'):format(fountainId)) / 100.0
end

-- set the fountain content in storage + state
local function setMoneyForId(fountainId, money)
    GlobalState['fountain_' .. fountainId] = math.tointeger(money)

    return SetResourceKvpInt(('money:%s'):format(fountainId), math.tointeger(money * 100.0))
end

-- get the nearest fountain to the player + ID
local function getMoneyFountain(id, source)
    local coords = GetEntityCoords(GetPlayerPed(source))

    for _, v in pairs(moneyFountains) do
        if v.id == id then
            if #(v.coords - coords) < 2.5 then
                return v
            end
        end
    end

    return nil
end

-- generic function for events
local function handleFountainStuff(source, id, pickup)
    -- if near the fountain we specify
    local fountain = getMoneyFountain(id, source)

    if fountain then
        -- and we can actually use the fountain already
        local player = Player(source)

        local nextUse = player.state['fountain_nextUse']
        if not nextUse then
            nextUse = 0
        end

        -- GetGameTimer ~ GetNetworkTime on client
        if nextUse <= GetGameTimer() then
            -- not rate limited
            local success = false
            local money = getMoneyForId(fountain.id)

            -- decide the op
            if pickup then
                -- if the fountain is rich enough to get the per-use amount
                if money >= fountain.amount then
                    -- give the player money
                    if ms:addMoney(source, 'cash', fountain.amount) then
                        money -= fountain.amount
                        success = true
                    end
                end
            else
                -- if the player is rich enough
                if ms:removeMoney(source, 'cash', fountain.amount) then
                    -- add to the fountain
                    money += fountain.amount
                    success = true
                end
            end

            -- save it and set the player's cooldown
            if success then
                setMoneyForId(fountain.id, money)
                player.state['fountain_nextUse'] = GetGameTimer() + GetConvarInt('moneyFountain_cooldown', 5000)
            end
        end
    end
end

-- event for picking up fountain->player
RegisterNetEvent('money_fountain:tryPickup')
AddEventHandler('money_fountain:tryPickup', function(id)
    handleFountainStuff(source, id, true)
end)

-- event for donating player->fountain
RegisterNetEvent('money_fountain:tryPlace')
AddEventHandler('money_fountain:tryPlace', function(id)
    handleFountainStuff(source, id, false)
end)

-- listener: if a new fountain is added, set its current money in state
CreateThread(function()
    while true do
        Wait(500)

        for _, fountain in pairs(moneyFountains) do
            if not sentState[fountain.id] then
                GlobalState['fountain_' .. fountain.id] = math.tointeger(getMoneyForId(fountain.id))

                sentState[fountain.id] = true
            end
        end
    end
end)