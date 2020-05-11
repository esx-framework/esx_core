ESX.Modules['job_police'] = {};
local self = ESX.Modules['job_police']

-- Properties
self.Config = ESX.EvalFile(GetCurrentResourceName(), 'modules/job_police/data/config.lua', {
  vector3 = vector3
})['Config']

self.GetPriceFromHash = function(vehicleHash, jobGrade, type)

  local authorizedVehicles = {}

  for i=1, jobGrade, 1 do

    local vehicles = self.Config.AuthorizedVehicles[type][i]

    for j=1, #vehicles, 1 do
      authorizedVehicles[#authorizedVehicles + 1] = vehicles[j]
    end

  end

	for k,v in ipairs(authorizedVehicles) do
		if GetHashKey(v.model) == vehicleHash then
			return v.price
		end
	end

  return -1

end
