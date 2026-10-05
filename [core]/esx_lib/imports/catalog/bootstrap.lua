-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local resource = GetCurrentResourceName()
local readiness = promise.new()
local success = false
local failure = nil
local reconcile = nil

local function awaitCatalog()
    Citizen.Await(readiness)

    assert(success, ('[%s] SQL catalog startup failed: %s'):format(resource, tostring(failure)))

    return true
end

ESXCatalog = {
    awaitReady = awaitCatalog,
    isReady = function()
        return success
    end,
}

local function refreshCatalogs(result)
    if Core and Core.DatabaseConnected then
        if (result.catalogs.jobs or result.catalogs.job_grades) and ESX.RefreshJobs then
            ESX.RefreshJobs()
        end

        if result.catalogs.items and not Config.CustomInventory and ESX.RefreshItems then
            ESX.RefreshItems()
        end
    end

    TriggerEvent('esx:sqlCatalogReady', result.catalogs)
end

local function initialize()
    local locale = Config and (Config.SqlCatalogLocale or Config.Locale)
        or GetConvar('esx:locale', GetConvar('txAdmin-locale', 'en'))

    if locale == 'custom' or locale == 'invalid' then
        locale = 'en'
    end

    if resource == 'es_extended' then
        local source = assert(
            LoadResourceFile('esx_lib', 'imports/catalog/server.lua'),
            'Missing esx_lib catalog service'
        )
        local chunk = assert(load(source, '@@esx_lib/imports/catalog/server.lua', 't', _ENV))
        local catalog = chunk()
        local dataSource = assert(
            LoadResourceFile('esx_lib', 'imports/catalog/data.json'),
            'Missing SQL catalog data'
        )
        local data = json.decode(dataSource)

        assert(type(data) == 'table', 'Invalid SQL catalog data')

        reconcile = catalog.service(MySQL, data, refreshCatalogs)
    end

    MySQL.ready.await()

    local result

    if resource == 'es_extended' then
        result = reconcile(resource, locale)
    else
        result = exports.es_extended:EnsureSqlCatalog(resource, locale)
    end

    assert(type(result) == 'table', 'Invalid SQL catalog preparation result')
    assert(type(result.locale) == 'string', 'Missing SQL catalog locale')
    assert(type(result.imported) == 'number', 'Missing SQL catalog import count')

    return result
end

if resource == 'es_extended' then
    exports('EnsureSqlCatalog', function(name, locale)
        local caller = GetInvokingResource()

        assert(caller == name, 'A resource can only prepare its own SQL catalog')
        awaitCatalog()

        return reconcile(name, locale)
    end)
end

CreateThread(function()
    local ok, result = pcall(function()
        Wait(0)

        return initialize()
    end)

    success = ok

    if not ok then
        failure = result
    end

    readiness:resolve(ok)

    if not ok then
        print(
            ('[%s] SQL catalog FAILED; resource initialization blocked: %s'):format(
                resource,
                tostring(result)
            )
        )

        return
    end

    print(
        ('[%s] SQL catalog 1.16.0 ready (%s): %d missing record(s) prepared'):format(
            resource,
            result.locale,
            result.imported
        )
    )
end)
