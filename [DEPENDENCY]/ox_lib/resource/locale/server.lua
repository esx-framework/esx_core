do
	local locales = {}
	local system = os.getenv('OS')
	local command = system and system:match('Windows') and 'dir "' or 'ls "'
	local path = GetResourcePath(lib.name)
	local types = path:gsub('//', '/') .. '/locales'
	local suffix = command == 'dir "' and '/" /b' or '/"'
	local dir = io.popen(command .. types .. suffix)

	if dir then
		for line in dir:lines() do
			local file = line:gsub('([%a%-]+).json', '%1')
			
			if file then
				locales[#locales+1] = file
			end
		end
		dir:close()
	end

	GlobalState.locales = locales
end

RegisterCommand('serverlocale', function(_, args, _)
	if args?[1] then
		SetResourceKvp('locale', args[1])
		TriggerEvent('ox_lib:setLocale', args[1])
	end
end, true)

function lib.getServerLocale()
	return GetResourceKvpString('locale') or 'en'
end
