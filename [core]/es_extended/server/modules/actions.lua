RegisterServerEvent('esx:playerPedChanged')
RegisterServerEvent('esx:playerJumping')
RegisterServerEvent('esx:playerEnteringVehicle')
RegisterServerEvent('esx:playerEnteringVehicleAborted')
RegisterServerEvent('esx:playerEnteredVehicle')
RegisterServerEvent('esx:playerExitedVehicle')

if Config.EnableDebug then

    AddEventHandler('esx:playerPedChanged', function(netId)
        print('esx:playerPedChanged', source, netId)
    end)

    AddEventHandler('esx:playerJumping', function()
        print('esx:playerJumping', source)
    end)

    AddEventHandler('esx:playerEnteringVehicle', function(vehicle, plate, seat, netId)
        print('esx:playerEnteringVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'netId', netId)
    end)

    AddEventHandler('esx:playerEnteringVehicleAborted', function()
        print('esx:playerEnteringVehicleAborted', source)
    end)

    AddEventHandler('esx:playerEnteredVehicle', function(vehicle, plate, seat, displayName, netId)
        print('esx:playerEnteredVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

    AddEventHandler('esx:playerExitedVehicle', function(vehicle, plate, seat, displayName, netId)
        print('esx:playerExitedVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

end