local availableJobs = {}

for k,v in pairs(ESX.Jobs) do 
	print(v.whitelisted)
	if v.whitelisted == false then 
		availableJobs[k] = {label = v.label}
	end
end

ESX.RegisterServerCallback('esx_joblisting:getJobsList', function(source, cb)
	cb(availableJobs)
end)

function IsNearCentre(player)
	local Ped = GetPlayerPed(player)
	local PedCoords = GetEntityCoords(Ped)
	local Zones = Config.Zones

	for i=1, #Config.Zones, 1 do
		local distance = #(PedCoords - Config.Zones[i])

		if distance < Config.DrawDistance then
			return true
		end
	end
end

RegisterServerEvent('esx_joblisting:setJob')
AddEventHandler('esx_joblisting:setJob', function(job)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer and IsNearCentre(source) then
		if availableJobs[job] then
			xPlayer.setJob(job, 0)
		end
	end
end)
