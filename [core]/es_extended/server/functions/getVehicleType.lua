function ESX.GetVehicleType(Vehicle, Player, cb)
    Core.CurrentRequestId = Core.CurrentRequestId < 65535 and Core.CurrentRequestId + 1 or 0
    Core.ClientCallbacks[Core.CurrentRequestId] = cb
    TriggerClientEvent("esx:GetVehicleType", Player, Vehicle, Core.CurrentRequestId)
end