RegisterServerEvent('esx:playerPedChanged')
RegisterServerEvent('esx:playerJumping')
RegisterServerEvent('esx:enteringVehicle')
RegisterServerEvent('esx:enteringVehicleAborted')
RegisterServerEvent('esx:enteredVehicle')
RegisterServerEvent('esx:exitedVehicle')

if Config.EnableDebug then

    AddEventHandler('esx:playerPedChanged', function(netId)
        print('esx:playerPedChanged', source, netId)
    end)

    AddEventHandler('esx:playerJumping', function()
        print('esx:playerJumping', source)
    end)

    AddEventHandler('esx:enteringVehicle', function(vehicle, plate, seat, netId)
        print('esx:enteringVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'netId', netId)
    end)

    AddEventHandler('esx:enteringVehicleAborted', function()
        print('esx:enteringVehicleAborted', source)
    end)

    AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
        print('esx:enteredVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

    AddEventHandler('esx:exitedVehicle', function(vehicle, plate, seat, displayName, netId)
        print('esx:exitedVehicle', 'source', source, 'vehicle', vehicle, 'plate', plate, 'seat', seat, 'displayName', displayName, 'netId', netId)
    end)

end