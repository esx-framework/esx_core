Locales = {}

function _(str, ...)  -- Translate string
	if not Locales[Config.Locale] then 
		return 'Locale [' .. Config.Locale .. '] does not exist'
	end

	if Locales[Config.Locale][str] then
		return string.format(Locales[Config.Locale][str], ...)
	end
	
	return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub("^%l", string.upper))
end
