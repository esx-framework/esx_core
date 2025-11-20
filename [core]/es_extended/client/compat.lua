--All client-side functions outsourced from the Core to the lib will be stored here for compatability, e.g:

ESX.Game.GetShapeTestResultSync = xLib.Raycast.GetShapeTestResult
ESX.Game.RaycastScreen = xLib.Raycast.FromScreen
ESX.Game.StartRaycasting = xLib.Raycast.Start
---@param raycast table The raycast object returned from ESX.Game.StartRaycasting
ESX.Game.StopRaycasting = function(raycast)
    if raycast and raycast.active then
        raycast:Stop()
    end
end
---@param raycast table The raycast object returned from ESX.Game.StartRaycasting
ESX.Game.IsRaycastActive = function(raycast)
    if raycast and raycast.active then
        return raycast:IsActive()
    end
    return false
end
---@param raycast table The raycast object returned from ESX.Game.StartRaycasting
ESX.Game.GetRaycastResult = function(raycast)
    if raycast and raycast.active then
        return raycast.result
    end
    return nil
end
ESX.Game.GetClosestEntity = xLib.entity.closest
EnumerateEntitiesWithinDistance = xLib.entity.EnumerateWithinDistance
ESX.Game.Teleport = xLib.entity.Teleport

ESX.Game.DeleteVehicle  = xLib.vehicle.Delete
ESX.Game.SpawnVehicle = xLib.vehicle.Spawn
ESX.Game.SpawnLocalVehicle = xLib.vehicle.SpawnLocalVehicle
ESX.Game.IsVehicleEmpty = xLib.vehicle.IsEmpty
ESX.Game.GetClosestVehicle = xLib.vehicle.Closest
ESX.Game.GetVehiclesInArea = xLib.vehicle.EnumerateWithinDistance
ESX.Game.IsSpawnPointClear = xLib.vehicle.IsSpawnPointClear
ESX.Game.GetVehicleInDirection = xLib.vehicle.GetInDirection
ESX.Game.GetVehicleProperties = xLib.vehicle.GetProperties
ESX.Game.SetVehicleProperties = xLib.vehicle.SetProperties