-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Cache <const> = xLib.require "@esx_whitelist.server.module.whitelist.cache"
local Util <const> = xLib.require "@esx_whitelist.server.module.whitelist.util"

---@class Database
---@description Provides database operations for whitelist entries and identifiers including CRUD, search, and cache refresh.
local Database = {}
local noop = function() end
local IDENTITY_ANCHOR_TYPES <const> = { license = true, license2 = true }

local function canonicalIdentifier(identifier)
    if type(identifier) ~= "string" then return nil end
    local idType, value = Util.normalizeIdentifier(identifier)
    if idType and value then return idType .. ":" .. value end
    return nil
end

---@description Helper function.
local function validIdentifiers(identifiers)
    local result, seen = {}, {}
    for i = 1, #(identifiers or {}) do
        local identifier = canonicalIdentifier(identifiers[i])
        if identifier and identifier ~= "" and not seen[identifier] then
            local idType = identifier:match("^(%w+):")
            if idType then
                seen[identifier] = true
                result[#result + 1] = { identifier = identifier, type = idType }
            end
        end
    end
    return result
end

---@description Helper function.
local function rawIdentifiers(clean)
    local result = {}
    for i = 1, #clean do result[#result + 1] = clean[i].identifier end
    return result
end

---@description Helper function.
local function identifierInsertQueries(id, clean)
    local placeholders, values = {}, {}
    for i = 1, #clean do
        placeholders[#placeholders + 1] = "(?, ?, ?)"
        values[#values + 1] = id
        values[#values + 1] = clean[i].type
        values[#values + 1] = clean[i].identifier
    end
    if #placeholders == 0 then return {} end
    return {{
        query = "INSERT INTO esx_whitelist_identifier (whitelist_id, type, identifier) VALUES " .. table.concat(placeholders, ", "),
        values = values
    }}
end

---@description Helper function.
local function insertIdentifiers(id, clean, callback)
    if #clean == 0 then return callback(true) end
    local statements = identifierInsertQueries(id, clean)
    local statement = statements[1]
    if not statement then return callback(true) end
    MySQL.insert(statement.query, statement.values, function(result)
        callback(result ~= nil and result ~= false)
    end)
end

---@description Helper function.
local function normalizeWhitelisted(value)
    if value == true or tostring(value):lower() == "true" then return 1 end
    return tonumber(value) == 1 and 1 or 0
end

---@description Helper function.
local function escapeLikePrefix(value)
    return (value:gsub("[=%%_]", function(character)
        return "=" .. character
    end)) .. "%"
end

---@description Initializes database tables if they do not exist.
---@param cb fun(success: boolean)
function Database.init(cb)
    cb = cb or noop
    local schema = LoadResourceFile(GetCurrentResourceName(), "install.sql")
    if type(schema) ~= "string" then
        if Config.Debug then
            print("^1[esx_whitelist] Failed to load install.sql.^7")
        end
        return cb(false)
    end

    local statements = {}
    for statement in schema:gmatch("(.-);") do
        if statement:match("%S") then statements[#statements + 1] = statement end
    end
    if #statements == 0 then return cb(false) end

    ---@description Helper function.
    local function runStatement(index)
        if index > #statements then
            return cb(true)
        end

        MySQL.query(statements[index], {}, function(result)
            if result == false then
                if Config.Debug then
                    print(("^1[esx_whitelist] Failed to execute install.sql statement %d.^7"):format(index))
                end
                return cb(false)
            end
            runStatement(index + 1)
        end)
    end

    runStatement(1)
end

---@description Refreshes the in-memory whitelist cache from the database.
---@param cb fun(success: boolean)
function Database.refreshCache(cb)
    cb = cb or noop
    local generation = Cache.beginWhitelistRefresh()
    MySQL.query([[SELECT w.id, wi.identifier
        FROM esx_whitelist w
        INNER JOIN esx_whitelist_identifier wi ON wi.whitelist_id = w.id
        WHERE w.whitelisted = 1]], {}, function(rows)
        if rows == false then return cb(false) end

        local cache = {}
        for i = 1, #(rows or {}) do
            local id = tonumber(rows[i].id)
            local identifier = canonicalIdentifier(rows[i].identifier)
            if id and type(identifier) == "string" then cache[identifier] = id end
        end
        cb(Cache.replaceWhitelist(cache, generation))
    end)
end

---@description Finds a whitelist entry by a single identifier.
---@param identifier string The identifier to search for
---@param cb fun(row: table?)
function Database.findByIdentifier(identifier, cb)
    cb = cb or noop
    if type(identifier) ~= "string" or identifier == "" then return cb(nil) end
    local normalizedIdentifier = canonicalIdentifier(identifier)
    if not normalizedIdentifier then return cb(nil) end
    identifier = normalizedIdentifier

    MySQL.query([[SELECT w.id, w.player_name, w.whitelisted
        FROM esx_whitelist w
        INNER JOIN esx_whitelist_identifier wi ON wi.whitelist_id = w.id
        WHERE wi.identifier = ? LIMIT 1]], { identifier }, function(rows)
        cb(rows ~= false and rows[1] or nil)
    end)
end

---@description Finds a whitelist entry by multiple identifiers.
---@param identifiers string[] List of identifiers
---@param cb fun(row: table?)
function Database.findByIdentifiers(identifiers, cb)
    cb = cb or noop
    local clean = validIdentifiers(identifiers)
    if #clean == 0 then return cb(nil) end

    local placeholders, params = {}, {}
    for i = 1, #clean do
        placeholders[#placeholders + 1] = "?"
        params[#params + 1] = clean[i].identifier
    end

    MySQL.query(([[SELECT w.id, w.player_name, w.whitelisted
        FROM esx_whitelist w
        INNER JOIN esx_whitelist_identifier wi ON wi.whitelist_id = w.id
        WHERE wi.identifier IN (%s)
        ORDER BY w.id ASC LIMIT 1]]):format(table.concat(placeholders, ",")), params, function(rows)
        cb(rows ~= false and rows[1] or nil)
    end)
end

---@description Helper function.
local function findIdentifierOwners(identifiers, cb)
    local clean = validIdentifiers(identifiers)
    if #clean == 0 then return cb({}) end

    local placeholders, params = {}, {}
    for i = 1, #clean do
        placeholders[#placeholders + 1] = "?"
        params[#params + 1] = clean[i].identifier
    end

    MySQL.query(([[SELECT w.id, w.player_name, w.whitelisted, wi.identifier
        FROM esx_whitelist w
        INNER JOIN esx_whitelist_identifier wi ON wi.whitelist_id = w.id
        WHERE wi.identifier IN (%s)
        ORDER BY w.id ASC]]):format(table.concat(placeholders, ",")), params, function(rows)
        cb(rows ~= false and (rows or {}) or nil)
    end)
end

---@description Finds conflicting identifiers assigned to other whitelist entries.
---@param whitelistId number The whitelist entry ID
---@param identifiers string[] Identifiers to check
---@param cb fun(conflicts: table[])
function Database.findConflicts(whitelistId, identifiers, cb)
    cb = cb or noop
    local clean = validIdentifiers(identifiers)
    if #clean == 0 then return cb({}) end

    local whitelistId = tonumber(whitelistId)
    if not whitelistId then return cb({}) end
    local placeholders, params = {}, {}
    for i = 1, #clean do
        placeholders[#placeholders + 1] = "?"
        params[#params + 1] = clean[i].identifier
    end
    params[#params + 1] = whitelistId

    MySQL.query(([[SELECT wi.identifier, wi.whitelist_id
        FROM esx_whitelist_identifier wi
        WHERE wi.identifier IN (%s) AND wi.whitelist_id <> ?]]):format(table.concat(placeholders, ",")),
        params, function(rows)
            cb(rows ~= false and rows or {})
        end)
end

---@description Gets all identifiers for a whitelist entry.
---@param whitelistId number The whitelist entry ID
---@param cb fun(rows: table[])
function Database.getIdentifiers(whitelistId, cb)
    cb = cb or noop
    whitelistId = tonumber(whitelistId)
    if not whitelistId then return cb({}) end

    MySQL.query("SELECT identifier FROM esx_whitelist_identifier WHERE whitelist_id = ? ORDER BY id ASC", { whitelistId }, function(rows)
        rows = rows ~= false and rows or {}
        for i = 1, #rows do
            rows[i].identifier = canonicalIdentifier(rows[i].identifier)
        end
        cb(rows)
    end)
end

---@description Gets a flat list of identifier strings for a whitelist entry.
---@param whitelistId number The whitelist entry ID
---@param cb fun(identifiers: string[])
function Database.getIdentifierList(whitelistId, cb)
    cb = cb or noop
    Database.getIdentifiers(whitelistId, function(rows)
        local identifiers = {}
        for i = 1, #(rows or {}) do identifiers[#identifiers + 1] = rows[i].identifier end
        cb(identifiers)
    end)
end

---@description Helper function.
local function buildAtomicInsertQueries(playerName, whitelisted, addedBy, clean)
    local queries = {}
    queries[1] = {
        query = "INSERT INTO esx_whitelist (player_name, whitelisted, added_by) VALUES (?, ?, ?)",
        values = {
            tostring(playerName or "Unknown"):sub(1, 255),
            whitelisted and 1 or 0,
            tostring(addedBy or "Unknown"):sub(1, 255)
        }
    }
    local placeholders, values = {}, {}
    for i = 1, #clean do
        placeholders[#placeholders + 1] = "(LAST_INSERT_ID(), ?, ?)"
        values[#values + 1] = clean[i].type
        values[#values + 1] = clean[i].identifier
    end
    queries[2] = {
        query = "INSERT INTO esx_whitelist_identifier (whitelist_id, type, identifier) VALUES " .. table.concat(placeholders, ", "),
        values = values
    }
    return queries
end

---@description Inserts a new player with identifiers into the database atomically.
---@param playerName string Player display name
---@param identifiers string[] Player identifiers
---@param whitelisted boolean Initial whitelist status
---@param addedBy string Who added the player
---@param cb fun(id: number?, error?: string, existing?: table)
---@description Helper function.
function Database.insertPlayer(playerName, identifiers, whitelisted, addedBy, cb)
    cb = cb or noop
    local clean = validIdentifiers(identifiers)
    if #clean == 0 then return cb(nil, "no_identifiers") end

    local identifiersOnly = rawIdentifiers(clean)
    Database.findByIdentifiers(identifiersOnly, function(existing)
        if existing then return cb(nil, "identifier_already_exists", existing) end

        local queries = buildAtomicInsertQueries(playerName, whitelisted, addedBy, clean)
        MySQL.transaction(queries, function(success)
            if not success then
                return Database.findByIdentifiers(identifiersOnly, function(racedEntry)
                    if racedEntry then
                        return cb(nil, "identifier_already_exists", racedEntry)
                    end
                    cb(nil, "identifier_insert_failed")
                end)
            end

            Database.findByIdentifiers(identifiersOnly, function(createdEntry)
                local id = createdEntry and tonumber(createdEntry.id)
                if id then
                    cb(id)
                else
                    cb(nil, "insert_verification_failed")
                end
            end)
        end)
    end)
end

---@description Updates whitelist status for an entry.
---@param id number The whitelist entry ID
---@param status number 0 or 1
---@param addedBy string Optional who made the change
---@param cb fun(affected: number)
function Database.setStatus(id, status, addedBy, cb)
    cb = cb or noop
    id = tonumber(id)
    status = tonumber(status)
    if not id or (status ~= 0 and status ~= 1) then return cb(0) end

    local query, params
    if addedBy then
        query = "UPDATE esx_whitelist SET whitelisted = ?, added_by = ? WHERE id = ?"
        params = { status, tostring(addedBy):sub(1, 255), id }
    else
        query = "UPDATE esx_whitelist SET whitelisted = ? WHERE id = ?"
        params = { status, id }
    end
    MySQL.update(query, params, function(affected)
        if affected and tonumber(affected) > 0 then return cb(affected) end
        MySQL.query("SELECT whitelisted FROM esx_whitelist WHERE id = ? LIMIT 1", { id }, function(rows)
            local alreadySet = rows ~= false and rows[1] and tonumber(rows[1].whitelisted) == status
            cb(alreadySet and 1 or 0)
        end)
    end)
end

---@description Ensures a player is whitelisted, inserting if needed and adding missing identifiers.
---@param playerName string Player display name
---@param identifiers string[] Player identifiers
---@param addedBy string Who added the player
---@param cb fun(success: boolean, error?: string, whitelistId?: number)
---@param retryCount number Internal retry counter
---@description Helper function.
function Database.ensureWhitelisted(playerName, identifiers, addedBy, cb, retryCount)
    cb = cb or noop
    retryCount = type(retryCount) == "number" and retryCount or 0
    local clean = validIdentifiers(identifiers)
    if #clean == 0 then return cb(false, "no_identifiers") end

    local identifiersOnly = rawIdentifiers(clean)
    local cacheIdentifiers = identifiersOnly
    local existing
    ---@description Helper function.
    local function cacheAndFinish(id)
        Cache.setWhitelistBatch(cacheIdentifiers, id)
        cb(true, nil, id)
    end

    ---@description Helper function.
    local function enable(id)
        if tonumber(existing and existing.whitelisted) == 1 then return cacheAndFinish(id) end

        MySQL.update("UPDATE esx_whitelist SET whitelisted = 1, added_by = ? WHERE id = ?", {
            tostring(addedBy or "system:admin"):sub(1, 255),
            id
        }, function(affected)
            if affected and tonumber(affected) > 0 then return cacheAndFinish(id) end

            MySQL.query("SELECT whitelisted FROM esx_whitelist WHERE id = ? LIMIT 1", { id }, function(rows)
                local enabled = rows ~= false and rows[1] and tonumber(rows[1].whitelisted) == 1
                if not enabled then return cb(false, "verify_failed", id) end
                cacheAndFinish(id)
            end)
        end)
    end

    local hasStrongIdentifier = false
    for i = 1, #clean do
        if IDENTITY_ANCHOR_TYPES[clean[i].type] then
            hasStrongIdentifier = true
            break
        end
    end

    ---@description Helper function.
    local function insertNew(identifiersToInsert)
        if #identifiersToInsert == 0 then return cb(false, "identity_conflict") end
        cacheIdentifiers = identifiersToInsert
        Database.insertPlayer(playerName, identifiersToInsert, true, addedBy, function(id, err)
            if id then return cacheAndFinish(id) end
            if err == "identifier_already_exists" and retryCount < 2 then
                return Database.ensureWhitelisted(playerName, identifiersOnly, addedBy, cb, retryCount + 1)
            end
            cb(false, err or "insert_failed")
        end)
    end

    findIdentifierOwners(identifiersOnly, function(ownerRows)
        if not ownerRows then return cb(false, "identifier_lookup_failed") end

        local owners, anchorOwners = {}, {}
        for i = 1, #ownerRows do
            local row = ownerRows[i]
            local ownerId = tonumber(row.id)
            if ownerId then
                if not owners[ownerId] then owners[ownerId] = row end
                local idType = type(row.identifier) == "string" and row.identifier:match("^(%w+):") or nil
                if idType and IDENTITY_ANCHOR_TYPES[idType:lower()] then
                    anchorOwners[ownerId] = true
                end
            end
        end

        local existingAnchorId, anchorCount
        anchorCount = 0
        for ownerId in pairs(anchorOwners) do
            existingAnchorId = ownerId
            anchorCount = anchorCount + 1
        end
        if anchorCount > 1 then return cb(false, "identity_anchor_conflict") end

        local allowEnrichment = anchorCount == 1
        if allowEnrichment then
            existing = owners[existingAnchorId]
        elseif not hasStrongIdentifier then
            local ownerId, ownerCount
            ownerCount = 0
            for candidateId in pairs(owners) do
                ownerId = candidateId
                ownerCount = ownerCount + 1
            end
            if ownerCount > 1 then return cb(false, "ambiguous_identifiers") end
            if ownerCount == 1 then existing = owners[ownerId] end
        end

        if not existing then
            local unowned = {}
            for i = 1, #identifiersOnly do
                local owned = false
                for j = 1, #ownerRows do
                    if ownerRows[j].identifier == identifiersOnly[i] then
                        owned = true
                        break
                    end
                end
                if not owned then unowned[#unowned + 1] = identifiersOnly[i] end
            end
            return insertNew(unowned)
        end

        local id = tonumber(existing.id)
        if not id then return cb(false, "invalid_id") end

        Database.getIdentifiers(id, function(rows)
            local known, knownIdentifiers, missing = {}, {}, {}
            for i = 1, #(rows or {}) do
                local identifier = rows[i].identifier
                if type(identifier) == "string" then
                    known[identifier] = true
                    knownIdentifiers[#knownIdentifiers + 1] = identifier
                end
            end
            cacheIdentifiers = knownIdentifiers

            if not allowEnrichment then return enable(id) end

            for i = 1, #identifiersOnly do
                if not known[identifiersOnly[i]] then missing[#missing + 1] = identifiersOnly[i] end
            end
            if #missing == 0 then return enable(id) end

            Database.findConflicts(id, missing, function(conflicts)
                local conflicting = {}
                for i = 1, #(conflicts or {}) do conflicting[conflicts[i].identifier] = true end
                local safe = {}
                for i = 1, #missing do
                    if not conflicting[missing[i]] then safe[#safe + 1] = missing[i] end
                end

                insertIdentifiers(id, safe, function(success)
                    if not success then
                        if retryCount < 2 then
                            return Database.ensureWhitelisted(playerName, identifiersOnly, addedBy, cb, retryCount + 1)
                        end
                        return cb(false, "identifier_insert_failed", id)
                    end

                    for i = 1, #safe do
                        knownIdentifiers[#knownIdentifiers + 1] = safe[i]
                    end
                    cacheIdentifiers = knownIdentifiers
                    enable(id)
                end)
            end)
        end)
    end)
end

---@description Adds identifiers to an existing whitelist entry.
---@param id number The whitelist entry ID
---@param identifiers string[] Identifiers to add
---@param cb fun(success: boolean, error?: string, conflicts?: table[])
function Database.addIdentifiers(id, identifiers, cb)
    cb = cb or noop
    id = tonumber(id)
    if not id then return cb(false, "invalid_id") end

    local clean = validIdentifiers(identifiers)
    if #clean == 0 then return cb(true) end

    Database.getIdentifiers(id, function(rows)
        local known = {}
        for i = 1, #(rows or {}) do known[rows[i].identifier] = true end
        local missing = {}
        for i = 1, #clean do
            if not known[clean[i].identifier] then missing[#missing + 1] = clean[i] end
        end
        if #missing == 0 then return cb(true) end

        Database.findConflicts(id, missing, function(conflicts)
            if #(conflicts or {}) > 0 then return cb(false, "identifier_already_exists", conflicts) end

            insertIdentifiers(id, missing, cb)
        end)
    end)
end

---@description Searches whitelist entries with keyset pagination and indexed prefix filters.
---@param request table Search parameters
---@param cb fun(result: {entries: table[], cursor: number?, nextCursor: number?, hasMore: boolean, limit: number})
function Database.search(request, cb)
    cb = cb or noop
    request = type(request) == "table" and request or {}
    local limit = math.min(100, math.max(10, math.floor(tonumber(request.limit) or 50)))
    local search = type(request.search) == "string" and request.search:sub(1, 100) or ""
    local status = tonumber(request.status)
    local cursor = tonumber(request.cursor)
    if cursor then cursor = math.floor(cursor) end
    if not cursor or cursor <= 0 then cursor = nil end

    local where, params = {}, {}
    local join = ""
    local idType, idValue = Util.normalizeIdentifier(search)
    local exactIdentifier = idType and idValue and (idType .. ":" .. idValue) or nil

    if exactIdentifier then
        join = " INNER JOIN `esx_whitelist_identifier` wi ON wi.whitelist_id = w.id"
        where[#where + 1] = "wi.identifier = ?"
        params[#params + 1] = exactIdentifier
    elseif search ~= "" and search:match("^%w+:") then
        where[#where + 1] = [[EXISTS (
            SELECT 1 FROM `esx_whitelist_identifier` wi
            WHERE wi.whitelist_id = w.id AND wi.identifier LIKE ? ESCAPE '='
        )]]
        params[#params + 1] = escapeLikePrefix(search:lower())
    elseif search ~= "" then
        where[#where + 1] = "w.player_name LIKE ? ESCAPE '='"
        params[#params + 1] = escapeLikePrefix(search)
    end

    if status == 0 or status == 1 then
        where[#where + 1] = "w.whitelisted = ?"
        params[#params + 1] = status
    end
    if cursor then
        where[#where + 1] = "w.id < ?"
        params[#params + 1] = cursor
    end

    local clause = #where > 0 and (" WHERE " .. table.concat(where, " AND ")) or ""
    local pageParams = {}
    for i = 1, #params do pageParams[#pageParams + 1] = params[i] end
    pageParams[#pageParams + 1] = limit + 1

    MySQL.query(([[SELECT w.id, w.player_name, w.whitelisted
        FROM `esx_whitelist` w%s%s
        ORDER BY w.id DESC
        LIMIT ?]]):format(join, clause), pageParams, function(rows)
        if rows == false then
            return cb({ entries = {}, cursor = cursor, nextCursor = nil, hasMore = false, limit = limit })
        end

        local hasMore = #rows > limit
        if hasMore then rows[#rows] = nil end
        if #rows == 0 then
            return cb({ entries = {}, cursor = cursor, nextCursor = nil, hasMore = false, limit = limit })
        end

        local ids, entriesById = {}, {}
        for i = 1, #rows do
            local row = rows[i]
            local id = tonumber(row.id)
            if id then
                ids[#ids + 1] = id
                entriesById[id] = {
                    id = id,
                    playerName = row.player_name or "Unknown",
                    whitelisted = normalizeWhitelisted(row.whitelisted),
                    identifiers = {}
                }
            end
        end

        local placeholders = {}
        for i = 1, #ids do placeholders[#placeholders + 1] = "?" end
        MySQL.query(([[SELECT whitelist_id, identifier
            FROM esx_whitelist_identifier
            WHERE whitelist_id IN (%s)
            ORDER BY whitelist_id, id ASC]]):format(table.concat(placeholders, ",")), ids, function(identifierRows)
            local identifiersById = {}
            for i = 1, #(identifierRows or {}) do
                local row = identifierRows[i]
                local id = tonumber(row.whitelist_id)
                if id and type(row.identifier) == "string" then
                    if not identifiersById[id] then identifiersById[id] = {} end
                    identifiersById[id][#identifiersById[id] + 1] = canonicalIdentifier(row.identifier)
                end
            end

            local entries = {}
            for i = 1, #ids do
                local entry = entriesById[ids[i]]
                if entry then
                    entry.identifiers = identifiersById[ids[i]] or {}
                    entries[#entries + 1] = entry
                end
            end
            cb({
                entries = entries,
                cursor = cursor,
                nextCursor = hasMore and entries[#entries].id or nil,
                hasMore = hasMore,
                limit = limit
            })
        end)
    end)
end

return Database
