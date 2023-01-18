local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
	math.randomseed(GetGameTimer())

	local generatedPlate = string.upper(GetRandomLetter(Config.PlateLetters) .. (Config.PlateUseSpace and ' ' or '') .. GetRandomNumber(Config.PlateNumbers))

	local isTaken = IsPlateTaken(generatedPlate)
	if isTaken then 
		return GeneratePlate()
	end

	return generatedPlate
end

-- mixing async with sync tasks
function IsPlateTaken(plate)
	local p = promise.new()
	
	ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function(isPlateTaken)
		p:resolve(isPlateTaken)
	end, plate)

	return Citizen.Await(p)
end

function GetRandomNumber(length)
	Wait(0)
	return length > 0 and GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)] or ''
end

function GetRandomLetter(length)
	Wait(0)
	return length > 0 and GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)] or ''
end
