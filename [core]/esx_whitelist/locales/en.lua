-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

return {
    ["whitelist_title"] = "Whitelist",

    ["admin_only"] = "This server is currently restricted to administrators.",
    ["not_whitelisted"] = "You are not whitelisted on this server.",
    ["discord_required"] = "A linked Discord account is required to join this server.",
    ["discord_role_required"] = "You lack the required Discord role to join this server.",
    ["discord_server_required"] = "You must be a member of our Discord server to join.",
    ["discord_unavailable"] = "Verification is temporarily unavailable. Please try again shortly.",
    ["verification_timeout"] = "Verification timed out. Please try again.",
    ["verification_error"] = "An internal error occurred during verification. Please try again.",

    ["checking_whitelist"] = "Checking whitelist...",
    ["checking_discord_membership"] = "Checking Discord membership...",
    ["verifying_authorization"] = "Verifying authorization...",

    ["command_no_permission"] = "You do not have permission to use this command.",
    ["command_usage"] = "Usage: whitelist [panel|status|reload|cache [clear]|test <id>]",
    ["command_usage_test"] = "Usage: whitelist test <serverId>",
    ["panel_only_in_game"] = "The panel can only be opened in-game.",
    ["runtime_reloaded"] = "Runtime configuration reloaded.",
    ["runtime_reloaded_fallback"] = "Runtime configuration file was corrupted; defaults restored.",
    ["discord_cache_cleared"] = "Discord verification cache cleared.",
    ["no_online_player"] = "No online player with server id %d.",
    ["player_left_before_check"] = "Player left before the check completed.",
    ["command_status"] = "Whitelist: %s | mode=%s (%s) | admin-only=%s",
    ["command_status_discord"] = "Discord: %s | requests=%d cacheHits=%d shared=%d rateLimits=%d errors=%d",
    ["command_status_decisions"] = "Decisions: total=%d allowed=%d denied=%d | adminCache=%d entries",
    ["command_cache_stats"] = "Discord cache: %d entries | admin cache: %d entries | queue: %d (active %d)",
    ["command_test_result"] = "Test for %s [%d]: %s | method=%s | reason=%s | identifier=%s",
    ["command_status_format"] = "Whitelist: %s | mode=%s (%s) | admin-only=%s",
}
