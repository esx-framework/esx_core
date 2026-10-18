-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

local function getCoordinateHeading(coordinates)
    local coordinateType = type(coordinates)

    if coordinateType == "vector4" then
        return coordinates.w
    elseif coordinateType == "table" then
        if coordinates.w ~= nil then
            return coordinates.w
        end

        if coordinates.heading ~= nil then
            return coordinates.heading
        end
    end

    return 0.0
end

local function isFiniteNumber(value)
    return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function areCoordinateComponentsValid(x, y, z, heading)
    local limit = Config.PlayerCoordinateLimit

    if not isFiniteNumber(limit) or limit <= 0 then
        limit = 10000.0
    end

    return isFiniteNumber(x) and isFiniteNumber(y) and isFiniteNumber(z) and isFiniteNumber(heading)
        and math.abs(x) <= limit and math.abs(y) <= limit and math.abs(z) <= limit
end

function Core.PlayerClass.IsValidCoordinates(coordinates)
    local coordinateType = type(coordinates)

    if coordinateType ~= "table" and coordinateType ~= "vector3" and coordinateType ~= "vector4" then
        return false
    end

    return areCoordinateComponentsValid(coordinates.x, coordinates.y, coordinates.z, getCoordinateHeading(coordinates))
end

function Core.PlayerClass.GetDefaultCoordinates()
    local spawns = {}

    for _, coordinates in ipairs(Config.DefaultSpawns or {}) do
        if Core.PlayerClass.IsValidCoordinates(coordinates) then
            spawns[#spawns + 1] = coordinates
        end
    end

    if #spawns == 0 then
        return nil
    end

    local coordinates = spawns[ESX.Math.Random(1, #spawns)]

    return {
        x = coordinates.x,
        y = coordinates.y,
        z = coordinates.z,
        heading = getCoordinateHeading(coordinates),
    }
end

local function updateCachedCoordinates(player, x, y, z, heading)
    if not areCoordinateComponentsValid(x, y, z, heading) then
        return false
    end

    if type(player.coords) ~= "table" then
        player.coords = {}
    end

    local coordinates = player.coords

    coordinates.x = x
    coordinates.y = y
    coordinates.z = z
    coordinates.heading = heading
    coordinates.w = nil
end

function Core.PlayerClass.AttachBase(self)
    local lastValidCoordinates

    local function rememberCoordinates(coordinates)
        lastValidCoordinates = lastValidCoordinates or {}
        lastValidCoordinates.x = coordinates.x
        lastValidCoordinates.y = coordinates.y
        lastValidCoordinates.z = coordinates.z
        lastValidCoordinates.heading = getCoordinateHeading(coordinates)
    end

    if Core.PlayerClass.IsValidCoordinates(self.coords) then
        rememberCoordinates(self.coords)
    end

    function self.isCurrent()
        return ESX.Players[self.source] == self
    end

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
        if not Core.PlayerClass.IsValidCoordinates(coordinates) then
            return false
        end

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

        updateCachedCoordinates(
            self,
            coordinates.x,
            coordinates.y,
            coordinates.z,
            entityHeading
        )
        rememberCoordinates(self.coords)
    end

    function self.getCoords(vector, heading)
        local ped = ESX.Players[self.source] == self and GetPlayerPed(self.source) or 0

        if ped ~= 0 and DoesEntityExist(ped) then
            local entityCoords = GetEntityCoords(ped)

            if Core.PlayerClass.IsValidCoordinates(entityCoords) then
                updateCachedCoordinates(
                    self,
                    entityCoords.x,
                    entityCoords.y,
                    entityCoords.z,
                    GetEntityHeading(ped)
                )
            end
        end

        if not Core.PlayerClass.IsValidCoordinates(self.coords) then
            local coordinates = lastValidCoordinates

            if not Core.PlayerClass.IsValidCoordinates(coordinates) then
                coordinates = Core.PlayerClass.GetDefaultCoordinates()
            end

            assert(coordinates, ("No valid player position or Config.DefaultSpawns for player %s"):format(self.source))
            updateCachedCoordinates(self, coordinates.x, coordinates.y, coordinates.z, getCoordinateHeading(coordinates))
        end

        local entityCoords = self.coords
        local entityHeading = getCoordinateHeading(entityCoords)

        rememberCoordinates(entityCoords)

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

    function self.set(k, v, replicate)
        self.variables[k] = v

        if replicate ~= false then
            self.triggerEvent('esx:updatePlayerData', 'variables', self.variables)
        end
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
