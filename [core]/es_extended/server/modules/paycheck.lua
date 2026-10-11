-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local function getPaycheckBatchSize()
    return math.max(1, math.floor(tonumber(Config.PaycheckBatchSize) or 100))
end

local function getPaycheckBatchDelay()
    return math.max(0, math.floor(tonumber(Config.PaycheckBatchDelay) or 250))
end

local function getPaycheckJitter()
    return math.max(0, math.floor(tonumber(Config.PaycheckJitter) or 0))
end

local function getSociety(name)
    local society
    TriggerEvent("esx_society:getSociety", name, function(result)
        society = result
    end)
    return society
end

local function getSharedAccount(name)
    local account
    TriggerEvent("esx_addonaccount:getSharedAccount", name, function(result)
        account = result
    end)
    return account
end

local function resolveSocietyAccounts(xPlayers)
    local accounts = {}

    if not Config.EnableSocietyPayouts then
        return accounts
    end

    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        local jobName = xPlayer.job and xPlayer.job.name

        if jobName and accounts[jobName] == nil then
            local society = getSociety(jobName)

            if society then
                local account = getSharedAccount(society.account)
                accounts[jobName] = {
                    accountName = society.account,
                    account = account,
                    available = account and account.money or 0,
                    pendingDebit = 0,
                }
            else
                accounts[jobName] = false
            end
        end
    end

    return accounts
end

local function flushSocietyDebits(accounts)
    for _, entry in pairs(accounts) do
        if entry and entry.account then
            if entry.pendingDebit > 0 then
                entry.account.removeMoney(entry.pendingDebit)
                entry.pendingDebit = 0
            end

            local account = getSharedAccount(entry.accountName)
            if account then
                entry.account = account
                entry.available = account.money
            end
        end
    end
end

local function logPaycheck(title, xPlayer, salary)
    if not Config.LogPaycheck then
        return
    end

    ESX.DiscordLogFields("Paycheck", title, "green", {
        { name = "Player", value = xPlayer.name, inline = true },
        { name = "ID", value = xPlayer.source, inline = true },
        { name = "Amount", value = salary, inline = true },
    })
end

local function payPlayer(xPlayer, societyAccounts, bankTitle, receivedPaycheck)
    local player = xPlayer.source

    if ESX.GetPlayerFromId(player) ~= xPlayer then
        return
    end

    local jobLabel = xPlayer.job.label
    local job = xPlayer.job.grade_name
    local onDuty = xPlayer.job.onDuty
    local salary = (job == "unemployed" or onDuty) and xPlayer.job.grade_salary or ESX.Math.Round(xPlayer.job.grade_salary * Config.OffDutyPaycheckMultiplier)

    if not xPlayer.paycheckEnabled or salary <= 0 then
        return
    end

    if job == "unemployed" then
        xPlayer.addAccountMoney("bank", salary, "Welfare Check")
        TriggerClientEvent(
            "esx:showAdvancedNotification",
            player,
            bankTitle,
            receivedPaycheck,
            TranslateCap("received_help", salary),
            "CHAR_BANK_MAZE",
            9
        )
        logPaycheck("Paycheck - Unemployment Benefits", xPlayer, salary)
        return
    end

    if Config.EnableSocietyPayouts then
        local societyEntry = societyAccounts[xPlayer.job.name]

        if societyEntry then
            if societyEntry.account and societyEntry.available >= salary then
                societyEntry.available -= salary
                societyEntry.pendingDebit += salary
                xPlayer.addAccountMoney("bank", salary, "Paycheck")
                TriggerClientEvent(
                    "esx:showAdvancedNotification",
                    player,
                    bankTitle,
                    receivedPaycheck,
                    TranslateCap("received_salary", salary),
                    "CHAR_BANK_MAZE",
                    9
                )
                logPaycheck("Paycheck - " .. jobLabel, xPlayer, salary)
            else
                TriggerClientEvent(
                    "esx:showAdvancedNotification",
                    player,
                    bankTitle,
                    "",
                    TranslateCap("company_nomoney"),
                    "CHAR_BANK_MAZE",
                    1
                )
            end

            return
        end

        xPlayer.addAccountMoney("bank", salary, "Paycheck")
        TriggerClientEvent(
            "esx:showAdvancedNotification",
            player,
            bankTitle,
            receivedPaycheck,
            TranslateCap("received_salary", salary),
            "CHAR_BANK_MAZE",
            9
        )
        logPaycheck("Paycheck - " .. jobLabel, xPlayer, salary)
        return
    end

    xPlayer.addAccountMoney("bank", salary, "Paycheck")
    TriggerClientEvent(
        "esx:showAdvancedNotification",
        player,
        bankTitle,
        receivedPaycheck,
        TranslateCap("received_salary", salary),
        "CHAR_BANK_MAZE",
        9
    )
    logPaycheck("Paycheck - Generic", xPlayer, salary)
end

function StartPayCheck()
    CreateThread(function()
        while true do
            Wait(Config.PaycheckInterval)

            local jitter = getPaycheckJitter()
            if jitter > 0 then
                Wait(math.random(jitter))
            end

            local xPlayers = ESX.GetExtendedPlayers()
            local societyAccounts = resolveSocietyAccounts(xPlayers)
            local batchSize = getPaycheckBatchSize()
            local batchDelay = getPaycheckBatchDelay()
            local bankTitle = TranslateCap("bank")
            local receivedPaycheck = TranslateCap("received_paycheck")

            for i = 1, #xPlayers do
                payPlayer(xPlayers[i], societyAccounts, bankTitle, receivedPaycheck)

                if i % batchSize == 0 then
                    flushSocietyDebits(societyAccounts)
                    Wait(batchDelay)
                end
            end

            flushSocietyDebits(societyAccounts)
        end
    end)
end
