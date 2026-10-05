-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

local function getCoordinateHeading(coordinates)
    local coordinateType = type(coordinates)

    if coordinateType == "vector4" then
        return coordinates.w
    elseif coordinateType == "table" then
        return coordinates.w or coordinates.heading or 0.0
    end

    return 0.0
end

function Core.PlayerClass.AttachBase(self)
    function self.triggerEvent(eventName, ...)
        assert(type(eventName) == "string", "eventName should be string!")
        TriggerClientEvent(eventName, self.source, ...)
    end

    function self.togglePaycheck(toggle)
        self.paycheckEnabled = toggle
    end

    function self.isPaycheckEnabled()
        return self.paycheckEnabled
    end

    function self.isAdmin()
        return Core.IsPlayerAdmin(self.source)
    end

    function self.setCoords(coordinates)
        local ped <const> = ESX.Players[self.source] == self and GetPlayerPed(self.source) or 0

        if ped == 0 or not DoesEntityExist(ped) then
            return false
        end

        local entityHeading = getCoordinateHeading(coordinates)

        SetEntityCoords(
            ped,
            coordinates.x,
            coordinates.y,
            coordinates.z,
            false,
            false,
            false,
            false
        )
        SetEntityHeading(ped, entityHeading)

        self.coords = {
            x = coordinates.x,
            y = coordinates.y,
            z = coordinates.z,
            heading = entityHeading,
        }
    end

    function self.getCoords(vector, heading)
        local ped = ESX.Players[self.source] == self and GetPlayerPed(self.source) or 0

        if ped ~= 0 and DoesEntityExist(ped) then
            local entityCoords = GetEntityCoords(ped)

            self.coords = {
                x = entityCoords.x,
                y = entityCoords.y,
                z = entityCoords.z,
                heading = GetEntityHeading(ped),
            }
        end

        local entityCoords = self.coords
        local entityHeading = getCoordinateHeading(entityCoords)

        if vector then
            if heading then
                return vector4(entityCoords.x, entityCoords.y, entityCoords.z, entityHeading)
            end

            return vector3(entityCoords.x, entityCoords.y, entityCoords.z)
        end

        local coordinates = {
            x = entityCoords.x,
            y = entityCoords.y,
            z = entityCoords.z,
        }

        if heading then
            coordinates.heading = entityHeading
        end

        return coordinates
    end

    function self.kick(reason)
        DropPlayer(self.source --[[@as string]], reason)
    end

    function self.getPlayTime()
        -- luacheck: ignore
        local lastPlaytime = tonumber(self.lastPlaytime) or 0
        local onlineTime

        if ESX.Players[self.source] == self then
            onlineTime = tonumber(GetPlayerTimeOnline(self.source --[[@as string]]))
        end

        if onlineTime then
            return lastPlaytime + onlineTime
        end

        local savedPlaytime = self.metadata and tonumber(self.metadata.lastPlaytime)

        return savedPlaytime or lastPlaytime
    end


    function self.getIdentifier()
        return self.identifier
    end

    function self.getSSN()
        return self.ssn
    end

    function self.setGroup(newGroup)
        local lastGroup = self.group

        ExecuteCommand(("remove_principal identifier.%s group.%s"):format(self.license, self.group))

        self.group = newGroup

        TriggerEvent("esx:setGroup", self.source, self.group, lastGroup)
        self.triggerEvent("esx:setGroup", self.group, lastGroup)
        Player(self.source).state:set("group", self.group, true)

        ExecuteCommand(("add_principal identifier.%s group.%s"):format(self.license, self.group))
    end

    function self.getGroup()
        return self.group
    end

    function self.set(k, v)
        self.variables[k] = v

        self.triggerEvent('esx:updatePlayerData', 'variables', self.variables)
    end

    function self.get(k)
        return self.variables[k]
    end


    function self.getName()
        return self.name
    end

    function self.setName(newName)
        self.name = newName
        Player(self.source).state:set("name", self.name, true)
    end


    function self.getSource()
        return self.source
    end
    self.getPlayerId = self.getSource

    function self.executeCommand(command)
        if type(command) ~= "string" then
            error("xPlayer.executeCommand must be of type string!")
            return
        end

        self.triggerEvent("esx:executeCommand", command)
    end

end
