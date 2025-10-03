RegisterCommand("resetmigrations", function(src)
	if src > 0 then
		print("^1[ERROR]^7 This command can only be run from the server console.")
		return
	end

	for version, _ in pairs(Core.Migrations or {}) do
		DeleteResourceKvp(("esx_migration:%s"):format(version))
	end
	print("^2[SUCCESS]^7 Reset all migrations. This will re-run all migrations on the next server start.")
end)

local migrationsRan = 0
local restartRequired = false

for esxVersion, migrations in pairs(Core.Migrations or {}) do
	---@cast esxVersion string
	---@cast migrations table<string, function>

	if ESX.Table.SizeOf(migrations) > 0 then
		print(("^4[INFO]^7 Running migrations for ESX version %s"):format(esxVersion))

		for migrationName, migration in pairs(migrations) do
			local success, result = pcall(migration)
			if not success then
				local err = result --[[@as string]]
				error(("^1[ERROR]^7 Failed migration ^4['%s.%s']^7: %s"):format(esxVersion, migrationName, err))
			end

			local migrationRequiresRestart = result --[[@as boolean]]

			if not restartRequired and migrationRequiresRestart then
				restartRequired = true
			end
		end

		SetResourceKvpInt(("esx_migration:%s"):format(esxVersion), 1)
		print(("^2[SUCCESS]^7 Successfully completed migrations for ESX version %s"):format(esxVersion))
		migrationsRan += 1
	end
end

while restartRequired do
	print(("^4[INFO]^7 Ran migrations for %d ESX version(s). ^1Server restart required!^7"):format(migrationsRan))
	Wait(500)
end
