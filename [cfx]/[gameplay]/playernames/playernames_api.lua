local ids = {}

local function getTriggerFunction(key)
    return function(id, ...)
        -- if on the client, it's easy
        if not IsDuplicityVersion() then
            TriggerEvent('playernames:configure', GetPlayerServerId(id), key, ...)
        else
            -- if on the server, save configuration
            if not ids[id] then
                ids[id] = {}
            end

            -- save the setting
            ids[id][key] = table.pack(...)

            -- broadcast to clients
            TriggerClientEvent('playernames:configure', -1, id, key, ...)
        end
    end
end

if IsDuplicityVersion() then
    function reconfigure(source)
        for id, data in pairs(ids) do
            for key, args in pairs(data) do
                TriggerClientEvent('playernames:configure', source, id, key, table.unpack(args))
            end
        end
    end

    AddEventHandler('playerDropped', function()
        ids[source] = nil
    end)
end

setComponentColor = getTriggerFunction('setc')
setComponentAlpha = getTriggerFunction('seta')
setComponentVisibility = getTriggerFunction('tglc')
setWantedLevel = getTriggerFunction('setw')
setHealthBarColor = getTriggerFunction('sehc')
setNameTemplate = getTriggerFunction('tpl')
setName = getTriggerFunction('name')

if not io then
    io = { write = nil, open = nil }
end

local template = load(LoadResourceFile(GetCurrentResourceName(), 'template/template.lua'))()

function formatPlayerNameTag(i, templateStr)
    --return ('%s &lt;%d&gt;'):format(GetPlayerName(i), GetPlayerServerId(i))
    local str = ''

    template.print = function(txt)
        str = str .. txt
    end

    local context = {
        name = GetPlayerName(i),
        i = i,
        global = _G
    }

    if IsDuplicityVersion() then
        context.id = i
    else
        context.id = GetPlayerServerId(i)
    end

    TriggerEvent('playernames:extendContext', i, function(k, v)
        context[k] = v
    end)

    template.render(templateStr, context, nil, true)

    template.print = print

    return str
end