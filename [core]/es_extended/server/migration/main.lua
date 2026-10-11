-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

RegisterCommand('resetmigrations', function(src)
    if src > 0 then
        print('^1[ERROR]^7 This command can only be run from the server console.')
        return
    end

    for version, _ in pairs(Core.Migrations or {}) do
        DeleteResourceKvp(('esx_migration:%s'):format(version))
        DeleteResourceKvp(('esx_migration:%s:success_logged'):format(version))
    end

    print(
        '^2[SUCCESS]^7 Reset all migrations. This will re-run all migrations on the next server start.'
    )
end)

local migrationsRan = 0
local restartRequired = false

local versions = {}

for version in pairs(Core.Migrations or {}) do
    versions[#versions + 1] = version
end

table.sort(versions, function(a, b)
    local am, an, ap = a:match('v?(%d+)%.(%d+)%.(%d+)')
    local bm, bn, bp = b:match('v?(%d+)%.(%d+)%.(%d+)')

    assert(am and bm, 'Invalid migration version')

    local av = {
        tonumber(am),
        tonumber(an),
        tonumber(ap),
    }

    local bv = {
        tonumber(bm),
        tonumber(bn),
        tonumber(bp),
    }

    for i = 1, 3 do
        if av[i] ~= bv[i] then
            return av[i] < bv[i]
        end
    end

    return a < b
end)

for _, esxVersion in ipairs(versions) do
    local migrations = Core.Migrations[esxVersion]
    ---@cast esxVersion string
    ---@cast migrations table<string, function>

    if xLib.table.sizeOf(migrations) > 0 then
        local logKey = ('esx_migration:%s:success_logged'):format(esxVersion)
        local logSuccess = GetResourceKvpInt(logKey) ~= 1

        if logSuccess then
            print(('^4[INFO]^7 Running migrations for ESX version %s'):format(esxVersion))
        end

        local names = {}

        for name in pairs(migrations) do
            names[#names + 1] = name
        end

        table.sort(names)

        for _, migrationName in ipairs(names) do
            local migration = migrations[migrationName]
            local success, result = pcall(migration)

            if not success then
                local err = result --[[@as string]]
                error(
                    ("^1[ERROR]^7 Failed migration ^4['%s.%s']^7: %s"):format(
                        esxVersion,
                        migrationName,
                        err
                    )
                )
            end

            local migrationRequiresRestart = result --[[@as boolean]]

            if not restartRequired and migrationRequiresRestart then
                restartRequired = true
            end
        end

        SetResourceKvpInt(('esx_migration:%s'):format(esxVersion), 1)
        if logSuccess then
            print(
                ('^2[SUCCESS]^7 Successfully completed migrations for ESX version %s'):format(
                    esxVersion
                )
            )
            SetResourceKvpInt(logKey, 1)
        end
        migrationsRan = migrationsRan + 1
    end
end

while restartRequired do
    print(
        ('^4[INFO]^7 Ran migrations for %d ESX version(s). ^1Server restart required!^7'):format(
            migrationsRan
        )
    )
    Wait(500)
end
