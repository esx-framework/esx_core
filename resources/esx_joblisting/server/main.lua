ESX = nil
local availableJobs = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT name, label FROM jobs WHERE whitelisted = @whitelisted', {
		['@whitelisted'] = false
	}, function(result)
		for i=1, #result, 1 do
			table.insert(availableJobs, {
				job = result[i].name,
				label = result[i].label
			})
		end
	end)
end)

ESX.RegisterServerCallback('esx_joblisting:getJobsList', function(source, cb)
	cb(availableJobs)
end)

RegisterServerEvent('esx_joblisting:setJob')
AddEventHandler('esx_joblisting:setJob', function(job)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer then
		for k,v in ipairs(availableJobs) do
			if v.job == job then
				xPlayer.setJob(job, 0)
				break
			end
		end
	end
end)
