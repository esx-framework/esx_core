local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('trickem:buyVehicle')
AddEventHandler('trickem:buyVehicle', function(model, price, vehicleName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local money = xPlayer.getAccount('bank').money

    if money >= price then
        xPlayer.removeAccountMoney('bank', price, "Purchased " .. vehicleName .. " from Groovy Rides")

        -- Generate a 70s style plate
        local plate = GeneratePlate()

        -- Store vehicle in database
        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)', {
            xPlayer.identifier,
            plate,
            json.encode({model = GetHashKey(model)}),
            'car',
            1 -- Stored in garage
        }, function(id)
            if id then
                TriggerClientEvent('esx:showNotification', source, '~g~Groovy! You bought a ' .. vehicleName .. ' for $' .. FormatMoney(price))
                TriggerClientEvent('esx:showNotification', source, '~y~Plate: ' .. plate .. ' - Pick it up from the garage!')
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Not enough bread in the bank, baby!')
    end
end)

function GeneratePlate()
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local nums = '0123456789'
    local plate = '7'

    -- Format: 7X NNN XX (70s style)
    plate = plate .. chars:sub(math.random(#chars), math.random(#chars))
    plate = plate .. ' '
    for i = 1, 3 do
        plate = plate .. nums:sub(math.random(#nums), math.random(#nums))
    end
    plate = plate .. ' '
    for i = 1, 2 do
        plate = plate .. chars:sub(math.random(#chars), math.random(#chars))
    end

    return plate
end

function FormatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end
