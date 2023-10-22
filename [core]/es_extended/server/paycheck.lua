function StartPayCheck()
  CreateThread(function()
    while true do
      Wait(Config.PaycheckInterval)
      for player, xPlayer in pairs(ESX.Players) do
        local jobLabel = xPlayer.job.label
        local job = xPlayer.job.grade_name
        local salary = xPlayer.job.grade_salary

        if salary > 0 and xPlayer.job.type ~= 'fraktion' then
          if job == 'arbeitslos' then -- unemployed
            xPlayer.addAccountMoney('bank', salary, "Welfare Check")
            TriggerEvent('okokBanking:AddTransferTransactionFromSocietyToP', salary, "salary", "Salary", xPlayer.identifier, xPlayer.getName())
            TriggerClientEvent('okokNotify:Alert', xPlayer.source, "Bürgergeld", "Du hast dein Bürgergeld in höhe von "..salary.."$ bekommen. Du kannst jetzt wieder Zigaretten und Alkohol kaufen!", 8000, 'harz4')
            if Config.LogPaycheck then
              ESX.DiscordLogFields("Paycheck", "Paycheck - Unemployment Benefits", "green", {
                { name = "Player", value = xPlayer.name,   inline = true },
                { name = "ID",     value = xPlayer.source, inline = true },
                { name = "Amount", value = salary,         inline = true }
              })
            end
          elseif Config.EnableSocietyPayouts then -- possibly a society
            TriggerEvent('esx_society:getSociety', xPlayer.job.name, function(society)
              if society ~= nil then              -- verified society
                TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function(account)
                  if account.money >= salary then -- does the society money to pay its employees?
                    xPlayer.addAccountMoney('bank', salary, "Paycheck")
                    account.removeMoney(salary)
                    if Config.LogPaycheck then
                      ESX.DiscordLogFields("Paycheck", "Paycheck - " .. jobLabel, "green", {
                        { name = "Player", value = xPlayer.name,   inline = true },
                        { name = "ID",     value = xPlayer.source, inline = true },
                        { name = "Amount", value = salary,         inline = true }
                      })
                    end

                    TriggerEvent('okokBanking:AddTransferTransactionFromSocietyToP', salary, "salary", "Salary", xPlayer.identifier, xPlayer.getName())
                    TriggerClientEvent('okokNotify:Alert', xPlayer.source, "Gehalt", "Du hast dein Gehalt in höhe von "..salary.."$ erhalten.", 8000, 'payment')
                  else
                    TriggerClientEvent('okokNotify:Alert', xPlayer.source, "Gehalt", "Deine Firma hat nicht genug Geld um dich zu bezahlen.", 8000, 'paymentdenied')
                  end
                end)
              else -- not a society
                xPlayer.addAccountMoney('bank', salary, "Paycheck")
                if Config.LogPaycheck then
                  ESX.DiscordLogFields("Paycheck", "Paycheck - " .. jobLabel, "green", {
                    { name = "Player", value = xPlayer.name,   inline = true },
                    { name = "ID",     value = xPlayer.source, inline = true },
                    { name = "Amount", value = salary,         inline = true }
                  })
                end
                TriggerEvent('okokBanking:AddTransferTransactionFromSocietyToP', salary, "salary", "Salary", xPlayer.identifier, xPlayer.getName())
                TriggerClientEvent('okokNotify:Alert', xPlayer.source, "Gehalt", "Du hast dein Gehalt in höhe von "..salary.."$ erhalten.", 8000, 'payment')
              end
            end)
          else -- generic job
            xPlayer.addAccountMoney('bank', salary, "Paycheck")
            if Config.LogPaycheck then
              ESX.DiscordLogFields("Paycheck", "Paycheck - Generic", "green", {
                { name = "Player", value = xPlayer.name,   inline = true },
                { name = "ID",     value = xPlayer.source, inline = true },
                { name = "Amount", value = salary,         inline = true }
              })
            end
            TriggerEvent('okokBanking:AddTransferTransactionFromSocietyToP', salary, "salary", "Salary", xPlayer.identifier, xPlayer.getName())
                TriggerClientEvent('okokNotify:Alert', xPlayer.source, "Gehalt", "Du hast dein Gehalt in höhe von "..salary.."$ erhalten.", 8000, 'payment')
          end
        end
      end
    end
  end)
end
