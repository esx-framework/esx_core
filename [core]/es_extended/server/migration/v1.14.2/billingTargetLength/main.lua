local esxVersion = "v1.14.2"

Core.Migrations = Core.Migrations or {}
Core.Migrations[esxVersion] = Core.Migrations[esxVersion] or {}

if GetResourceKvpInt(("esx_migration:%s"):format(esxVersion)) == 1 then
  return
end

---@return boolean restartRequired
Core.Migrations[esxVersion].billingTargetLength = function()
  print("^4[esx_migration:v1.14.2:billingTargetLength]^7 Checking the length of billing.target.")

  local length = MySQL.scalar.await([[
    SELECT CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'billing'
      AND COLUMN_NAME = 'target'
  ]])

  if not length then
    print("^4[esx_migration:v1.14.2:billingTargetLength]^7 Column not found, migration not needed.")
    return false
  end

  if length >= 60 then
    print(("^4[esx_migration:v1.14.2:billingTargetLength]^7 Column is already varchar(%s), migration not needed."):format(length))
    return false
  end

  print(("^4[esx_migration:v1.14.2:billingTargetLength]^7 Column is varchar(%s), widening it to 60."):format(length))

  MySQL.update.await([[
    ALTER TABLE `billing`
      MODIFY `target` VARCHAR(60) NOT NULL
  ]])

  print("^4[esx_migration:v1.14.2:billingTargetLength]^7 Migration complete.")
  return true
end
