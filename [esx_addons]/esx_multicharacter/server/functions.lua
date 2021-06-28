GetJobs = function()
	local jobs = {}
	while next(jobs) == nil do
		Citizen.Wait(250)
		jobs = exports['es_extended']:getSharedObject().Jobs
	end
	return jobs
end