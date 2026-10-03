-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Util = {}

---@description Helper function.
function Util.loadLocale(localeName)
    local raw = LoadResourceFile(GetCurrentResourceName(), ("locales/%s.json"):format(localeName))
        or LoadResourceFile(GetCurrentResourceName(), "locales/en.json")
    if not raw then return {} end
    local ok, decoded = pcall(json.decode, raw)
    return ok and type(decoded) == "table" and decoded or {}
end

---@description Helper function.
function Util.translate(translations, key, ...)
    if not translations then return key end
    local template = translations[key] or key
    if select("#", ...) == 0 then return template end
    local ok, result = pcall(string.format, template, ...)
    return ok and result or template
end

return Util
