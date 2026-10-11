-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

function Core.PlayerClass.AttachMetadata(self)
    function self.getMeta(index, subIndex)
        if not index then
            return self.metadata
        end

        if type(index) ~= "string" then
            error("xPlayer.getMeta ^5index^1 should be ^5string^1!")
            return
        end

        local metaData = self.metadata[index]
        if metaData == nil then
            return Config.EnableDebug and error(("xPlayer.getMeta ^5%s^1 not exist!"):format(index)) or nil
        end

        if subIndex and type(metaData) == "table" then
            local _type = type(subIndex)

            if _type == "string" then
                local value = metaData[subIndex]
                return value
            end

            if _type == "table" then
                local returnValues = {}

                for i = 1, #subIndex do
                    local key = subIndex[i]
                    if type(key) == "string" then
                        returnValues[key] = self.getMeta(index, key)
                    else
                        error(("xPlayer.getMeta subIndex should be ^5string^1 or ^5table^1! that contains ^5string^1, received ^5%s^1!, skipping..."):format(type(key)))
                    end
                end

                return returnValues
            end

            error(("xPlayer.getMeta subIndex should be ^5string^1 or ^5table^1!, received ^5%s^1!"):format(_type))
            return
        end

        return metaData
    end

    function self.setMeta(index, value, subValue)
        if not index then
            return error("xPlayer.setMeta ^5index^1 is Missing!")
        end

        if type(index) ~= "string" then
            return error("xPlayer.setMeta ^5index^1 should be ^5string^1!")
        end

        if value == nil then
            return error("xPlayer.setMeta value is missing!")
        end

        local _type = type(value)

        if not subValue then
            if _type ~= "number" and _type ~= "string" and _type ~= "table" then
                return error(("xPlayer.setMeta ^5%s^1 should be ^5number^1 or ^5string^1 or ^5table^1!"):format(value))
            end

            self.metadata[index] = value
        else
            if _type ~= "string" then
                return error(("xPlayer.setMeta ^5value^1 should be ^5string^1 as a subIndex!"):format(value))
            end

            if not self.metadata[index] or type(self.metadata[index]) ~= "table" then
                self.metadata[index] = {}
            end

            self.metadata[index] = type(self.metadata[index]) == "table" and self.metadata[index] or {}
            self.metadata[index][value] = subValue
        end
        self.triggerEvent('esx:updatePlayerData', 'metadata', self.metadata)
    end

    function self.clearMeta(index, subValues)
        if not index then
            return error("xPlayer.clearMeta ^5index^1 is Missing!")
        end

        if type(index) ~= "string" then
            return error("xPlayer.clearMeta ^5index^1 should be ^5string^1!")
        end

        local metaData = self.metadata[index]
        if metaData == nil then
            if Config.EnableDebug then
                error(("xPlayer.clearMeta ^5%s^1 does not exist!"):format(index))
            end

            return
        end

        if not subValues then
            -- If no subValues is provided, we will clear the entire value in the metaData table
            self.metadata[index] = nil
        elseif type(subValues) == "string" then
            -- If subValues is a string, we will clear the specific subValue within the table
            if type(metaData) == "table" then
                metaData[subValues] = nil
            else
                return error(("xPlayer.clearMeta ^5%s^1 is not a table! Cannot clear subValue ^5%s^1."):format(index, subValues))
            end
        elseif type(subValues) == "table" then
            -- If subValues is a table, we will clear multiple subValues within the table
            for i = 1, #subValues do
                local subValue = subValues[i]
                if type(subValue) == "string" then
                    if type(metaData) == "table" then
                        metaData[subValue] = nil
                    else
                        error(("xPlayer.clearMeta ^5%s^1 is not a table! Cannot clear subValue ^5%s^1."):format(index, subValue))
                    end
                else
                    error(("xPlayer.clearMeta subValues should contain ^5string^1, received ^5%s^1, skipping..."):format(type(subValue)))
                end
            end
        else
            return error(("xPlayer.clearMeta ^5subValues^1 should be ^5string^1 or ^5table^1, received ^5%s^1!"):format(type(subValues)))
        end
        self.triggerEvent('esx:updatePlayerData', 'metadata', self.metadata)
    end

end
