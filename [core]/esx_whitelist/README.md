<h1 align='center'>ESX Whitelist System</h1>
<p align='center'><a href='https://discord.esx-framework.org/'>Discord</a> - <a href='https://esx-framework.org/'>Website</a> - <a href='https://docs.esx-framework.org/en'>Documentation</a></p>

<p align='center'><b>Dynamic whitelist with automated rules and Discord integration</b></p>

<hr>

## ✨ Features

- 🎯 Dynamic whitelist control without restarts
- ⏱️ Grace period system before kick
- 🎨 Modern tablet-style UI panel
- 🔍 Auto-detect identifiers (License, Steam, Discord, XBL, FiveM)
- 🤖 Automated rules (player count, admin presence, scheduled)
- 🔔 Discord webhook logs + role verification
- ⚡ Optimized performance (6x faster queries)
- 🔐 Secure with rate limiting & validation

---

## 📦 Installation

1. Extract to `resources/esx_whitelist`
2. Add to `server.cfg`: `ensure esx_whitelist`
3. Configure Discord token in `server/cfg_discord.lua` (optional)
4. Restart server

**Requirements:** ESX Legacy, oxmysql, ox_lib

---

## 🎮 Commands

**In-Game (Admin)**
```
/whitelist          - Open panel
/wl_add [id]       - Add player
/wl_check [id]     - Check status
```

**Console**
```
wl_add [identifier]     - Add by identifier
wl_remove [identifier]  - Remove player
wl_on / wl_off         - Toggle whitelist
```

---

## ⚙️ Configuration

Edit `config.lua`:
```lua
Config.Locale = 'en'
Config.UICommand = 'whitelist'
Config.AdminGroups = { 'admin', 'mod' }
```

Discord token in `server/cfg_discord.lua`:
```lua
Config.DiscordBotToken = "YOUR_BOT_TOKEN"
```

---

## 💬 Support

- [ESX Discord](https://discord.esx-framework.org/)
- [ESX Documentation](https://docs.esx-framework.org/en)

---

<p align='center'><b>Developed by ESX TEAM - Alx</b></p>
<p align='center'>Made with ❤️ for the ESX Community</p>