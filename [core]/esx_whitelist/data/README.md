# Runtime data

This folder holds files created and maintained by the resource at runtime:

- `runtime_config.json` — panel-made configuration overrides (layered over `config/main.lua`)
- `admin_cache.json` — persistent identifier -> ESX group cache
- `discord_cache.json` — persistent Discord verification results
- `*.broken` — quarantined copies of files that failed validation on load

Do not edit these files by hand while the server is running. Deleting them
is safe: the resource recreates them (the whitelist itself never depends on
them, they only cache known-good state).
