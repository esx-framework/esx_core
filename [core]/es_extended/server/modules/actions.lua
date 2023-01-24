RegisterServerEvent('esx:playerPedChanged')
RegisterServerEvent('esx:playerJumping')
RegisterServerEvent('esx:EnteringVehicle')
RegisterServerEvent('esx:EnteringVehicleAborted')
RegisterServerEvent('esx:EnteredVehicle')
RegisterServerEvent('esx:ExitedVehicle')

if Config.EnableDebug then

    AddEventHandler('esx:playerPedChanged', function(netId)
        print('esx:playerPedChanged', source, netId)
    end)

    AddEventHandler('esx:playerJumping', function()
        print('esx:playerJumping', source)
    end)

    AddEventHandler('esx:EnteringVehicle', function(vehicle, plate, seat, netId)
        print('esx:EnteringVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'netId', netId)
    end)

    AddEventHandler('esx:EnteringVehicleAborted', function()
        print('esx:EnteringVehicleAborted', source)
    end)

    AddEventHandler('esx:EnteredVehicle', function(vehicle, plate, seat, displayName, netId)
        print('esx:EnteredVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

    AddEventHandler('esx:ExitedVehicle', function(vehicle, plate, seat, displayName, netId)
        print('esx:ExitedVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

end