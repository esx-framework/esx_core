Locales = {}

function _(str, ...)  -- Translate string

  if Locales[Config.Locale] ~= nil then

    if Locales[Config.Locale][str] ~= nil then
      return string.format(Locales[Config.Locale][str], ...)
    else
      return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exists'
    end

  else
    return 'Locale [' .. Config.Locale .. '] does not exists'
  end

end

function _U(str, ...) -- Translate string first char uppercase
  return tostring(_(str, ...):gsub("^%l", string.upper))
end
