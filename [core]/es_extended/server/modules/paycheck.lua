function StartPayCheck()
    CreateThread(function()
        while true do
            Wait(Config.PaycheckInterval)
            for player, xPlayer in pairs(Core.Players) do
                local jobLabel = xPlayer.job.label
                local job = xPlayer.job.grade_name
                local salary = xPlayer.job.grade_salary
                local onDuty = xPlayer.job.onDuty
                local effectiveSalary = (job == "unemployed" or onDuty) and salary or ESX.Math.Round(salary * Config.OffDutyPaycheckMultiplier)
                
                if xPlayer.paycheckEnabled then
                    if effectiveSalary > 0 then
                        if job == "unemployed" then -- unemployed
                            xPlayer.addAccountMoney("bank", effectiveSalary, "Welfare Check")
                            TriggerClientEvent("esx:showAdvancedNotification", player, TranslateCap("bank"), TranslateCap("received_paycheck"), TranslateCap("received_help", effectiveSalary), "CHAR_BANK_MAZE", 9)
                            if Config.LogPaycheck then
                                ESX.DiscordLogFields("Paycheck", "Paycheck - Unemployment Benefits", "green", {
                                    { name = "Player", value = xPlayer.name, inline = true },
                                    { name = "ID", value = xPlayer.source, inline = true },
                                    { name = "Amount", value = effectiveSalary, inline = true },
                                })
                            end
                        elseif Config.EnableSocietyPayouts then -- possibly a society
                            TriggerEvent("esx_society:getSociety", xPlayer.job.name, function(society)
                                if society ~= nil then -- verified society
                                    TriggerEvent("esx_addonaccount:getSharedAccount", society.account, function(account)
                                        if account.money >= effectiveSalary then -- does the society money to pay its employees?
                                            xPlayer.addAccountMoney("bank", effectiveSalary, "Paycheck")
                                            account.removeMoney(effectiveSalary)
                                            if Config.LogPaycheck then
                                                ESX.DiscordLogFields("Paycheck", "Paycheck - " .. jobLabel, "green", {
                                                    { name = "Player", value = xPlayer.name, inline = true },
                                                    { name = "ID", value = xPlayer.source, inline = true },
                                                    { name = "Amount", value = effectiveSalary, inline = true },
                                                })
                                            end

                                            TriggerClientEvent("esx:showAdvancedNotification", player, TranslateCap("bank"), TranslateCap("received_paycheck"), TranslateCap("received_salary", effectiveSalary), "CHAR_BANK_MAZE", 9)
                                        else
                                            TriggerClientEvent("esx:showAdvancedNotification", player, TranslateCap("bank"), "", TranslateCap("company_nomoney"), "CHAR_BANK_MAZE", 1)
                                        end
                                    end)
                                else -- not a society
                                    xPlayer.addAccountMoney("bank", effectiveSalary, "Paycheck")
                                    if Config.LogPaycheck then
                                        ESX.DiscordLogFields("Paycheck", "Paycheck - " .. jobLabel, "green", {
                                            { name = "Player", value = xPlayer.name, inline = true },
                                            { name = "ID", value = xPlayer.source, inline = true },
                                            { name = "Amount", value = effectiveSalary, inline = true },
                                        })
                                    end
                                    TriggerClientEvent("esx:showAdvancedNotification", player, TranslateCap("bank"), TranslateCap("received_paycheck"), TranslateCap("received_salary", effectiveSalary), "CHAR_BANK_MAZE", 9)
                                end
                            end)
                        else -- generic job
                            xPlayer.addAccountMoney("bank", effectiveSalary, "Paycheck")
                            if Config.LogPaycheck then
                                ESX.DiscordLogFields("Paycheck", "Paycheck - Generic", "green", {
                                    { name = "Player", value = xPlayer.name, inline = true },
                                    { name = "ID", value = xPlayer.source, inline = true },
                                    { name = "Amount", value = effectiveSalary, inline = true },
                                })
                            end
                            TriggerClientEvent("esx:showAdvancedNotification", player, TranslateCap("bank"), TranslateCap("received_paycheck"), TranslateCap("received_salary", effectiveSalary), "CHAR_BANK_MAZE", 9)
                        end
                    end
                end
            end
        end
    end)
end
