-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Enum = {}

-- Authorization methods
Enum.AuthMethod = {
    DISCORD = 'discord',
    IDENTIFIER = 'identifier',
    ADMIN_GROUP = 'admin_group',
    ADMIN_IDENTIFIER = 'admin_identifier',
    BYPASS = 'bypass',
    DISABLED = 'disabled',
    DENIED = 'denied',
}

-- Stable reason codes.
Enum.Reason = {
    WHITELIST_DISABLED = 'whitelist_disabled',
    BYPASS = 'bypass_identifier',
    ADMIN_ONLY_GRANTED = 'admin_only_granted',
    ADMIN_ONLY_DENIED = 'admin_only_denied',
    ADMIN_GROUP = 'admin_group_allowed',
    IDENTIFIER_MATCH = 'identifier_match',
    IDENTIFIER_NO_MATCH = 'identifier_no_match',
    DISCORD_ALLOWED = 'discord_role_allowed',
    DISCORD_ROLE_MISSING = 'discord_role_missing',
    DISCORD_NOT_IN_GUILD = 'discord_not_in_guild',
    DISCORD_NO_IDENTIFIER = 'discord_no_identifier',
    DISCORD_UNAVAILABLE = 'discord_unavailable',
    DISCORD_MISCONFIGURED = 'discord_misconfigured',
    COMBINATION_UNMET = 'combination_unmet',
    TIMEOUT = 'verification_timeout',
    ERROR = 'internal_error',
}

-- Log severities, filtered through Config.Logging.Levels.
Enum.LogLevel = {
    INFO = 'info',
    WARNING = 'warning',
    ERROR = 'error',
    SECURITY = 'security',
}

return Enum
