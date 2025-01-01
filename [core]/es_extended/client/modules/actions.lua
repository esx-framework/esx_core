Actions = {}
Actions._index = Actions

Actions.inVehicle = false
Actions.enteringVehicle = false
Actions.inPauseMenu = false
Actions.currentWeapon = false

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
        ESX.SetPlayerData("ped", newPed)

        TriggerEvent("esx:playerPedChanged", newPed)

        if Config.EnableDebug then
            print("[DEBUG] Player ped changed:", newPed)
        end
    end
end

function Actions:TrackPauseMenu()
    local isActive = IsPauseMenuActive()

    if isActive ~= self.inPauseMenu then
        self.inPauseMenu = isActive
        TriggerEvent("esx:pauseMenuActive", isActive)

        if Config.EnableDebug then
            print("[DEBUG] Pause menu active:", isActive)
        end
    end
end

function Actions:EnterVehicle()
    self.seat = GetSeatPedIsTryingToEnter(ESX.PlayerData.ped)

    local _, netId, plate = self:GetVehicleData()

    self.enteringVehicle = true
    TriggerEvent("esx:enteringVehicle", self.vehicle, plate, self.seat, netId)
    TriggerServerEvent("esx:enteringVehicle", plate, self.seat, netId)

    self:SetVehicleStatus()

    if Config.EnableDebug then
        print("[DEBUG] Entering vehicle:", self.vehicle, plate, self.seat, netId)
    end
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

    if Config.EnableDebug then
        print("[DEBUG] Entering vehicle aborted")
    end
end

function Actions:WarpEnter()
    self.enteringVehicle = false
    self.inVehicle = true

    self.seat = self:GetSeatPedIsIn()

    local displayName, netId, plate = self:GetVehicleData()

    self:SetVehicleStatus()
    TriggerEvent("esx:enteredVehicle", self.vehicle, plate, self.seat, displayName, netId)
    TriggerServerEvent("esx:enteredVehicle", plate, self.seat, displayName, netId)

    if Config.EnableDebug then
        print("[DEBUG] Entered vehicle:", self.vehicle, plate, self.seat, displayName, netId)
    end
end

function Actions:ExitVehicle()
    local currentVehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)

    if currentVehicle ~= self.vehicle or ESX.PlayerData.dead then
        local displayName, netId, plate = self:GetVehicleData()

        TriggerEvent("esx:exitedVehicle", self.vehicle, plate, self.seat, displayName, netId)
        TriggerServerEvent("esx:exitedVehicle", plate, self.seat, displayName, netId)

        if Config.EnableDebug then
            print("[DEBUG] Exited vehicle:", self.vehicle, plate, self.seat, displayName, netId)
        end

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
        self:TrackSeat()
    end
end

function Actions:TrackSeat()
    if not self.inVehicle then
        return
    end

    local newSeat = self:GetSeatPedIsIn()
    if newSeat ~= self.seat then
        self.seat = newSeat
        ESX.SetPlayerData("seat", self.seat)
        TriggerEvent("esx:vehicleSeatChanged", self.seat)

        if Config.EnableDebug then
            print("[DEBUG] Vehicle seat changed:", self.seat)
        end
    end
end

function Actions:TrackWeapon()
    ---@type number|false
    local newWeapon = GetSelectedPedWeapon(ESX.PlayerData.ped)
    newWeapon = newWeapon ~= `WEAPON_UNARMED` and newWeapon or false

    if newWeapon ~= self.currentWeapon then
        self.currentWeapon = newWeapon
        ESX.SetPlayerData("weapon", self.currentWeapon)
        TriggerEvent("esx:weaponChanged", self.currentWeapon)

        if Config.EnableDebug then
            print("[DEBUG] Weapon changed:", self.currentWeapon)
        end
    end
end

function Actions:SlowLoop()
    CreateThread(function()
        while ESX.PlayerLoaded do
            self:TrackPedCoords()
            self:TrackPauseMenu()
            self:TrackVehicle()
            self:TrackWeapon()
            Wait(500)
        end
    end)
end

function Actions:PedLoop()
    CreateThread(function()
        while ESX.PlayerLoaded do
            self:TrackPed()
            Wait(0)
        end
    end)
end

function Actions:Init()
    self:SlowLoop()
    self:PedLoop()
end

Actions:Init()
