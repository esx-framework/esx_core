# ESX Whitelist

ESX whitelist system with database identifiers, optional Discord role verification, automatic rules, and an admin NUI control panel.

## Authorization flow

Connection authorization is always evaluated in this order:

1. **Whitelist disabled** → **ALLOW** normal players without identifier or Discord checks.
2. **Configured identifier allowlist** → **ALLOW** without a database or Discord check.
3. **ESX/ACE admin** → **ALLOW** based on the current ESX group or ACE permission.
4. **Identifier mode** → only an enabled database-whitelist identifier can **ALLOW**.
5. **Discord mode** → verify the configured Discord guild role, persist the player's identifiers, then **ALLOW**.
6. With enforcement enabled, no selected-method check passing → **KICK**.

Choose **Identifier database** or **Discord role** in the panel's Discord Integration card. The methods are intentionally separate: enabling Discord does not turn it into a fallback for database identifiers. Successful Discord-role authorizations are saved to the identifier whitelist for audit and recovery. ESX/ACE admin checks use the live group or ACE permission and do not query the `users` table per authorization.

## Requirements

- `es_extended`
- `esx_lib`
- `oxmysql`
- Discord bot token only if Discord role verification is enabled

## Installation

1. Copy the resource to your server resources directory.
2. Import `install.sql` into the server database, or allow the resource to create the tables on first start.
3. Add the resource to `server.cfg` after its dependencies:

```cfg
ensure es_extended
ensure esx_lib
ensure oxmysql
ensure esx_whitelist
```

4. If Discord verification is enabled, configure the bot token in `server.cfg`:

```cfg
set discord:botToken "YOUR_DISCORD_BOT_TOKEN"
```

Never put the Discord bot token in the resource files.

## NUI

Open the admin panel with:

```text
/whitelist
```

Only configured ESX admin groups can use the NUI server callbacks.

The panel supports:

- Master whitelist switch
- Grace period
- Immediate-kick option for connected unauthorized players
- Discord role configuration
- Discord webhook test
- Automatic whitelist rules
- Add/remove whitelist identifiers
- Search and pagination
- Grant/revoke database whitelist status

The production UI is served from `web/dist/index.html`. If you modify `web/src`, rebuild the UI with the project's normal Node/Vite build and deploy the resulting `web/dist` directory.

## Commands

```text
/wl_add [player id]       Add a connected player to the database whitelist
/wl_remove [player id]    Remove a connected player from the database whitelist
/wl_check [player id]     Check authorization and show the method used
/wl_on                    Enable whitelist
/wl_off                   Disable whitelist
/wl_sync                  Refresh the in-memory database whitelist cache
```

Add server-side identifier exceptions in `server/config/main.lua`:

```lua
ServerConfig.AllowedIdentifiers = {
    "license2:your-license-identifier",
    "discord:123456789012345678"
}
```

## Admin permissions

`config/main.lua` controls ESX admin groups:

```lua
Config.AdminGroups = {
    "admin",
    "mod"
}
```

Add the permission in `server.cfg` for each staff group. `add_principal` only assigns a principal; it does **not** make `group.admin` a permission that a resource can check.

```cfg
add_principal identifier.fivem:123456 group.admin
add_ace group.admin esx_whitelist.admin allow
```

Use the identifier type that you actually assign in your server configuration (for example, `identifier.fivem:...` or `identifier.license:...`).

## Automatic rules

Rules are evaluated by priority. The first applicable enabled rule determines the desired master whitelist state.

Supported rule types:

- `admin-presence`
- `player-count`
- `scheduled`

If no rule is applicable, the current master state is retained.

## Security notes

- Discord bot tokens are read from the `discord:botToken` server convar.
- Discord webhook URLs are stored in the resource configuration only when explicitly configured through the NUI.
- Identifier conflicts are rejected instead of silently ignored.
- Database and Discord authorization are performed server-side.
- Disabling the master whitelist allows new normal players to connect without identifier or Discord checks. When enabled, database and Discord failures reject authorization safely.
