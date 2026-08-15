local esxVersion = "v1.14.2"

Core.Migrations = Core.Migrations or {}
Core.Migrations[esxVersion] = Core.Migrations[esxVersion] or {}

if GetResourceKvpInt(("esx_migration:%s"):format(esxVersion)) == 1 then
  return
end

local targets = {
  { table = "billing", column = "identifier" },
  { table = "owned_vehicles", column = "owner" },
  { table = "user_licenses", column = "owner" },
  { table = "society_moneywash", column = "identifier" },
  { table = "addon_account_data", column = "owner" },
  { table = "addon_inventory_items", column = "owner" },
  { table = "datastore_data", column = "owner" },
}

---@return boolean restartRequired
Core.Migrations[esxVersion].multicharDeleteIndexes = function()
  print("^4[esx_migration:v1.14.2:multicharDeleteIndexes]^7 Indexing character deletion columns.")

  for i = 1, #targets do
    local target = targets[i]

    local tableExists = MySQL.scalar.await([[
      SELECT COUNT(*)
      FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = ?
    ]], { target.table })

    if tableExists ~= 0 then
      local leadingIndex = MySQL.scalar.await([[
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND COLUMN_NAME = ?
          AND SEQ_IN_INDEX = 1
      ]], { target.table, target.column })

      if leadingIndex == 0 then
        MySQL.update.await(("CREATE INDEX `esx_%s_%s` ON `%s` (`%s`)"):format(target.table, target.column, target.table, target.column))
        print(("^4[esx_migration:v1.14.2:multicharDeleteIndexes]^7 Indexed ^5%s.%s^7."):format(target.table, target.column))
      end
    end
  end

  print("^4[esx_migration:v1.14.2:multicharDeleteIndexes]^7 Migration complete.")
  return false
end
