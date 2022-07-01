local key = GetConvar('datadog:key', '')

if key ~= '' then
	local site = ('https://http-intake.logs.%s/api/v2/logs'):format(GetConvar('datadog:site', 'datadoghq.com'))
	local resourceName = GetCurrentResourceName()
	key = key:gsub("[\'\"]", '')

	return function(source, event, message, ...)
		local data = json.encode({
			hostname = resourceName,
			service = event,
			message = message,
			ddsource = tostring(source),
			ddtags = string.strjoin(',', string.tostringall(...))
		})

		PerformHttpRequest(site, function(status, _, _, response)
			if status ~= 202 then
				-- Thanks, I hate it
				response = json.decode(response:sub(10)).errors[1]
				print(('unable to submit logs to %s\n%s'):format(site, json.encode(response, {indent=true})))
			end
		end, 'POST', data, {
			['Content-Type'] = 'application/json',
			['DD-API-KEY'] = key
		})
	end
end

return function() end
