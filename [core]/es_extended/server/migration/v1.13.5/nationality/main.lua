local esxVersion = "v1.13.5"

Core.Migrations = Core.Migrations or {}
Core.Migrations[esxVersion] = Core.Migrations[esxVersion] or {}

if GetResourceKvpInt(("esx_migration:%s"):format(esxVersion)) == 1 then
    return
end

---@return boolean restartRequired
Core.Migrations[esxVersion].nationality = function()
    print("^4[esx_migration:v1.13.5:nationality]^7 Adding nationality column to users table.")

    local col = MySQL.scalar.await([[
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'users'
        AND COLUMN_NAME = 'nationality'
    ]])

    if col == 0 then
        print("^4[esx_migration:v1.13.5:nationality]^7 Column not found, altering users table.")
        MySQL.update.await([[
            ALTER TABLE `users`
            ADD COLUMN `nationality` VARCHAR(52) DEFAULT NULL AFTER `height`
        ]])
    else
        print("^4[esx_migration:v1.13.5:nationality]^7 Column already exists, migration not needed.")
        return false
    end

    print("^4[esx_migration:v1.13.5:nationality]^7 Migration complete.")
    return true
end
