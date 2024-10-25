Actions = {}
Actions._index = Actions

Actions.inVehicle = false
Actions.enteringVehicle = false
Actions.inPauseMenu = false

function Actions:GetSeatPedIsIn()
    for i = -1, 16 do
        if GetPedInVehicleSeat(self.vehicle, i) == ESX.PlayerData.ped then
            return i
        end
    end
    return -1
end

function Actions:GetVehicleData()
    if not DoesEntityExist(self.vehicle) then
        return
    end

    local vehicleModel = GetEntityModel(self.vehicle)
    local displayName = GetDisplayNameFromVehicleModel(vehicleModel)
    local netId = NetworkGetEntityIsNetworked(self.vehicle) and VehToNet(self.vehicle) or self.vehicle
    local plate = GetVehicleNumberPlateText(self.vehicle)

    return displayName, netId, plate
end

function Actions:SetVehicleStatus()
    ESX.SetPlayerData("vehicle", self.vehicle)
    ESX.SetPlayerData("seat", self.seat)
end

function Actions:TrackPedCoords()
    local playerPed = ESX.PlayerData.ped
    local coords = GetEntityCoords(playerPed)

    ESX.SetPlayerData("coords", coords)
end

function Actions:TrackPed()
    local playerPed = ESX.PlayerData.ped
    local newPed = PlayerPedId()

    if playerPed ~= newPed then
        ESX.PlayerData.ped = newPed
        ESX.SetPlayerData("ped", playerPed)

        TriggerEvent("esx:playerPedChanged", playerPed)
        TriggerServerEvent("esx:playerPedChanged", PedToNet(playerPed))
    end
end

function Actions:TrackPauseMenu()
    local isActive = IsPauseMenuActive()

    if isActive ~= self.inPauseMenu then
        self.inPauseMenu = isActive
        TriggerEvent("esx:pauseMenuActive", isActive)
    end
end

function Actions:EnterVehicle()
    self.seat = GetSeatPedIsTryingToEnter(ESX.PlayerData.ped)

    local _, netId, plate = self:GetVehicleData()

    self.isEnteringVehicle = true
    TriggerEvent("esx:enteringVehicle", self.vehicle, plate, self.seat, netId)
    TriggerServerEvent("esx:enteringVehicle", plate, self.seat, netId)

    self:SetVehicleStatus()
end

function Actions:ResetVehicleData()
    self.enteringVehicle = false
    self.vehicle = false
    self.seat = false
    self.inVehicle = false

    self:SetVehicleStatus()
end

function Actions:EnterAborted()
    self:ResetVehicleData()

    TriggerEvent("esx:enteringVehicleAborted")
    TriggerServerEvent("esx:enteringVehicleAborted")
end

function Actions:WarpEnter()
    self.enteringVehicle = false
    self.inVehicle = true

    self.seat = self:GetSeatPedIsIn()

    local displayName, netId, plate = self:GetVehicleData()

    self:SetVehicleStatus()
    TriggerEvent("esx:enteredVehicle", self.vehicle, plate, self.seat, displayName, netId)
    TriggerServerEvent("esx:enteredVehicle", plate, self.seat, displayName, netId)
end

function Actions:ExitVehicle()
    local currentVehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)

    if currentVehicle ~= self.vehicle or ESX.PlayerData.dead then
        local displayName, netId, plate = self:GetVehicleData()

        TriggerEvent("esx:exitedVehicle", self.vehicle, plate, self.seat, displayName, netId)
        TriggerServerEvent("esx:exitedVehicle", plate, self.seat, displayName, netId)

        self:ResetVehicleData()
    end
end

function Actions:TrackVehicle()
    if not self.inVehicle and not ESX.PlayerData.dead then
        local tempVehicle = GetVehiclePedIsTryingToEnter(ESX.PlayerData.ped)

        if DoesEntityExist(tempVehicle) and not self.enteringVehicle then
            self.vehicle = tempVehicle
            self:EnterVehicle()
        elseif not DoesEntityExist(tempVehicle) and not IsPedInAnyVehicle(ESX.PlayerData.ped, true) and self.enteringVehicle then
            self:EnterAborted()
        elseif IsPedInAnyVehicle(ESX.PlayerData.ped, false) then
            self.vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
            self:WarpEnter()
        end
    elseif self.inVehicle then
        self:ExitVehicle()
    end
end

function Actions:SlowLoop()
    CreateThread(function()
        while ESX.PlayerLoaded do
            self:TrackPed()
            self:TrackPedCoords()
            self:TrackPauseMenu()
            self:TrackVehicle()
            Wait(500)
        end
    end)
end

function Actions:Init()
    self:SlowLoop()
end

Actions:Init()
