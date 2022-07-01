function lib.checkDependency(resource, minimumVersion, printMessage)
	local currentVersion = GetResourceMetadata(resource, 'version', 0):match('%d%.%d+%.%d+')

	if currentVersion < minimumVersion then
		local msg = ("^1%s requires version '%s' of '%s' (current version: %s)^0"):format(GetInvokingResource() or GetCurrentResourceName(), minimumVersion, resource, currentVersion)

		if printMessage then
			return print(msg)
		end

		return false, msg
	end

	return true
end
