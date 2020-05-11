local self = ESX.Modules['interact']

AddEventHandler('esx:interact:register', self.Register)

-- Do not use this in prod ! internal event only
AddEventHandler('esx:interact:enter', function(name, data)
  TriggerEvent('esx:interact:enter:' .. name, data)
end)

AddEventHandler('esx:interact:exit', function(name, data)
  TriggerEvent('esx:interact:exit:' .. name, data)
end)
