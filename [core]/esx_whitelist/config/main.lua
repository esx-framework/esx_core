-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Config = {}

--[[
    When false, every player is allowed to connect and all
    verification work is skipped.
]]
Config.Whitelist = {
    Enabled = true,

    --[[
        Active verification mechanism(s):
            "discord"    -> Discord guild membership + role only
            "identifier" -> static identifier list only
            "both"       -> identifier + discord, combined via CombinationMode
    ]]
    Mode = "discord", -- "discord", "identifier", or "both"

    --[[
        How "both" mode combines the two mechanisms:
            "or"  -> identifier whitelist OR Discord whitelist (recommended)
            "and" -> identifier whitelist AND Discord whitelist
    ]]
    CombinationMode = "or", -- "or" or "and"

    --[[
        Static identifier whitelist. Any ONE matching identifier grants
        access. 
        Examples:
            "license2:1234567890abcdef1234567890abcdef12345678",
            "license:1234567890abcdef1234567890abcdef1234567890",
            "discord:123456789012345678",
            "steam:110000100000000",
    ]]
    AllowedIdentifiers = {},
}

--[[
    Discord role verification.

    The bot token is NOT configured here. Add to server.cfg:
        set discord:botToken "YOUR_DISCORD_BOT_TOKEN"
]]
Config.Discord = {
    -- When true, Discord verification is performed. If false, Discord verification is skipped.
    Enabled = false,

    -- Discord guild (server) ID the player must be a member of.
    GuildId = "",

    -- Role IDs; the member needs at least ONE of them.
    AllowedRoles = {
        --"123456789012345678",
    },

    -- Per-request HTTP timeout in milliseconds.
    Timeout = 5000,

    -- How long (seconds) a POSITIVE result (member with role) is cached.
    CacheDuration = 300,

    -- How long (seconds) a NEGATIVE result (deny / not in guild) is cached.
    -- Short on purpose: players who just received a role should not wait long.
    NegativeCacheDuration = 60,

    -- Retry policy for transient failures (timeout, 5xx, network errors).
    MaxRetries = 2,
    RetryBaseDelay = 750, -- ms, doubled after each failed attempt (max RetryMaxDelay)
    RetryMaxDelay = 4000, -- ms
}

Config.Admin = {
    -- Groups treated as administrators for whitelist purposes.
    Groups = {
        admin = true,
        superadmin = true,
        owner = true,
    },

    --[[
        Ordered preference for the stable identifier used as cache key.
        The first identifier type present for the player wins.
    ]]
    IdentifierPriority = { "license2", "license", "fivem" },

    -- Persistent cache behavior (stored at data/admin_cache.json).
    Cache = {
        Enabled = true,
        Expiry = 2592000, -- seconds an entry stays valid (30 days)
        SaveDelay = 5000, -- ms debounce before dirty entries hit the disk
    },
}

--[[
    Administrator-only mode. When enabled, ONLY players that match an
    AdminOnly group (via the persistent admin cache) or an explicit
    AdminOnly identifier may connect; all other mechanisms are skipped.
]]
Config.AdminOnly = {
    Enabled = true,

    Groups = {
        admin = true,
        superadmin = true,
        owner = true,
    },

    -- Explicit identifiers that may connect while admin-only mode is on.
    -- Use this to guarantee access for head admins even with a cold cache.
    AllowedIdentifiers = {
        -- "license2:...",
    },
}

--[[
    Emergency bypass. Evaluated before everything else, including
    admin-only mode. Keep this list tiny and secret.
]]
Config.Bypass = {
    AllowedIdentifiers = {
        -- "license2:...",
    },
}

--[[
    Discord webhook logging (optional).

    The webhook is NOT configured here. Add to server.cfg:
        set whitelist:webhook "https://discord.com/api/webhooks/..."
]]
Config.Logging = {
    Enabled = true,

    MinInterval = 1200, -- ms between webhook requests
    BatchSize = 5,      -- events drained per cycle
    QueueLimit = 250,   -- oldest events are dropped beyond this

    -- Which event severities are sent: "info", "warning", "error", "security"
    Levels = {
        info = true,
        warning = true,
        error = true,
        security = true,
    },
}

Config.Performance = {
    -- Max simultaneous outbound Discord API requests.
    DiscordConcurrency = 5,

    -- Bounded queue for pending Discord verifications.
    DiscordQueueLimit = 512,

    -- Hard upper bound (ms) for the whole verification of one connection.
    -- Players are never left hanging in deferrals longer than this.
    VerificationTimeout = 10000,

    -- Client -> server management event rate limit.
    PanelRateLimit = 10,     -- actions ...
    PanelRateWindow = 5000,  -- ... per window (ms)
}

--[[
    In-game panel.
]]
Config.Panel = {
    Command = "whitelist", -- /whitelist opens the panel (admins only)
}

--[[
    Debugging. When true, extra logs are printed to the server console.
]]
Config.Debug = false
