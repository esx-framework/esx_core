local esxVersion = "v1.13.5"

Core.Migrations = Core.Migrations or {}
Core.Migrations[esxVersion] = Core.Migrations[esxVersion] or {}

if GetResourceKvpInt(("esx_migration:%s"):format(esxVersion)) == 1 then
  return
end

---@return boolean restartRequired
Core.Migrations[esxVersion].jobTypes = function()
  print("^4[esx_migration:v1.13.5:jobTypes]^7 Adding job type column to jobs table.")

  local col = MySQL.scalar.await([[
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'jobs'
      AND COLUMN_NAME = 'type'
  ]])

  if col == 0 then
    print("^4[esx_migration:v1.13.5:jobTypes]^7 Column not found, altering jobs table.")
    MySQL.update.await([[
      ALTER TABLE `jobs`
        ADD COLUMN `type` VARCHAR(50) NOT NULL DEFAULT 'civ' AFTER `label`
    ]])
  else
    print("^4[esx_migration:v1.13.5:jobTypes]^7 Column already exists, migration not needed.")
    return false
  end

  print("^4[esx_migration:v1.13.5:jobTypes]^7 Migration complete.")
  return true
end
