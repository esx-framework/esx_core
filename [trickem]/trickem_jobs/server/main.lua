local ESX = exports["es_extended"]:getSharedObject()

-- Job signup
RegisterNetEvent('trickem:signupJob')
AddEventHandler('trickem:signupJob', function(jobName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    -- Set the job
    xPlayer.setJob(jobName, 0)
    TriggerClientEvent('esx:showNotification', source, '~g~Welcome aboard! You\'re now working at the ' .. jobName .. ' gig.')
end)

-- Quit job
RegisterNetEvent('trickem:quitJob')
AddEventHandler('trickem:quitJob', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    xPlayer.setJob('unemployed', 0)
    TriggerClientEvent('esx:showNotification', source, '~o~You quit your gig. Hit the streets and find something new.')
end)

-- Taxi fare completion
RegisterNetEvent('trickem:taxiFareComplete')
AddEventHandler('trickem:taxiFareComplete', function(fare)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end
    if xPlayer.getJob().name ~= 'taxi' then return end

    -- Validate fare amount (prevent exploitation)
    if fare < 0 or fare > 500 then return end

    xPlayer.addAccountMoney('money', fare, "Taxi fare")
    TriggerClientEvent('esx:showNotification', source, '~g~Fare collected: ~y~$' .. fare .. '~g~. Keep cruising!')
end)

-- Fishing rewards
RegisterNetEvent('trickem:caughtFish')
AddEventHandler('trickem:caughtFish', function(fishName, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end
    if xPlayer.getJob().name ~= 'fisherman' then return end

    -- Validate price
    if price < 0 or price > 200 then return end

    xPlayer.addInventoryItem('fish', 1)
    TriggerClientEvent('esx:showNotification', source, '~g~' .. fishName .. ' added to your inventory!')
end)

-- Sell goods (fish, wood, ore)
RegisterNetEvent('trickem:sellGoods')
AddEventHandler('trickem:sellGoods', function(jobName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if jobName == "fisherman" then
        local fishItem = xPlayer.getInventoryItem('fish')
        if fishItem and fishItem.count > 0 then
            local count = fishItem.count
            local totalPrice = count * 22 -- Average fish price
            xPlayer.removeInventoryItem('fish', count)
            xPlayer.addAccountMoney('money', totalPrice, "Sold fish")
            TriggerClientEvent('esx:showNotification', source, '~g~Sold ' .. count .. ' fish for ~y~$' .. totalPrice)
        else
            TriggerClientEvent('esx:showNotification', source, '~r~You got nothing to sell, man!')
        end

    elseif jobName == "lumberjack" then
        local woodItem = xPlayer.getInventoryItem('wood')
        if woodItem and woodItem.count > 0 then
            local count = woodItem.count
            local totalPrice = count * 18
            xPlayer.removeInventoryItem('wood', count)
            xPlayer.addAccountMoney('money', totalPrice, "Sold wood")
            TriggerClientEvent('esx:showNotification', source, '~g~Sold ' .. count .. ' wood for ~y~$' .. totalPrice)
        else
            TriggerClientEvent('esx:showNotification', source, '~r~You got no wood to sell!')
        end

    elseif jobName == "miner" then
        local totalPrice = 0
        local itemsSold = 0

        local oreItems = {'iron', 'copper', 'gold', 'diamond'}
        local orePrices = {iron = 12, copper = 18, gold = 65, diamond = 150}

        for _, oreName in ipairs(oreItems) do
            local oreItem = xPlayer.getInventoryItem(oreName)
            if oreItem and oreItem.count > 0 then
                totalPrice = totalPrice + (oreItem.count * orePrices[oreName])
                itemsSold = itemsSold + oreItem.count
                xPlayer.removeInventoryItem(oreName, oreItem.count)
            end
        end

        if itemsSold > 0 then
            xPlayer.addAccountMoney('money', totalPrice, "Sold ore and gems")
            TriggerClientEvent('esx:showNotification', source, '~g~Sold ' .. itemsSold .. ' items for ~y~$' .. totalPrice)
        else
            TriggerClientEvent('esx:showNotification', source, '~r~You got no ore to sell, brother!')
        end
    end
end)

-- Harvest wood
RegisterNetEvent('trickem:harvestWood')
AddEventHandler('trickem:harvestWood', function(amount)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end
    if xPlayer.getJob().name ~= 'lumberjack' then return end

    -- Validate amount
    if amount < 1 or amount > 3 then return end

    xPlayer.addInventoryItem('wood', amount)
end)

-- Mine ore
RegisterNetEvent('trickem:minedOre')
AddEventHandler('trickem:minedOre', function(item, name, price)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end
    if xPlayer.getJob().name ~= 'miner' then return end

    -- Validate
    local validItems = {iron = true, copper = true, gold = true, diamond = true}
    if not validItems[item] then return end

    xPlayer.addInventoryItem(item, 1)
end)
