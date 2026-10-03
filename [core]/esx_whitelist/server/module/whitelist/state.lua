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

-- Bumped whenever configuration or whitelist data changes in a way that can
-- invalidate previously recorded authorization decisions. Sessions record the
-- generation under which they were authorized; stale generations are ignored.
State.authorizationGeneration = 1
State.configError = false
State.configErrorMessage = nil
State.databaseReady = false
State.initializing = false

return State
