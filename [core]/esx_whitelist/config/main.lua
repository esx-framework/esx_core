-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Config = {}
Config.Locale = GetConvar('esx:locale', 'en')

-- Server-file policy for access credentials. IP identifiers are never accepted.
Config.IdentifierTypes = { license2 = true, license = true, fivem = true }

--[[
    When false, every player is allowed to connect and all
    verification work is skipped.
]]
Config.Whitelist = {
    Enabled = true,

    --[[
        Active verification mechanism(s):
            "discord"    -> Discord guild membership + role only
            "identifier" -> database identifier list only
            "both"       -> identifier + discord, combined via CombinationMode
    ]]
    Mode = 'identifier', -- "discord", "identifier", or "both"

    --[[
        How "both" mode combines the two mechanisms:
            "or"  -> identifier whitelist OR Discord whitelist (recommended)
            "and" -> identifier whitelist AND Discord whitelist
    ]]
    CombinationMode = 'or', -- "or" or "and"

    --[[
        Initial identifier list, imported once into MySQL. Any ONE matching identifier grants
        access.
        Examples:
            "license2:1234567890abcdef1234567890abcdef12345678",
            "license:1234567890abcdef1234567890abcdef1234567890",
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
    GuildId = '',

    -- Role IDs; the member needs at least ONE of them.
    AllowedRoles = {
        -- "123456789012345678",
    },

    -- Per-request HTTP timeout in milliseconds.
    Timeout = 5000,

    -- Verified roles may be reused for at most this many seconds (0 disables reuse).
    CacheTTL = 60,
    CacheMaxEntries = 10000,

    -- Smooth outbound traffic in addition to honoring Discord rate-limit headers.
    RequestsPerSecond = 40,

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
    IdentifierPriority = { 'license2', 'license', 'fivem' },

    Cache = {
        Enabled = true,
        SaveDelay = 5000, -- retained for panel compatibility; administrator decisions are not persisted
    },
}

--[[
    Administrator-only mode. When enabled, ONLY players that match an
    AdminOnly group (after checking the current ESX users record) or an explicit
    AdminOnly identifier may connect; all other mechanisms are skipped.
]]
Config.AdminOnly = {
    Enabled = false,

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
    BatchSize = 5, -- events drained per cycle
    QueueLimit = 250, -- oldest events are dropped beyond this

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
    DiscordConcurrency = 10,

    -- Bounded queue for pending Discord verifications.
    DiscordQueueLimit = 4096,

    -- Hard upper bound (ms) for the whole verification of one connection.
    -- Keeps a slot-scale join burst in the queue instead of failing early.
    VerificationTimeout = 120000,

    -- Client -> server management event rate limit.
    PanelRateLimit = 10, -- actions ...
    PanelRateWindow = 5000, -- ... per window (ms)
}

--[[
    Commands and subcommands for the in-game admin panel and console.
]]
Config.Panel = {
    Command = 'whitelist', -- /whitelist opens the panel (admins only)
    Subcommands = {
        Panel = 'panel',
        Status = 'status',
        Reload = 'reload',
        Cache = 'cache',
        CacheClear = 'clear',
        Test = 'test',
        Add = 'add',
        Remove = 'remove',
    },
}

--[[
    Debugging. When true, extra logs are printed to the server console.
]]
Config.Debug = false
