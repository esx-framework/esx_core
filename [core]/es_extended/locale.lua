Locales = {}

function Translate(str, ...) -- Translate string
    if not str then
        error(("Resource ^5%s^1 You did not specify a parameter for the Translate function or the value is nil!"):format(GetInvokingResource() or GetCurrentResourceName()))
    end

    local translations = Locales[Config.Locale]
    if not translations then
        -- Fall back to English translation if the current locale is not found
        if Locales.en and Locales.en[str] then
            return Locales.en[str]:format(...)
        end

        return ("Locale [%s] does not exist"):format(Config.Locale)
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
