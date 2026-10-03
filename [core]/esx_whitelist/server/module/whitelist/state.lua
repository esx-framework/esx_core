-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State = {}

State.config = {
    enabled = false,
    gracePeriod = 60,
    kickConnected = false,
    discordWebhook = "",
    discordBotToken = "",
    discordEnabled = false,
    discordGuildId = "",
    discordRoleId = "",
    -- "identifier" checks the local whitelist database; "discord" checks
    -- the configured Discord role. This is deliberately not a fallback.
    authorizationMethod = "identifier",
    rules = {}
}

State.translations = {}
State.compiledRules = {}
State.playerIdentifiers = {}
State.onlineIdentifierSources = {}
State.whitelistCache = {}
State.gracePlayers = {}
State.adminSources = {}
State.onlineSources = {}
State.onlinePlayerCount = 0
State.onlineAdminCount = 0

State.ruleEvaluationPending = false
State.lastRuleStateChangeAt = 0
State.configError = false
State.configErrorMessage = nil
State.databaseReady = false
State.initializing = false

return State
