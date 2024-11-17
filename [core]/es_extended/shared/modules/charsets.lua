Charset = {}
ESX.Charset = {}

function Charset:Init()
    for i = 48, 57 do
        ESX.Charset[#ESX.Charset+1] = string.char(i)
    end
    for i = 65, 90 do
        ESX.Charset[#ESX.Charset+1] = string.char(i)
    end
    for i = 97, 122 do
        ESX.Charset[#ESX.Charset+1] = string.char(i)
    end
end

---@param length number
---@return string
function ESX.GetRandomString(length)
    math.randomseed(GetGameTimer())

    return length > 0 and ESX.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)] or ""
end

CreateThread(function()
    Charset:Init()
end)
