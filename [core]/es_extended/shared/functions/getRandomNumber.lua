--- @param length number
function ESX.GetRandomNumber(length)
    local numbers = "0123456789"
	math.randomseed(GetGameTimer())
    local randomNumber = ''

    if length <= 0 then return '' end

    for	i = 1, length do
        local rand = math.random(#numbers)
        randomNumber = randomNumber .. string.sub(numbers, rand, rand)
    end

    return tonumber(randomNumber)
end