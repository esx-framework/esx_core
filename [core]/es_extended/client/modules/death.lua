Death = {}
Death._index = Death

function Death:ResetValues()
    self.killerEntity = nil
    self.deathCause = nil
    self.killerId = nil
    self.killerServerId = nil
end

function Death:ByPlayer()
    local victimCoords = GetEntityCoords(ESX.PlayerData.ped)
    local killerCoords = GetEntityCoords(self.killerEntity)
    local distance = #(victimCoords - killerCoords)

    local data = {
        victimCoords = { x = ESX.Math.Round(victimCoords.x, 1), y = ESX.Math.Round(victimCoords.y, 1), z = ESX.Math.Round(victimCoords.z, 1) },
        killerCoords = { x = ESX.Math.Round(killerCoords.x, 1), y = ESX.Math.Round(killerCoords.y, 1), z = ESX.Math.Round(killerCoords.z, 1) },

        killedByPlayer = true,
        deathCause = self.deathCause,
        distance = ESX.Math.Round(distance, 1),

        killerServerId = self.killerServerId,
        killerClientId = self.killerId,
    }

    TriggerEvent("esx:onPlayerDeath", data)
    TriggerServerEvent("esx:onPlayerDeath", data)
end

function Death:Natural()
    local coords = GetEntityCoords(ESX.PlayerData.ped)

    local data = {
        victimCoords = { x = ESX.Math.Round(coords.x, 1), y = ESX.Math.Round(coords.y, 1), z = ESX.Math.Round(coords.z, 1) },

        killedByPlayer = false,
        deathCause = self.deathCause,
    }

    TriggerEvent("esx:onPlayerDeath", data)
    TriggerServerEvent("esx:onPlayerDeath", data)
end

function Death:Died()
    self.killerEntity = GetPedSourceOfDeath(ESX.PlayerData.ped)
    self.deathCause = GetPedCauseOfDeath(ESX.PlayerData.ped)
    self.killerId = NetworkGetPlayerIndexFromPed(self.killerEntity)
    self.killerServerId = GetPlayerServerId(self.killerId)

    local isActive = NetworkIsPlayerActive(self.killerId)

    if self.killerEntity ~= ESX.PlayerData.ped and self.killerId and isActive then
        self:ByPlayer()
    else
        self:Natural()
    end

    self:ResetValues()
end

AddEventHandler("esx:onPlayerSpawn", function()
    Citizen.CreateThreadNow(function()
        while not ESX.PlayerLoaded do Wait(0) end

        while ESX.PlayerLoaded and not ESX.PlayerData.dead do
            if DoesEntityExist(ESX.PlayerData.ped) and (IsPedDeadOrDying(ESX.PlayerData.ped, true) or IsPedFatallyInjured(ESX.PlayerData.ped)) then
                Death:Died()
                break
            end
            Citizen.Wait(250)
        end
    end)
end)
