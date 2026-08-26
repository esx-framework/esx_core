local SELF = GetCurrentResourceName()

local function isESXResource(name)
    if name:find('^esx_') or name:find('^es_') then
        return true
    end

    local count = GetNumResourceMetadata(name, 'dependency')

    for i = 0, count - 1 do
        local dependency = GetResourceMetadata(name, 'dependency', i)

        if dependency == 'es_extended' or dependency == 'esx_lib' then
            return true
        end
    end

    return false
end

local function exposeVersion(name)
    local version = GetResourceMetadata(name, 'version', 0)
    local legacyVersion = GetResourceMetadata(name, 'legacyversion', 0)

    local hasVersion = version and version ~= ''
    local hasLegacyVersion = legacyVersion and legacyVersion ~= ''

    if not hasVersion and not hasLegacyVersion then
        return
    end

    local value

    if hasVersion and hasLegacyVersion then
        value = ('{ legacyVersion: %s, version: %s }'):format(
            legacyVersion,
            version
        )
    else
        value = hasVersion and version or legacyVersion
    end

    SetConvarServerInfo(name .. '-version', value)
end

CreateThread(function()
    Wait(2000)

    for i = 0, GetNumResources() - 1 do
        local name = GetResourceByFindIndex(i)

        if name and isESXResource(name) then
            exposeVersion(name)
        end
    end
    exposeVersion(SELF)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == SELF then
        return
    end

    if isESXResource(resourceName) then
        exposeVersion(resourceName)
    end
end)