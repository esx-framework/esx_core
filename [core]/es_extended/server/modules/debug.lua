if Config.EnableDebug then
    RegisterNetEvent("esx:enteringVehicle", function(plate, seat, netId)
        print("esx:enteringVehicle", "source", source, "plate", plate, "seat", seat, "netId", netId)
    end)

    RegisterNetEvent("esx:enteringVehicleAborted", function()
        print("esx:enteringVehicleAborted", source)
    end)

    RegisterNetEvent("esx:enteredVehicle", function(plate, seat, displayName, netId)
        print("esx:enteredVehicle", "source", source, "plate", plate, "seat", seat, "displayName", displayName, "netId", netId)
    end)

    RegisterNetEvent("esx:exitedVehicle", function(plate, seat, displayName, netId)
        print("esx:exitedVehicle", "source", source, "plate", plate, "seat", seat, "displayName", displayName, "netId", netId)
    end)

    RegisterNetEvent("esx:clientLog", function(msg)
        print(("[^2TRACE^7] %s^7"):format(msg))
    end)
end

---@param msg string
---@return nil
function ESX.Trace(msg)
    if Config.EnableDebug then
        print(("[^2TRACE^7] %s^7"):format(msg))
    end
end

