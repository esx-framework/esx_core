local openData

RegisterNetEvent('runcode:openUi')

AddEventHandler('runcode:openUi', function(options)
    openData = {
        type = 'open',
        options = options,
        url = 'http://' .. GetCurrentServerEndpoint() .. '/' .. GetCurrentResourceName() .. '/',
        res = GetCurrentResourceName()
    }

    SendNuiMessage(json.encode(openData))
end)

RegisterNUICallback('getOpenData', function(args, cb)
    cb(openData)
end)

RegisterNUICallback('doOk', function(args, cb)
    SendNuiMessage(json.encode({
        type = 'ok'
    }))

    SetNuiFocus(true, true)

    cb('ok')
end)

RegisterNUICallback('doClose', function(args, cb)
    SendNuiMessage(json.encode({
        type = 'close'
    }))

    SetNuiFocus(false, false)

    cb('ok')
end)

local rcCbs = {}
local id = 1

RegisterNUICallback('runCodeInBand', function(args, cb)
    id = id + 1

    rcCbs[id] = cb

    TriggerServerEvent('runcode:runInBand', id, args)
end)

RegisterNetEvent('runcode:inBandResult')

AddEventHandler('runcode:inBandResult', function(id, result)
    if rcCbs[id] then
        local cb = rcCbs[id]
        rcCbs[id] = nil

        cb(result)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)