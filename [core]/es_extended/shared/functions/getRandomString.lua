--- @param length number
function ESX.GetRandomString(length)
    local upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local lowerCase = "abcdefghijklmnopqrstuvwxyz"
    local characterSet = upperCase .. lowerCase
	math.randomseed(GetGameTimer())
    local randomString = ''

    if length <= 0 then return '' end

    for	i = 1, length do
        local rand = math.random(#characterSet)
        randomString = randomString .. string.sub(characterSet, rand, rand)
    end

    return randomString
end