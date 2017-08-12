Locales = {}

function _(str, ...)	-- Translate string
	return string.format(Locales[Config.Locale][str], ...)
end

function _U(str, ...) -- Translate string first char uppercase
  return tostring(_(str, ...):gsub("^%l", string.upper))
end
