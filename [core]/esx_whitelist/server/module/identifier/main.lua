-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

return function(Util, IdentifierUtil, RuntimeConfig, Log, Database)
    local Identifier = { ready = false }
    local lookups = { whitelist = {}, admin_only = {}, bypass = {} }

    function Identifier:ReplaceFromRows(rows)
        local replacement = { whitelist = {}, admin_only = {}, bypass = {} }

        for i = 1, #rows do
            local row = rows[i]

            if replacement[row.type] and Util.ValidateAccessIdentifier(row.identifier) then
                replacement[row.type][Util.NormalizeIdentifier(row.identifier)] = true
            else
                Log(
                    'warning',
                    'Ignoring invalid persisted access identifier: '
                        .. Util.MaskIdentifier(row.identifier)
                )
            end
        end

        lookups = replacement
        self.ready = true
    end

    function Identifier:Rebuild()
        return RuntimeConfig:WithWriteLock(function()
            if not Database or not Database.ready then
                return false, 'database unavailable'
            end

            local rows, err = Database:LoadIdentifiers()

            if not rows then
                return false, err
            end

            self:ReplaceFromRows(rows)
            RuntimeConfig:RefreshIdentifierProjection()

            return true
        end)
    end

    function Identifier:MatchWhitelist(identifiers)
        return Util.MatchAnyIdentifier(identifiers, lookups.whitelist)
    end

    function Identifier:MatchAdminOnly(identifiers)
        return Util.MatchAnyIdentifier(identifiers, lookups.admin_only)
    end

    function Identifier:MatchBypass(identifiers)
        return Util.MatchAnyIdentifier(identifiers, lookups.bypass)
    end

    function Identifier:GetList(idType)
        local list = {}

        for identifier in pairs(lookups[idType] or {}) do
            list[#list + 1] = identifier
        end

        table.sort(list)

        return list
    end

    ---Called under RuntimeConfig's shared write lock, after schema validation.
    function Identifier:Sync(idType, list)
        if not self.ready or not Database or not Database.ready then
            return false, 'identifier storage unavailable'
        end

        local ok, err = Database:SyncIdentifiers(idType, list)

        if not ok then
            return false, err
        end

        lookups[idType] = Util.BuildIdentifierLookup(list)

        return true
    end

    local function mutate(identifier, idType, adding)
        idType = idType or 'whitelist'

        if not lookups[idType] then
            return false, 'invalid identifier category'
        end

        -- Unsafe legacy credentials may still be removed by administrators.
        if
            not Util.ValidateIdentifier(identifier)
            or (adding and not Util.ValidateAccessIdentifier(identifier))
        then
            return false, 'invalid or disallowed access identifier'
        end

        if not Identifier.ready or not Database or not Database.ready then
            return false, 'identifier storage unavailable'
        end

        local normalized = Util.NormalizeIdentifier(identifier)

        return RuntimeConfig:WithWriteLock(function()
            local ok, err

            if adding then
                ok, err = Database:AddIdentifier(normalized, idType)
            else
                ok, err = Database:RemoveIdentifier(normalized, idType)
            end

            if not ok then
                return false, err
            end

            lookups[idType][normalized] = adding and true or nil
            RuntimeConfig:RefreshIdentifierProjection()

            return true
        end)
    end

    function Identifier:Add(identifier, idType)
        return mutate(identifier, idType, true)
    end

    function Identifier:Remove(identifier, idType)
        return mutate(identifier, idType, false)
    end

    function Identifier:GetCounts()
        local function count(lookup)
            local n = 0

            for _ in pairs(lookup) do
                n = n + 1
            end

            return n
        end

        return {
            whitelist = count(lookups.whitelist),
            adminOnly = count(lookups.admin_only),
            bypass = count(lookups.bypass),
        }
    end

    RuntimeConfig:BindIdentifiers(Identifier)

    return Identifier
end
