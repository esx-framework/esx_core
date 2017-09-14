ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)

TriggerEvent('esx_phone:registerNumber', 'realestateagent', _U('client'), false, false)
TriggerEvent('esx_society:registerSociety', 'realestateagent', 'Agent immobilier', 'society_realestateagent', 'society_realestateagent', 'society_realestateagent', {type = 'private'})

RegisterServerEvent('esx_realestateagentjob:revoke')
AddEventHandler('esx_realestateagentjob:revoke', function(property, owner)
  TriggerEvent('esx_property:removeOwnedPropertyIdentifier', property, owner)
end)

RegisterServerEvent('esx_realestateagentjob:sell')
AddEventHandler('esx_realestateagentjob:sell', function(target, property, price)

  local xPlayer = ESX.GetPlayerFromId(target)

  xPlayer.removeMoney(price)

  TriggerEvent('esx_addonaccount:getSharedAccount', 'society_realestateagent', function(account)
    account.addMoney(price)
  end)

  TriggerEvent('esx_property:setPropertyOwned', property, price, false, xPlayer.identifier)
end)

RegisterServerEvent('esx_realestateagentjob:rent')
AddEventHandler('esx_realestateagentjob:rent', function(target, property, price)

  local xPlayer = ESX.GetPlayerFromId(target)

  TriggerEvent('esx_property:setPropertyOwned', property, price, true, xPlayer.identifier)
end)

ESX.RegisterServerCallback('esx_realestateagentjob:getCustomers', function(source, cb)

  TriggerEvent('esx_ownedproperty:getOwnedProperties', function(properties)

    local xPlayers  = ESX.GetPlayers()
    local customers = {}

    for i=1, #properties, 1 do
      for j=1, #xPlayers, 1 do

        local xPlayer = ESX.GetPlayerFromId(xPlayers[j])

        if xPlayer.identifier == properties[i].owner then
          table.insert(customers, {
            name           = xPlayer.name,
            propertyOwner  = properties[i].owner,
            propertyRented = properties[i].rented,
            propertyId     = properties[i].id,
            propertyPrice  = properties[i].price,
            propertyName   = properties[i].name
          })
        end
      end
    end

    cb(customers)

  end)

end)
