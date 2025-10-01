Locales = {}

function Translate(str, ...) -- Translate string
    if not str then
        error(("Resource ^5%s^1 You did not specify a parameter for the Translate function or the value is nil!"):format(GetInvokingResource() or GetCurrentResourceName()))
    end

    --- Load the locale file if it hasn't been loaded yet
    if Locales[Config.Locale] == nil then
        local success, result = pcall(function()
            return assert(load(LoadResourceFile(GetCurrentResourceName(), ("locales/%s.lua"):format(Config.Locale))))()
        end)

        Locales[Config.Locale] = success and result or false
    end

    local translations = Locales[Config.Locale]
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
    return _(str, ...):gsub("^%l", string.upper)
end

_ = Translate
-- luacheck: ignore _U
_U = TranslateCap