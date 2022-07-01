local Core = {
	Ox = 'ox_core',
	QB = 'qb-core',
	ESX = 'es_extended',
}

return function()
	local result

	Citizen.CreateThreadNow(function()
		local framework = GetConvar('framework', '')

		if framework == '' then
			framework = GetResourceState(Core.Ox):find('start') and Core.Ox
			or GetResourceState(Core.QB):find('start') and Core.QB
			or GetResourceState(Core.ESX):find('start') and Core.ESX

			if not framework then
				error('Unable to determine framework (convar is not set, or resource was renamed)')
			end
		end

		local success
		local import
		local resource

		if framework == Core.Ox then
			import = ('imports/%s.lua'):format(lib.service)
			resource = Core.Ox
		else
			import = ('imports/getCore/%s/%s.lua'):format(framework, lib.service)
			resource = lib.name
		end

		success, result = pcall(LoadResourceFile, resource, import)

		if not result then
			error(("Unable to load '@%s/%s'"):format(resource, import))
		end

		if not success then
			error(result and result or ("Unable to load '@%s/%s'"):format(resource, import), 0)
		end

		success, result = load(result, ('@@%s/%s'):format(resource, import))

		if not success then
			error(result, 0)
		end

		success, result = pcall(success, framework)

		if not success then error(result) end

		if framework == Core.Ox then
			result = Ox
		end

		if not result then
			error(('no loader exists for %s'):format(framework))
		elseif type(result) == 'function' then
			result = result(framework)
		end

		result.resource = framework
	end)

	return result
end
