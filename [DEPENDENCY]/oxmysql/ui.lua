RegisterNetEvent('oxmysql:openUi', function(data)
    SendNUIMessage({
        action = 'openUI',
        data = data
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('exit', function(_, cb)
    cb(true)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('fetchResource', function(data, cb)
    TriggerServerEvent('oxmysql:fetchResource', data)
    cb(true)
end)

RegisterNetEvent('oxmysql:loadResource', function(data)
    SendNUIMessage({
        action = 'loadResource',
        data = data
    })
end)