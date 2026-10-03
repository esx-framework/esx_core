-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class WhitelistConfig
Config = {}

Config.Locale = "en"
Config.Debug = false
Config.UICommand = "whitelist"

Config.AdminGroups = {
    "admin",
    "mod"
}

Config.AdminAcePermissions = {
    "esx_whitelist.admin"
}

Config.AuthorizationIdentifierTypes = {
    "license2",
    "license"
}

-- Anti-flapping cooldown in seconds between automatic rule state transitions
Config.RuleStateChangeCooldown = 60

-- Deferral timeout in milliseconds for identifier authorization mode
Config.IdentifierDeferralTimeout = 5000

-- Discord role verification settings
Config.DiscordCacheTTL = 300
Config.DiscordMaxConcurrentRequests = 8
Config.DiscordMaxQueuedRequests = 2048
Config.DiscordRequestIntervalMs = 25

Config.InGameCommands = true

---@description Console command names for whitelist management.
Config.Commands = {
    Add = "wl_add",
    Remove = "wl_remove",
    Check = "wl_check",
    On = "wl_on",
    Off = "wl_off",
    Sync = "wl_sync",
}

Config.DefaultRules = {
    {
        id = "1",
        type = "admin-presence",
        enabled = false,
        priority = 1,
        operator = "<",
        value = 1,
        action = "enable"
    },
    {
        id = "2",
        type = "player-count",
        enabled = false,
        priority = 2,
        operator = ">",
        value = 32,
        action = "enable"
    },
    {
        id = "3",
        type = "scheduled",
        enabled = false,
        priority = 3,
        startTime = "03:00",
        endTime = "08:00",
        action = "enable"
    }
}
