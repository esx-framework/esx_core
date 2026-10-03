-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local State <const> = xLib.require "@esx_whitelist.server.module.whitelist.state"
local ConfigService <const> = xLib.require "@esx_whitelist.server.module.whitelist.config"

---@class Rules
---@description Evaluates automatic whitelist rules by priority and applies state changes when conditions are met.
local Rules = {}

---@description Evaluates all compiled rules and returns the desired whitelist state.
---@return boolean desiredState
function Rules.evaluate()
    local currentTime = os.date("*t")
    local currentMinutes = (tonumber(currentTime.hour) or 0) * 60 + (tonumber(currentTime.min) or 0)
    for i = 1, #(State.compiledRules or {}) do
        local applicable, desired = State.compiledRules[i]:evaluate(
            State.onlinePlayerCount,
            State.onlineAdminCount,
            currentMinutes
        )
        if applicable and desired ~= nil then return desired end
    end
    return State.config.enabled
end

---@description Evaluates rules and applies state changes if conditions are met.
---@param onChanged fun(newState: boolean)
---@return boolean changed
function Rules.evaluateAndApply(onChanged)
    if State.ruleEvaluationPending then return false end

    local newState = Rules.evaluate()
    local changed = newState ~= State.config.enabled
    if not changed then return false end

    local cooldownMs = math.max(10, math.floor(tonumber(Config.RuleStateChangeCooldown) or 60)) * 1000
    local now = GetGameTimer()
    if State.lastRuleStateChangeAt and State.lastRuleStateChangeAt > 0 and (now - State.lastRuleStateChangeAt) < cooldownMs then
        if Config.Debug then
            print(("^3[esx_whitelist] Automatic state change suppressed by anti-flapping cooldown (%d ms remaining).^7"):format(
                cooldownMs - (now - State.lastRuleStateChangeAt)
            ))
        end
        return false
    end

    State.ruleEvaluationPending = true

    local ok, err = ConfigService.setEnabled(newState)
    if not ok then
        if Config.Debug then
            print(("^1[esx_whitelist] Automatic state save failed (%s); keeping current state.^7"):format(err or "unknown error"))
        end
        State.ruleEvaluationPending = false
        return false
    end

    State.lastRuleStateChangeAt = math.max(1, now)
    if onChanged then onChanged(newState, false, nil) end

    SetTimeout(1000, function()
        State.ruleEvaluationPending = false
    end)
    return true
end

return Rules
