Locales = {}

function Translate(str, ...) -- Translate string
    local currentLocale = Locales[Config.Locale]
    if not currentLocale then
        print('[^3WARNING^7] Locale [^3' .. Config.Locale .. '^7] does not exist!')
        return str -- Return string key if nothing is found
    end

    local translationFound = currentLocale[str]
    if not translationFound then
        print('[^3WARNING^7] Translation [^3' .. str .. '^7] does not exist!')
        return str -- Return string key if nothing is found
    end

    return (translationFound):format(...)
end

function TranslateCap(str, ...) -- Translate string first char uppercase
	return _(str, ...):gsub("^%l", string.upper)
end

_ = Translate
_U = TranslateCap
