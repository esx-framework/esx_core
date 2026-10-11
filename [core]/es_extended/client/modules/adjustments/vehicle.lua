-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

function Adjustments:SeatShuffle()
    if Config.DisableVehicleSeatShuff and not self.seatShuffleRegistered then
        self.seatShuffleRegistered = true

        AddEventHandler("esx:enteredVehicle", function(vehicle, _, seat)
            if seat > -1 then
                SetPedIntoVehicle(ESX.PlayerData.ped, vehicle, seat)
                SetPedConfigFlag(ESX.PlayerData.ped, 184, true)
            end
        end)
    end
end

function Adjustments:DisableRadio()
    if Config.RemoveHudComponents[16] and not self.disableRadioRegistered then
        self.disableRadioRegistered = true

        AddEventHandler("esx:enteredVehicle", function(vehicle)
            SetVehRadioStation(vehicle, "OFF")
            SetUserRadioControlEnabled(false)
        end)
    end
end
