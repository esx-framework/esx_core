MySQL = {
    Async = {},
    Sync = {},
	Threaded = {} -- remove in the next big version
}

local function safeParameters(params)
    if nil == params then
        return {[''] = ''}
    end

    assert(type(params) == "table", "A table is expected")
    assert(params[1] == nil, "Parameters should not be an array, but a map (key / value pair) instead")

    if next(params) == nil then
        return {[''] = ''}
    end

    return params
end

---
-- Execute a query with no result required, sync version
--
-- @param query
-- @param params
--
-- @return int Number of rows updated
--
function MySQL.Sync.execute(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    local res = 0
    local finishedQuery = false
    exports['mysql-async']:mysql_execute(query, safeParameters(params), function (result)
        res = result
        finishedQuery = true
    end)
    repeat Citizen.Wait(0) until finishedQuery == true
    return res
end
---
-- Execute a query and fetch all results in an sync way
--
-- @param query
-- @param params
--
-- @return table Query results
--
function MySQL.Sync.fetchAll(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    local res = {}
    local finishedQuery = false
    exports['mysql-async']:mysql_fetch_all(query, safeParameters(params), function (result)
        res = result
        finishedQuery = true
    end)
    repeat Citizen.Wait(0) until finishedQuery == true
    return res
end

---
-- Execute a query and fetch the first column of the first row, sync version
-- Useful for count function by example
--
-- @param query
-- @param params
--
-- @return mixed Value of the first column in the first row
--
function MySQL.Sync.fetchScalar(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    local res = ''
    local finishedQuery = false
    exports['mysql-async']:mysql_fetch_scalar(query, safeParameters(params), function (result)
        res = result
        finishedQuery = true
    end)
    repeat Citizen.Wait(0) until finishedQuery == true
    return res
end

---
-- Execute a query and retrieve the last id insert, sync version
--
-- @param query
-- @param params
--
-- @return mixed Value of the last insert id
--
function MySQL.Sync.insert(query, params)
    assert(type(query) == "string", "The SQL Query must be a string")

    local res = 0
    local finishedQuery = false
    exports['mysql-async']:mysql_insert(query, safeParameters(params), function (result)
        res = result
        finishedQuery = true
    end)
    repeat Citizen.Wait(0) until finishedQuery == true
    return res
end

---
-- Execute a List of querys and returns bool true when all are executed successfully
--
-- @param querys
-- @param params
--
-- @return bool if the transaction was successful
--
--function MySQL.Sync.transaction(querys, params)
--    assert(type(querys) == "table", "The SQL Query must be a table of strings")
--
--    return exports['mysql-async']:mysql_sync_transaction(querys, safeParameters(params))
--end

---
-- Execute a query with no result required, async version
--
-- @param query
-- @param params
-- @param func(int)
--
function MySQL.Async.execute(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_execute(query, safeParameters(params), func)
end

---
-- Execute a query and fetch all results in an async way
--
-- @param query
-- @param params
-- @param func(table)
--
function MySQL.Async.fetchAll(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_fetch_all(query, safeParameters(params), func)
end

---
-- Execute a query and fetch the first column of the first row, async version
-- Useful for count function by example
--
-- @param query
-- @param params
-- @param func(mixed)
--
function MySQL.Async.fetchScalar(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_fetch_scalar(query, safeParameters(params), func)
end

---
-- Execute a query and retrieve the last id insert, async version
--
-- @param query
-- @param params
-- @param func(string)
--
function MySQL.Async.insert(query, params, func)
    assert(type(query) == "string", "The SQL Query must be a string")

    exports['mysql-async']:mysql_insert(query, safeParameters(params), func)
end

---
-- Execute a List of querys and returns bool true when all are executed successfully
--
-- @param querys
-- @param params
-- @param func(bool)
--
--function MySQL.Async.transaction(querys, params, func)
--    assert(type(querys) == "table", "The SQL Query must be a table of strings")
--
--    return exports['mysql-async']:mysql_transaction(querys, safeParameters(params), func)
--end

--
-- Remove in the next big update
--
MySQL.Threaded.execute = MySQL.Sync.execute
MySQL.Threaded.fetchAll = MySQL.Sync.fetchAll
MySQL.Threaded.fetchScalar = MySQL.Sync.fetchScalar
MySQL.Threaded.insert = MySQL.Sync.insert


local isReady = false
local callbackDictionary = {}

AddEventHandler('MySQLReady', function ()
    isReady = true
    for i, cb in ipairs(callbackDictionary) do
        callbackDictionary[i] = nil
        cb()
    end
end)

function MySQL.ready (callback)
    if isReady then
        callback()
    else
        table.insert(callbackDictionary, callback)
    end
end
