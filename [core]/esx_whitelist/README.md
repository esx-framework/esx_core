# esx_whitelist

- Discord guild + role whitelist 
- ESX admin-group authorization via a persistent identifier→group cache
- Admin-only mode and emergency bypass
- Discord webhook logging 
- In-game admin panel

---

## 1. Installation

1. The in-game panel ships **prebuilt** in `web/dist/` — no build step is required to run the resource.
   To rebuild the panel after changing `web/src/`:
   ```bash
   cd /esx_whitelist/web
   npm install
   npm run build
   ```
2. Add to your `server.cfg` (order matters — the resource must start **after** `es_extended`):

   ```cfg
   # Secrets (server-only)
   set discord:botToken "YOUR_DISCORD_BOT_TOKEN"
   set whitelist:webhook "https://discord.com/api/webhooks/..."   # optional logging

   setr esx:ui:logoUrl "https://example.com/logo.png"             # optional; defaults to the ESX logo

   ensure esx_lib
   ensure es_extended
   ensure esx_whitelist
   ```
3. Open `config/main.lua` and set your Discord `GuildId`, `AllowedRoles`, and optionally static `AllowedIdentifiers`.
> `set` convars stay on the server; the theme convars MUST use `setr`, and the secrets MUST use `set`.

## 2. Discord bot setup

1. Create an application + bot at <https://discord.com/developers/applications>.
2. Enable **Server Members Intent** is NOT required for `GET /guilds/{id}/members/{userId}`, but the bot must be **a member of the guild**.
3. Invite the bot with the `bot` scope (no special permissions needed; role reads work via the member endpoint).
4. Put the token in `server.cfg` as shown above. Never put it in `config/main.lua` on a shared repository, and never in any client/NUI file.
5. For webhook logging, set `set whitelist:webhook "https://discord.com/api/webhooks/..."` in `server.cfg`;
6. Copy your guild ID and role IDs (Discord → Settings → Advanced → Developer Mode, then right-click → Copy ID) into the config or the in-game panel.

If the token is missing or invalid, the resource prints a clear startup error and Discord-based checks fail closed (deny) without crashing anything.

## 3. Whitelist modes

| Mode | Behavior |
|---|---|
| `discord` | Player must be a guild member with at least one allowed role. |
| `identifier` | One of the player's FiveM identifiers must be in `AllowedIdentifiers`. |
| `both` + `"or"` | Identifier match **or** Discord verification |
| `both` + `"and"` | Identifier match **and** Discord verification |

Regardless of mode, the evaluation order is always:

```text
0. Whitelist disabled            -> allow
1. Emergency bypass identifiers  -> allow        (method: bypass)
2. Admin-only mode               -> allow/deny   (replaces everything below)
3. Cached admin group            -> allow        (method: admin_group)
4. Mode-specific checks          -> allow/deny
5. Default                       -> deny         (fail closed)
```

## 4. In-game panel

- Open with `/whitelist` (admins only).
- Tabs: Dashboard, Whitelist, Discord, Admins, Logging & Performance.

## 5. Commands

| Command | Description |
|---|---|
| `/whitelist` | Open the admin panel |
| `whitelist status` | Modes, Discord readiness, decision counters (chat/console) |
| `whitelist reload` | Reload runtime config + caches from disk |
| `whitelist cache` | Cache/queue statistics |
| `whitelist cache clear` | Clear the Discord verification cache |
| `whitelist test <serverId>` | Run the full pipeline against an online player |

All commands work in the server console as well. Permission is always checked server-side against the ESX group.

