local ESX = exports["es_extended"]:getSharedObject()

-- Buy a drink
RegisterNetEvent('trickem:buyDrink')
AddEventHandler('trickem:buyDrink', function(drinkName, price, health)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    -- Validate price
    if price < 0 or price > 50 then return end
    if health < 0 or health > 20 then return end

    if xPlayer.getAccount('money').money >= price then
        xPlayer.removeAccountMoney('money', price, "Bought " .. drinkName .. " at the disco")
        TriggerClientEvent('esx:showNotification', source, '~g~Enjoy your ' .. drinkName .. '! That\'s ~y~$' .. price .. '~g~ off your tab.')
        TriggerClientEvent('trickem:drinkEffect', source, health)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~Not enough bread for that drink, baby!')
    end
end)

-- DJ set completion
RegisterNetEvent('trickem:djSetComplete')
AddEventHandler('trickem:djSetComplete', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    xPlayer.addAccountMoney('money', Config.DJPayPerSet, "DJ set at the disco")
    TriggerClientEvent('esx:showNotification', source, '~g~Earned ~y~$' .. Config.DJPayPerSet .. '~g~ for your DJ set! Keep spinning!')
end)
