OnESX = function(cb)

  local ESX = nil

  Citizen.CreateThread(function()

    while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(0)
    end

    cb(ESX)

  end)

end

exports('OnESX', OnESX)
