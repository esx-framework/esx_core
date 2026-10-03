-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Enum = {}

Enum.IdentifierType = {
    STEAM = "steam",
    LICENSE = "license",
    LICENSE2 = "license2",
    DISCORD = "discord",
    XBL = "xbl",
    FIVEM = "fivem"
}

Enum.RuleType = {
    ADMIN_PRESENCE = "admin-presence",
    PLAYER_COUNT = "player-count",
    SCHEDULED = "scheduled"
}

Enum.RuleOperator = {
    LESS_THAN = "<",
    GREATER_THAN = ">",
    LESS_OR_EQUAL = "<=",
    GREATER_OR_EQUAL = ">=",
    EQUALS = "=="
}

Enum.RuleAction = {
    ENABLE = "enable",
    DISABLE = "disable"
}

Enum.DiscordEmbedColor = {
    SUCCESS = 3066993,
    DANGER = 15158332,
    PRIMARY = 3447003
}

return Enum
