Locales = {}

--- English fallback for missing keys. locale.lua runs in every resource VM, so
--- a resource may opt out through its own Config.LocaleFallback; otherwise the
--- shared "esx:localeFallback" convar decides (enabled by default).
local function localeFallbackEnabled()
    if Config.LocaleFallback ~= nil then
        return Config.LocaleFallback
    end

    return GetConvar("esx:localeFallback", "true") ~= "false"
end

--- Read and execute a locale file, returning its table or false if unreadable.
local function readLocale(locale)
    local success, result = pcall(function()
        return assert(load(LoadResourceFile(GetCurrentResourceName(), ("locales/%s.lua"):format(locale))))()
    end)

    return success and result or false
end

--- Copy every key the target locale is missing from English into it once, warn
--- about the gaps, then let the English table go. The locale ends up
--- self-contained, so no per-call fallback and only one table stays in memory.
local function backfillFromEnglish(locale, translations)
    local english = readLocale("en")
    if not english then
        return
    end

    local missing = {}
    for key, value in pairs(english) do
        if translations[key] == nil then
            translations[key] = value
            missing[#missing + 1] = key
        end
    end

    if #missing > 0 then
        print(("[es_extended] locale [%s] is missing %d translation(s), falling back to English: %s")
            :format(locale, #missing, table.concat(missing, ", ")))
    end
end

--- Lazily load and cache a locale file, false if it cannot be read.
local function loadLocale(locale)
    if Locales[locale] == nil then
        local translations = readLocale(locale)

        if translations and locale ~= "en" and localeFallbackEnabled() then
            backfillFromEnglish(locale, translations)
        end

        Locales[locale] = translations
    end

    return Locales[locale]
end

function Translate(str, ...) -- Translate string
    if not str then
        error(("Resource ^5%s^1 You did not specify a parameter for the Translate function or the value is nil!"):format(GetInvokingResource() or GetCurrentResourceName()))
    end

    local translations = loadLocale(Config.Locale)
    if not translations then
        if Config.Locale == "en" then
            return "Locale [en] does not exist"
        end

        -- Fall back to English translation if the current locale is not found
        Config.Locale = "en"
        return Translate(str, ...)
    end

    if translations[str] then
        return translations[str]:format(...)
    end

    return ("Translation [%s][%s] does not exist"):format(Config.Locale, str)
end

function TranslateCap(str, ...) -- Translate string first char uppercase
    return (_(str, ...):gsub("^%l", string.upper))
end

_ = Translate
-- luacheck: ignore _U
_U = TranslateCap
