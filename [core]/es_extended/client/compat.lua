--All client-side functions outsourced from the Core to the lib will be stored here for compatability, e.g:

ESX.Game.GetClosestEntity = xLib.entity.closest
EnumerateEntitiesWithinDistance = xLib.entity.EnumerateWithinDistance
ESX.Game.Teleport = xLib.entity.Teleport

ESX.Streaming = {
    RequestModel = xLib.streaming.requestModel,
    RequestStreamedTextureDict = xLib.streaming.requestStreamedTextureDict,
    RequestNamedPtfxAsset = xLib.streaming.requestNamedPtfxAsset,
    RequestAnimSet = xLib.streaming.requestAnimSet,
    RequestAnimDict = xLib.streaming.requestAnimDict,
    RequestWeaponAsset = xLib.streaming.requestWeaponAsset,
}

ESX.Scaleform = {
    ShowFreemodeMessage = xLib.scaleform.showFreemodeMessage,
    ShowBreakingNews = xLib.scaleform.showBreakingNews,
    ShowPopupWarning = xLib.scaleform.showPopupWarning,
    ShowTrafficMovie = xLib.scaleform.showTrafficMovie,
    Utils = {
        RequestScaleformMovie = xLib.scaleform.utils.requestScaleformMovie,
        RunMethod = xLib.scaleform.utils.runMethod,
    },
}

ESX.CreatePointInternal = xLib.points.create
ESX.RemovePointInternal = xLib.points.remove
ESX.HidePointInternal = xLib.points.hide
StartPointsLoop = xLib.points.startLoop
ESX.Point = xLib.point

ESX.RegisterInteraction = xLib.interactions.register
ESX.RemoveInteraction = xLib.interactions.remove
ESX.GetInteractKey = xLib.interactions.getInteractKey

ESX.Game.GetPedMugshot = xLib.game.getPedMugshot
ESX.Game.SpawnObject = xLib.game.spawnObject
ESX.Game.SpawnLocalObject = xLib.game.spawnLocalObject
ESX.Game.DeleteVehicle = xLib.game.deleteVehicle
ESX.Game.DeleteObject = xLib.game.deleteObject
ESX.Game.SpawnVehicle = xLib.game.spawnVehicle
ESX.Game.SpawnLocalVehicle = xLib.game.spawnLocalVehicle
ESX.Game.IsVehicleEmpty = xLib.game.isVehicleEmpty
ESX.Game.GetObjects = xLib.game.getObjects
ESX.Game.GetPeds = xLib.game.getPeds
ESX.Game.GetVehicles = xLib.game.getVehicles
ESX.Game.GetPlayers = xLib.game.getPlayers
ESX.Game.GetClosestObject = xLib.game.getClosestObject
ESX.Game.GetClosestPed = xLib.game.getClosestPed
ESX.Game.GetClosestPlayer = xLib.game.getClosestPlayer
ESX.Game.GetClosestVehicle = xLib.game.getClosestVehicle
ESX.Game.GetPlayersInArea = xLib.game.getPlayersInArea
ESX.Game.GetVehiclesInArea = xLib.game.getVehiclesInArea
ESX.Game.IsSpawnPointClear = xLib.game.isSpawnPointClear
ESX.Game.GetVehicleInDirection = xLib.game.getVehicleInDirection
ESX.Game.GetVehicleProperties = xLib.game.getVehicleProperties
ESX.Game.SetVehicleProperties = xLib.game.setVehicleProperties

function ESX.RegisterInput(command_name, label, input_group, key, on_press, on_release)
    return xLib.addKeybind({
        name = command_name,
        description = label,
        defaultMapper = input_group,
        defaultKey = key,
        onPressed = on_press,
        onReleased = on_release
    })
end

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
