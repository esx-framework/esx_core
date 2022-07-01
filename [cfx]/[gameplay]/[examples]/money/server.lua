local playerData = exports['cfx.re/playerData.v1alpha1']

local validMoneyTypes = {
    bank = true,
    cash = true,
}

local function getMoneyForId(playerId, moneyType)
    return GetResourceKvpInt(('money:%s:%s'):format(playerId, moneyType)) / 100.0
end

local function setMoneyForId(playerId, moneyType, money)
    local s = playerData:getPlayerById(playerId)

    TriggerEvent('money:updated', {
        dbId = playerId,
        source = s,
        moneyType = moneyType,
        money = money
    })

    return SetResourceKvpInt(('money:%s:%s'):format(playerId, moneyType), math.tointeger(money * 100.0))
end

local function addMoneyForId(playerId, moneyType, amount)
    local curMoney = getMoneyForId(playerId, moneyType)
    curMoney += amount

    if curMoney >= 0 then
        setMoneyForId(playerId, moneyType, curMoney)
        return true, curMoney
    end

    return false, 0
end

exports('addMoney', function(playerIdx, moneyType, amount)
    amount = tonumber(amount)

    if amount <= 0 or amount > (1 << 30) then
        return false
    end

    if not validMoneyTypes[moneyType] then
        return false
    end

    local playerId = playerData:getPlayerId(playerIdx)
    local success, money = addMoneyForId(playerId, moneyType, amount)

    if success then
        Player(playerIdx).state['money_' .. moneyType] = money
    end

    return true
end)

exports('removeMoney', function(playerIdx, moneyType, amount)
    amount = tonumber(amount)

    if amount <= 0 or amount > (1 << 30) then
        return false
    end

    if not validMoneyTypes[moneyType] then
        return false
    end

    local playerId = playerData:getPlayerId(playerIdx)
    local success, money = addMoneyForId(playerId, moneyType, -amount)

    if success then
        Player(playerIdx).state['money_' .. moneyType] = money
    end

    return success
end)

exports('getMoney', function(playerIdx, moneyType)
    local playerId = playerData:getPlayerId(playerIdx)
    return getMoneyForId(playerId, moneyType)
end)

-- player display bits
AddEventHandler('money:updated', function(data)
    if data.source then
        TriggerClientEvent('money:displayUpdate', data.source, data.moneyType, data.money)
    end
end)

RegisterNetEvent('money:requestDisplay')

AddEventHandler('money:requestDisplay', function()
    local source = source
    local playerId = playerData:getPlayerId(source)

    for type, _ in pairs(validMoneyTypes) do
        local amount = getMoneyForId(playerId, type)
        TriggerClientEvent('money:displayUpdate', source, type, amount)

        Player(source).state['money_' .. type] = amount
    end
end)

RegisterCommand('earn', function(source, args)
    local type = args[1]
    local amount = tonumber(args[2])

    exports['money']:addMoney(source, type, amount)
end, true)

RegisterCommand('spend', function(source, args)
    local type = args[1]
    local amount = tonumber(args[2])

    if not exports['money']:removeMoney(source, type, amount) then
        print('you are broke??')
    end
end, true)