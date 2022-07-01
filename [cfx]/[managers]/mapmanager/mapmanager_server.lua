-- loosely based on MTA's https://code.google.com/p/mtasa-resources/source/browse/trunk/%5Bmanagers%5D/mapmanager/mapmanager_main.lua

local maps = {}
local gametypes = {}

local function refreshResources()
    local numResources = GetNumResources()

    for i = 0, numResources - 1 do
        local resource = GetResourceByFindIndex(i)

        if GetNumResourceMetadata(resource, 'resource_type') > 0 then
            local type = GetResourceMetadata(resource, 'resource_type', 0)
            local params = json.decode(GetResourceMetadata(resource, 'resource_type_extra', 0))
            
            local valid = false
            
            local games = GetNumResourceMetadata(resource, 'game')
            if games > 0 then
				for j = 0, games - 1 do
					local game = GetResourceMetadata(resource, 'game', j)
				
					if game == GetConvar('gamename', 'gta5') or game == 'common' then
						valid = true
					end
				end
            end

			if valid then
				if type == 'map' then
					maps[resource] = params
				elseif type == 'gametype' then
					gametypes[resource] = params
				end
			end
        end
    end
end

AddEventHandler('onResourceListRefresh', function()
    refreshResources()
end)

refreshResources()

AddEventHandler('onResourceStarting', function(resource)
    local num = GetNumResourceMetadata(resource, 'map')

    if num then
        for i = 0, num-1 do
            local file = GetResourceMetadata(resource, 'map', i)

            if file then
                addMap(file, resource)
            end
        end
    end

    if maps[resource] then
        if getCurrentMap() and getCurrentMap() ~= resource then
            if doesMapSupportGameType(getCurrentGameType(), resource) then
                print("Changing map from " .. getCurrentMap() .. " to " .. resource)

                changeMap(resource)
            else
                -- check if there's only one possible game type for the map
                local map = maps[resource]
                local count = 0
                local gt

                for type, flag in pairs(map.gameTypes) do
                    if flag then
                        count = count + 1
                        gt = type
                    end
                end

                if count == 1 then
                    print("Changing map from " .. getCurrentMap() .. " to " .. resource .. " (gt " .. gt .. ")")

                    changeGameType(gt)
                    changeMap(resource)
                end
            end

            CancelEvent()
        end
    elseif gametypes[resource] then
        if getCurrentGameType() and getCurrentGameType() ~= resource then
            print("Changing gametype from " .. getCurrentGameType() .. " to " .. resource)

            changeGameType(resource)

            CancelEvent()
        end
    end
end)

math.randomseed(GetInstanceId())

local currentGameType = nil
local currentMap = nil

AddEventHandler('onResourceStart', function(resource)
    if maps[resource] then
        if not getCurrentGameType() then
            for gt, _ in pairs(maps[resource].gameTypes) do
                changeGameType(gt)
                break
            end
        end

        if getCurrentGameType() and not getCurrentMap() then
            if doesMapSupportGameType(currentGameType, resource) then
                if TriggerEvent('onMapStart', resource, maps[resource]) then
                    if maps[resource].name then
                        print('Started map ' .. maps[resource].name)
                        SetMapName(maps[resource].name)
                    else
                        print('Started map ' .. resource)
                        SetMapName(resource)
                    end

                    currentMap = resource
                else
                    currentMap = nil
                end
            end
        end
    elseif gametypes[resource] then
        if not getCurrentGameType() then
            if TriggerEvent('onGameTypeStart', resource, gametypes[resource]) then
                currentGameType = resource

                local gtName = gametypes[resource].name or resource

                SetGameType(gtName)

                print('Started gametype ' .. gtName)

                SetTimeout(50, function()
                    if not currentMap then
                        local possibleMaps = {}

                        for map, data in pairs(maps) do
                            if data.gameTypes[currentGameType] then
                                table.insert(possibleMaps, map)
                            end
                        end

                        if #possibleMaps > 0 then
                            local rnd = math.random(#possibleMaps)
                            changeMap(possibleMaps[rnd])
                        end
                    end
                end)
            else
                currentGameType = nil
            end
        end
    end

    -- handle starting
    loadMap(resource)
end)

local function handleRoundEnd()
	local possibleMaps = {}

	for map, data in pairs(maps) do
		if data.gameTypes[currentGameType] then
			table.insert(possibleMaps, map)
		end
    end

    if #possibleMaps > 1 then
        local mapname = currentMap

        while mapname == currentMap do
            local rnd = math.random(#possibleMaps)
            mapname = possibleMaps[rnd]
        end

        changeMap(mapname)
    elseif #possibleMaps > 0 then
        local rnd = math.random(#possibleMaps)
        changeMap(possibleMaps[rnd])
	end
end

AddEventHandler('mapmanager:roundEnded', function()
    -- set a timeout as we don't want to return to a dead environment
    SetTimeout(50, handleRoundEnd) -- not a closure as to work around some issue in neolua?
end)

function roundEnded()
    SetTimeout(50, handleRoundEnd)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == currentGameType then
        TriggerEvent('onGameTypeStop', resource)

        currentGameType = nil

        if currentMap then
            StopResource(currentMap)
        end
    elseif resource == currentMap then
        TriggerEvent('onMapStop', resource)

        currentMap = nil
    end

    -- unload the map
    unloadMap(resource)
end)

AddEventHandler('rconCommand', function(commandName, args)
    if commandName == 'map' then
        if #args ~= 1 then
            RconPrint("usage: map [mapname]\n")
        end

        if not maps[args[1]] then
            RconPrint('no such map ' .. args[1] .. "\n")
            CancelEvent()

            return
        end

        if currentGameType == nil or not doesMapSupportGameType(currentGameType, args[1]) then
            local map = maps[args[1]]
            local count = 0
            local gt

            for type, flag in pairs(map.gameTypes) do
                if flag then
                    count = count + 1
                    gt = type
                end
            end

            if count == 1 then
                print("Changing map from " .. getCurrentMap() .. " to " .. args[1] .. " (gt " .. gt .. ")")

                changeGameType(gt)
                changeMap(args[1])

                RconPrint('map ' .. args[1] .. "\n")
            else
                RconPrint('map ' .. args[1] .. ' does not support ' .. currentGameType .. "\n")
            end

            CancelEvent()

            return
        end

        changeMap(args[1])

        RconPrint('map ' .. args[1] .. "\n")

        CancelEvent()
    elseif commandName == 'gametype' then
        if #args ~= 1 then
            RconPrint("usage: gametype [name]\n")
        end

        if not gametypes[args[1]] then
            RconPrint('no such gametype ' .. args[1] .. "\n")
            CancelEvent()

            return
        end

        changeGameType(args[1])

        RconPrint('gametype ' .. args[1] .. "\n")

        CancelEvent()
    end
end)

function getCurrentGameType()
    return currentGameType
end

function getCurrentMap()
    return currentMap
end

function getMaps()
    return maps
end

function changeGameType(gameType)
    if currentMap and not doesMapSupportGameType(gameType, currentMap) then
        StopResource(currentMap)
    end

    if currentGameType then
        StopResource(currentGameType)
    end

    StartResource(gameType)
end

function changeMap(map)
    if currentMap then
        StopResource(currentMap)
    end

    StartResource(map)
end

function doesMapSupportGameType(gameType, map)
    if not gametypes[gameType] then
        return false
    end

    if not maps[map] then
        return false
    end

    if not maps[map].gameTypes then
        return true
    end

    return maps[map].gameTypes[gameType]
end
