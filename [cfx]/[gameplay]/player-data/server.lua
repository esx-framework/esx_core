--- player-data is a basic resource to showcase player identifier storage
--
-- it works in a fairly simple way: a set of identifiers is assigned to an account ID, and said
-- account ID is then returned/added as state bag
--
-- it also implements the `cfx.re/playerData.v1alpha1` spec, which is exposed through the following:
-- - getPlayerId(source: string)
-- - getPlayerById(dbId: string)
-- - getPlayerIdFromIdentifier(identifier: string)
-- - setting `cfx.re/playerData@id` state bag field on the player

-- identifiers that we'll ignore (e.g. IP) as they're low-trust/high-variance
local identifierBlocklist = {
    ip = true
}

-- function to check if the identifier is blocked
local function isIdentifierBlocked(identifier)
    -- Lua pattern to correctly split
    local idType = identifier:match('([^:]+):')

    -- ensure it's a boolean
    return identifierBlocklist[idType] or false
end

-- our database schema, in hierarchical KVS syntax:
-- player:
--     <id>:
--         identifier:
--             <identifier>: 'true'
-- identifier:
--     <identifier>: <playerId>

-- list of player indices to data
local players = {}

-- list of player DBIDs to player indices
local playersById = {}

-- a sequence field using KVS
local function incrementId()
    local nextId = GetResourceKvpInt('nextId')
    nextId = nextId + 1
    SetResourceKvpInt('nextId', nextId)

    return nextId
end

-- gets the ID tied to an identifier in the schema, or nil
local function getPlayerIdFromIdentifier(identifier)
    local str = GetResourceKvpString(('identifier:%s'):format(identifier))

    if not str then
        return nil
    end

    return msgpack.unpack(str).id
end

-- stores the identifier + adds to a logging list
local function setPlayerIdFromIdentifier(identifier, id)
    local str = ('identifier:%s'):format(identifier)
    SetResourceKvp(str, msgpack.pack({ id = id }))
    SetResourceKvp(('player:%s:identifier:%s'):format(id, identifier), 'true')
end

-- stores any new identifiers for this player ID
local function storeIdentifiers(playerIdx, newId)
    for _, identifier in ipairs(GetPlayerIdentifiers(playerIdx)) do
        if not isIdentifierBlocked(identifier) then
            -- TODO: check if the player already has an identifier of this type
            setPlayerIdFromIdentifier(identifier, newId)
        end
    end
end

-- registers a new player (increments sequence, stores data, returns ID)
local function registerPlayer(playerIdx)
    local newId = incrementId()
    storeIdentifiers(playerIdx, newId)

    return newId
end

-- initializes a player's data set
local function setupPlayer(playerIdx)
    -- try getting the oldest-known identity from all the player's identifiers
    local defaultId = 0xFFFFFFFFFF
    local lowestId = defaultId

    for _, identifier in ipairs(GetPlayerIdentifiers(playerIdx)) do
        if not isIdentifierBlocked(identifier) then
            local dbId = getPlayerIdFromIdentifier(identifier)

            if dbId then
                if dbId < lowestId then
                    lowestId = dbId
                end
            end
        end
    end

    -- if this is the default ID, register. if not, update
    local playerId

    if lowestId == defaultId then
        playerId = registerPlayer(playerIdx)
    else
        storeIdentifiers(playerIdx, lowestId)
        playerId = lowestId
    end

    -- add state bag field
    if Player then
        Player(playerIdx).state['cfx.re/playerData@id'] = playerId
    end

    -- and add to our caching tables
    players[playerIdx] = {
        dbId = playerId
    }

    playersById[tostring(playerId)] = playerIdx
end

-- we want to add a player pretty early
AddEventHandler('playerConnecting', function()
    local playerIdx = tostring(source)
    setupPlayer(playerIdx)
end)

-- and migrate them to a 'joining' ID where possible
RegisterNetEvent('playerJoining')

AddEventHandler('playerJoining', function(oldIdx)
    -- resource restart race condition
    local oldPlayer = players[tostring(oldIdx)]

    if oldPlayer then
        players[tostring(source)] = oldPlayer
        players[tostring(oldIdx)] = nil
    else
        setupPlayer(tostring(source))
    end
end)

-- remove them if they're dropped
AddEventHandler('playerDropped', function()
    local player = players[tostring(source)]

    if player then
        playersById[tostring(player.dbId)] = nil
    end

    players[tostring(source)] = nil
end)

-- and when the resource is restarted, set up all players that are on right now
for _, player in ipairs(GetPlayers()) do
    setupPlayer(player)
end

-- also a quick command to get the current state
RegisterCommand('playerData', function(source, args)
    if not args[1] then
        print('Usage:')
        print('\tplayerData getId <dbId>: gets identifiers for ID')
        print('\tplayerData getIdentifier <identifier>: gets ID for identifier')

        return
    end

    if args[1] == 'getId' then
        local prefix = ('player:%s:identifier:'):format(args[2])
        local handle = StartFindKvp(prefix)
        local key

        repeat
            key = FindKvp(handle)

            if key then
                print('result:', key:sub(#prefix + 1))
            end
        until not key

        EndFindKvp(handle)
    elseif args[1] == 'getIdentifier' then
        print('result:', getPlayerIdFromIdentifier(args[2]))
    end
end, true)

-- COMPATIBILITY for server versions that don't export provide
local function getExportEventName(resource, name)
	return string.format('__cfx_export_%s_%s', resource, name)
end

function AddExport(name, fn)
    if not Citizen.Traits or not Citizen.Traits.ProvidesExports then
        AddEventHandler(getExportEventName('cfx.re/playerData.v1alpha1', name), function(setCB)
            setCB(fn)
        end)
    end

    exports(name, fn)
end

-- exports
AddExport('getPlayerIdFromIdentifier', getPlayerIdFromIdentifier)

AddExport('getPlayerId', function(playerIdx)
    local player = players[tostring(playerIdx)]

    if not player then
        return nil
    end

    return player.dbId
end)

AddExport('getPlayerById', function(playerId)
    return playersById[tostring(playerId)]
end)