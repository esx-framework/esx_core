ESX.StartPayCheck = function ()

  function payCheck ()
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
      local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
      if xPlayer.job.grade_name == 'interim' or xPlayer.job.grade_name == 'rsa' or xPlayer.job.grade_name == 'employee' then -- Si il n'est pas dans une société, je prends chez l'état
        if xPlayer.job.grade_salary > 0 then
          xPlayer.addAccountMoney('bank',xPlayer.job.grade_salary)
        TriggerClientEvent('esx:showNotification', xPlayer.source, ('L\'état vous a payé ') .. '~g~$' .. xPlayer.job.grade_salary)
        end
      else -- Sinon je prends l'argent dans la société
        TriggerEvent('esx_society:getSociety', xPlayer.job.name, function (society)
          TriggerEvent('esx_addonaccount:getSharedAccount', society.account, function (account)
        if account.money >= xPlayer.job.grade_salary then
          xPlayer.addAccountMoney('bank',xPlayer.job.grade_salary)
          account.removeMoney(xPlayer.job.grade_salary)
         TriggerClientEvent('esx:showNotification', xPlayer.source, ('Votre entreprise vous a payé ') .. '~g~$' .. xPlayer.job.grade_salary)
        else
          TriggerClientEvent('esx:showNotification', xPlayer.source, 'Votre entreprise n\'a plus d\'argent pour vous payer !')
        end
      end)
      end)
    end
    end

    SetTimeout(Config.PaycheckInterval, payCheck)
  end
  SetTimeout(Config.PaycheckInterval, payCheck)
end
