local contextMenus = {}
local openContextMenu = nil

local function closeContext(_, cb, onExit)
    if cb then cb(1) end
    if (cb or onExit) and contextMenus[openContextMenu].onExit then contextMenus[openContextMenu].onExit() end
    SetNuiFocus(false, false)
    if not cb then SendNUIMessage({action = 'hideContext'}) end
    openContextMenu = nil
end

function lib.showContext(id)
    if not contextMenus[id] then return error('No context menu of such id found.') end
    local data = contextMenus[id]
    openContextMenu = id
    SetNuiFocus(true, true)
    SendNuiMessage(json.encode({
        action = 'showContext',
        data = {
            title = data.title,
            menu = data.menu,
            options = data.options
        }
    }, { sort_keys = true }))
end

function lib.registerContext(context)
    for k, v in pairs(context) do
        if type(k) == 'number' then
            contextMenus[v.id] = v
        else
            contextMenus[context.id] = context
            break
        end
    end
end

function lib.getOpenContextMenu() return openContextMenu end

function lib.hideContext(onExit) return closeContext(nil, nil, onExit) end

RegisterNUICallback('openContext', function(id, cb)
    cb(1)
    lib.showContext(id)
end)

RegisterNUICallback('clickContext', function(id, cb)
    cb(1)
    if math.type(tonumber(id)) == 'float' then
        id = math.tointeger(id)
    elseif tonumber(id) then
        id += 1
    end
    local data = contextMenus[openContextMenu].options[id]
    if not data.event and not data.serverEvent then return end
    openContextMenu = nil
    SetNuiFocus(false, false)
    if data.event then TriggerEvent(data.event, data.args) end
    if data.serverEvent then TriggerServerEvent(data.serverEvent, data.args) end
    SendNUIMessage({
        action = 'hideContext'
    })
end)

RegisterNUICallback('closeContext', closeContext)
