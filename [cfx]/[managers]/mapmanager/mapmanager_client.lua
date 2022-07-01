local maps = {}
local gametypes = {}

AddEventHandler('onClientResourceStart', function(res)
    -- parse metadata for this resource

    -- map files
    local num = GetNumResourceMetadata(res, 'map')

    if num > 0 then
        for i = 0, num-1 do
            local file = GetResourceMetadata(res, 'map', i)

            if file then
                addMap(file, res)
            end
        end
    end

    -- resource type data
    local type = GetResourceMetadata(res, 'resource_type', 0)

    if type then
        local extraData = GetResourceMetadata(res, 'resource_type_extra', 0)

        if extraData then
            extraData = json.decode(extraData)
        else
            extraData = {}
        end

        if type == 'map' then
            maps[res] = extraData
        elseif type == 'gametype' then
            gametypes[res] = extraData
        end
    end

    -- handle starting
    loadMap(res)

    -- defer this to the next game tick to work around a lack of dependencies
    Citizen.CreateThread(function()
        Citizen.Wait(15)

        if maps[res] then
            TriggerEvent('onClientMapStart', res)
        elseif gametypes[res] then
            TriggerEvent('onClientGameTypeStart', res)
        end
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if maps[res] then
        TriggerEvent('onClientMapStop', res)
    elseif gametypes[res] then
        TriggerEvent('onClientGameTypeStop', res)
    end

    unloadMap(res)
end)

AddEventHandler('getMapDirectives', function(add)
	if not CreateScriptVehicleGenerator then
		return
	end

    add('vehicle_generator', function(state, name)
        return function(opts)
            local x, y, z, heading
            local color1, color2

            if opts.x then
                x = opts.x
                y = opts.y
                z = opts.z
            else
                x = opts[1]
                y = opts[2]
                z = opts[3]
            end

            heading = opts.heading or 1.0
            color1 = opts.color1 or -1
            color2 = opts.color2 or -1

            CreateThread(function()
                local hash = GetHashKey(name)
                RequestModel(hash)

                while not HasModelLoaded(hash) do
                    Wait(0)
                end

                local carGen = CreateScriptVehicleGenerator(x, y, z, heading, 5.0, 3.0, hash, color1, color2, -1, -1, true, false, false, true, true, -1)
                SetScriptVehicleGenerator(carGen, true)
                SetAllVehicleGeneratorsActive(true)

                state.add('cargen', carGen)
            end)
        end
    end, function(state, arg)
        Citizen.Trace("deleting car gen " .. tostring(state.cargen) .. "\n")

        DeleteScriptVehicleGenerator(state.cargen)
    end)
end)
