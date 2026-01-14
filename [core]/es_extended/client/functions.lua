---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
function ESX.IsPlayerLoaded()
    return ESX.PlayerLoaded
end

---@return table
function ESX.GetPlayerData()
    return ESX.PlayerData
end

---@param name string
---@param func function
---@return nil
function ESX.SecureNetEvent(name, func)
    local invoker = GetInvokingResource()
    local invokingResource = invoker and invoker ~= 'unknown' and invoker or 'es_extended'
    if not invokingResource then
        return
    end

    if not Core.Events[invokingResource] then
        Core.Events[invokingResource] = {}
    end

    local event = RegisterNetEvent(name, function(...)
        if source == '' then
            return
        end

        local success, result = pcall(func, ...)
        if not success then
            error(("%s"):format(result))
        end
    end)
    local eventIndex = #Core.Events[invokingResource] + 1
    Core.Events[invokingResource][eventIndex] = event
end

local addonResourcesState = {
    ['esx_progressbar'] = GetResourceState('esx_progressbar') ~= 'missing',
    ['esx_notify'] = GetResourceState('esx_notify') ~= 'missing',
    ['esx_textui'] = GetResourceState('esx_textui') ~= 'missing',
    ['esx_context'] = GetResourceState('esx_context') ~= 'missing',
}

local function IsResourceFound(resource)
	return addonResourcesState[resource] or error(('Resource [^5%s^1] is Missing!'):format(resource))
end

function ESX.DisableSpawnManager()
    if GetResourceState("spawnmanager") == "started" then
        exports.spawnmanager:setAutoSpawn(false)
    end
end

---@param items string | table The item(s) to search for
---@param count? boolean Whether to return the count of the item as well
---@return table | number
function ESX.SearchInventory(items, count)
    local item
    if type(items) == 'string' then
        item, items = items, {items}
    end

    local data = {}
    for i = 1, #ESX.PlayerData.inventory do
        local e = ESX.PlayerData.inventory[i]
        for ii = 1, #items do
            if e.name == items[ii] then
                data[table.remove(items, ii)] = count and e.count or e
                break
            end
        end
        if #items == 0 then
            break
        end
    end

    return not item and data or data[item]
end

---@param key string Table key to set
---@param val any Value to set
---@return nil
function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val
    if key ~= "loadout" then
        if type(val) == "table" or val ~= current then
            TriggerEvent("esx:setPlayerData", key, val, current)
        end
    end
end

---@param freeze boolean Whether to freeze the player
---@return nil
function Core.FreezePlayer(freeze)
    local ped = PlayerPedId()
    SetPlayerControl(ESX.playerId, not freeze, 0)

    if freeze then
        SetEntityCollision(ped, false, false)
        FreezeEntityPosition(ped, true)
    else
        SetEntityCollision(ped, true, true)
        FreezeEntityPosition(ped, false)
    end
end

---@param skin table Skin data to set
---@param coords table Coords to spawn the player at
---@param cb function Callback function
---@return nil
function ESX.SpawnPlayer(skin, coords, cb)
    local p = promise.new()
    TriggerEvent("skinchanger:loadSkin", skin, function()
        p:resolve()
    end)
    Citizen.Await(p)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    local playerPed = PlayerPedId()
    local timer = GetGameTimer()

    Core.FreezePlayer(true)
    SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z, false, false, true)
    SetEntityHeading(playerPed, coords.heading)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(playerPed) and (GetGameTimer() - timer) < 5000 do
        Wait(0)
    end

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, 0, true)
    TriggerEvent('playerSpawned', coords)
    cb()
end

---@param message string
---@param length? number Timeout in milliseconds
---@param options? ProgressBarOptions
---@return boolean Success Whether the progress bar was successfully created or not
function ESX.Progressbar(message, length, options)
	return IsResourceFound('esx_progressbar') and exports['esx_progressbar']:Progressbar(message, length, options)
end

function ESX.CancelProgressbar()
    return IsResourceFound('esx_progressbar') and exports['esx_progressbar']:CancelProgressbar()
end

---@param message string The message to show
---@param notifyType? string The type of notification to show
---@param length? number The length of the notification
---@param title? string The title of the notification
---@return nil
function ESX.ShowNotification(message, notifyType, length, title)
	return IsResourceFound('esx_notify') and exports['esx_notify']:Notify(notifyType, length, message, title)
end

function ESX.TextUI(...)
	return IsResourceFound('esx_textui') and exports['esx_textui']:TextUI(...)
end

---@return nil
function ESX.HideUI()
	return IsResourceFound('esx_textui') and exports['esx_textui']:HideUI()
end

---@param sender string
---@param subject string
---@param msg string
---@param textureDict string
---@param iconType integer
---@param flash boolean
---@param saveToBrief? boolean
---@param hudColorIndex? integer
---@return nil
function ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    AddTextEntry("esxAdvancedNotification", msg)
    BeginTextCommandThefeedPost("esxAdvancedNotification")
    if hudColorIndex then
        ThefeedSetNextPostBackgroundColor(hudColorIndex)
    end
    EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
    EndTextCommandThefeedPostTicker(flash, saveToBrief == nil or saveToBrief)
end

---@param msg string The message to show
---@param thisFrame? boolean Whether to show the message this frame
---@param beep? boolean Whether to beep
---@param duration? number The duration of the message
---@return nil
function ESX.ShowHelpNotification(msg, thisFrame, beep, duration)
    AddTextEntry("esxHelpNotification", msg)
    if thisFrame then
        DisplayHelpTextThisFrame("esxHelpNotification", false)
    else
        BeginTextCommandDisplayHelp("esxHelpNotification")
        EndTextCommandDisplayHelp(0, false, beep == nil or beep, duration or -1)
    end
end

---@param msg string The message to show
---@param coords table The coords to show the message at
---@return nil
function ESX.ShowFloatingHelpNotification(msg, coords)
    AddTextEntry("esxFloatingHelpNotification", msg)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp("esxFloatingHelpNotification")
    EndTextCommandDisplayHelp(2, false, false, -1)
end

---@param msg string The message to show
---@param time number The duration of the message
---@return nil
function ESX.DrawMissionText(msg, time)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, true)
end

---@param str string The string to hash
---@return string The hashed string
function ESX.HashString(str)
    return ('~INPUT_%s~'):format(('%x'):format(joaat(str) & 0x7fffffff + 2 ^ 31):upper())
end

function ESX.OpenContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Open(...)
end

function ESX.PreviewContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Preview(...)
end

function ESX.CloseContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Close(...)
end

function ESX.RefreshContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Refresh(...)
end

---@param menuType string
---@param open function The function to call on open
---@param close function The function to call on close
function ESX.UI.Menu.RegisterType(menuType, open, close)
    ESX.UI.Menu.RegisteredTypes[menuType] = {
        open = open,
        close = close,
    }
end

---@class ESXMenu
---@field type string
---@field namespace string
---@field resourceName string
---@field name string
---@field data table
---@field submit? function
---@field cancel? function
---@field change? function
---@field close function
---@field update function
---@field refresh function
---@field setElement function
---@field setElements function
---@field setTitle function
---@field removeElement function

---@param menuType string
---@param namespace string
---@param name string
---@param data table
---@param submit? function
---@param cancel? function
---@param change? function
---@param close? function
---@return ESXMenu
function ESX.UI.Menu.Open(menuType, namespace, name, data, submit, cancel, change, close)
    ---@class ESXMenu
    local menu = {}

    menu.type = menuType
    menu.namespace = namespace
    menu.resourceName = (GetInvokingResource() or "Unknown")
    menu.name = name
    menu.data = data
    menu.submit = submit
    menu.cancel = cancel
    menu.change = change

    menu.close = function()
        ESX.UI.Menu.RegisteredTypes[menuType].close(namespace, name)

        for i = 1, #ESX.UI.Menu.Opened, 1 do
            if ESX.UI.Menu.Opened[i] then
                if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
                    ESX.UI.Menu.Opened[i] = nil
                end
            end
        end

        if close then
            close()
        end
    end

    menu.update = function(query, newData)
        for i = 1, #menu.data.elements, 1 do
            local match = true

            for k, v in pairs(query) do
                if menu.data.elements[i][k] ~= v then
                    match = false
                end
            end

            if match then
                for k, v in pairs(newData) do
                    menu.data.elements[i][k] = v
                end
            end
        end
    end

    menu.refresh = function()
        ESX.UI.Menu.RegisteredTypes[menuType].open(namespace, name, menu.data)
    end

    menu.setElement = function(i, key, val)
        menu.data.elements[i][key] = val
    end

    menu.setElements = function(newElements)
        menu.data.elements = newElements
    end

    menu.setTitle = function(val)
        menu.data.title = val
    end

    menu.removeElement = function(query)
        for i = 1, #menu.data.elements, 1 do
            for k, v in pairs(query) do
                if menu.data.elements[i] then
                    if menu.data.elements[i][k] == v then
                        table.remove(menu.data.elements, i)
                        break
                    end
                end
            end
        end
    end

    ESX.UI.Menu.Opened[#ESX.UI.Menu.Opened + 1] = menu
    ESX.UI.Menu.RegisteredTypes[menuType].open(namespace, name, data)

    return menu
end

---@param menuType string
---@param namespace string
---@param name string
---@param cancel? boolean Should the close be classified as a cancel
---@return nil
function ESX.UI.Menu.Close(menuType, namespace, name, cancel)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
                if not cancel then
                    ESX.UI.Menu.Opened[i].close()
                else
                    local menu = ESX.UI.Menu.Opened[i]
                    ESX.UI.Menu.RegisteredTypes[menu.type].close(menu.namespace, menu.name)

                    if type(menu.cancel) ~= "nil" then
                        menu.cancel(menu.data, menu)
                    end
                end
                ESX.UI.Menu.Opened[i] = nil
            end
        end
    end
end

---@param cancel? boolean Should the close be classified as a cancel
---@return nil
function ESX.UI.Menu.CloseAll(cancel)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if not cancel then
                ESX.UI.Menu.Opened[i].close()
            else
                local menu = ESX.UI.Menu.Opened[i]
                ESX.UI.Menu.RegisteredTypes[menu.type].close(menu.namespace, menu.name)

                if type(menu.cancel) ~= "nil" then
                    menu.cancel(menu.data, menu)
                end
            end
            ESX.UI.Menu.Opened[i] = nil
        end
    end
end

---@param menuType string
---@param namespace string
---@param name string
---@return ESXMenu | nil
function ESX.UI.Menu.GetOpened(menuType, namespace, name)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].type == menuType and ESX.UI.Menu.Opened[i].namespace == namespace and ESX.UI.Menu.Opened[i].name == name then
                return ESX.UI.Menu.Opened[i]
            end
        end
    end
end

---@return ESXMenu[]
function ESX.UI.Menu.GetOpenedMenus()
    return ESX.UI.Menu.Opened
end

ESX.UI.Menu.IsOpen = ESX.UI.Menu.GetOpened

---@param add boolean Whether the item is being added or removed
---@param item string The item to show
---@param count number How many of the item to show
---@return nil
function ESX.UI.ShowInventoryItemNotification(add, item, count)
    SendNUIMessage({
        action = "inventoryNotification",
        add = add,
        item = item,
        count = count,
    })
end

---@param ped integer The ped to get the mugshot of
---@param transparent? boolean Whether the mugshot should be transparent
function ESX.Game.GetPedMugshot(ped, transparent)
    if not DoesEntityExist(ped) then
        return
    end
    local mugshot = transparent and RegisterPedheadshotTransparent(ped) or RegisterPedheadshot(ped)

    while not IsPedheadshotReady(mugshot) do
        Wait(0)
    end

    return mugshot, GetPedheadshotTxdString(mugshot)
end

---@param object integer | string The object to spawn
---@param coords table | vector3 The coords to spawn the object at
---@param cb? function The callback function
---@param networked? boolean Whether the object should be networked
---@return integer | nil
function ESX.Game.SpawnObject(object, coords, cb, networked)
    local model = type(object) == "number" and object or joaat(object)

    ESX.Streaming.RequestModel(model)

	local obj = CreateObject(model, coords.x, coords.y, coords.z, networked == nil or networked, false, true)
	return cb and cb(obj) or obj
end

---@param object integer | string The object to spawn
---@param coords table | vector3 The coords to spawn the object at
---@param cb? function The callback function
---@return nil
function ESX.Game.SpawnLocalObject(object, coords, cb)
    ESX.Game.SpawnObject(object, coords, cb, false)
end

---@param object integer The object to delete
---@return nil
function ESX.Game.DeleteObject(object)
    SetEntityAsMissionEntity(object, false, true)
    DeleteObject(object)
end

---@return table
function ESX.Game.GetObjects() -- Leave the function for compatibility
    return GetGamePool("CObject")
end

---@param onlyOtherPeds? boolean Whether to exlude the player ped
---@return table
function ESX.Game.GetPeds(onlyOtherPeds)
    local pool = GetGamePool("CPed")

    if onlyOtherPeds then
        local myPed = ESX.PlayerData.ped
        for i = 1, #pool do
            if pool[i] == myPed then
                table.remove(pool, i)
                break
            end
        end
    end

    return pool
end

---@return table
function ESX.Game.GetVehicles() -- Leave the function for compatibility
    return GetGamePool("CVehicle")
end

---@param onlyOtherPlayers? boolean Whether to exclude the player
---@param returnKeyValue? boolean Whether to return the key value pair
---@param returnPeds? boolean Whether to return the peds
---@return table
function ESX.Game.GetPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players = {}
    local active = GetActivePlayers()

    for i = 1, #active do
        local currentPlayer = active[i]
        local ped = GetPlayerPed(currentPlayer)

        if DoesEntityExist(ped) and ((onlyOtherPlayers and currentPlayer ~= ESX.playerId) or not onlyOtherPlayers) then
            if returnKeyValue then
                players[currentPlayer] = ped
            else
                players[#players + 1] = returnPeds and ped or currentPlayer
            end
        end
    end

    return players
end

---@param coords? table | vector3 The coords to get the closest object to
---@param modelFilter? table The model filter
---@return integer, integer
function ESX.Game.GetClosestObject(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetObjects(), false, coords, modelFilter)
end

---@param coords? table | vector3 The coords to get the closest ped to
---@param modelFilter? table The model filter
---@return integer, integer
function ESX.Game.GetClosestPed(coords, modelFilter)
    return ESX.Game.GetClosestEntity(ESX.Game.GetPeds(true), false, coords, modelFilter)
end

---@param coords? table | vector3 The coords to get the closest player to
---@return integer, integer
function ESX.Game.GetClosestPlayer(coords)
    return ESX.Game.GetClosestEntity(ESX.Game.GetPlayers(true, true), true, coords, nil)
end

---@param coords table | vector3 The coords to search from
---@param maxDistance number The max distance to search within
---@return table
function ESX.Game.GetPlayersInArea(coords, maxDistance)
    return EnumerateEntitiesWithinDistance(ESX.Game.GetPlayers(true, true), true, coords, maxDistance)
end

---@param coords vector3 | table coords to get the closest pickup to
---@param text string The text to display
---@param size? number The size of the text
---@param font? number The font of the text
---@return nil
function ESX.Game.Utils.DrawText3D(coords, text, size, font)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)

    local camCoords = GetFinalRenderedCamCoord()
    local distance = #(vector - camCoords)

    size = size or 1
    font = font or 0

    local scale = (size / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(font)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(vector.x, vector.y, vector.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

---@param account string Account name (money/bank/black_money)
---@return table|nil
function ESX.GetAccount(account)
    for i = 1, #ESX.PlayerData.accounts, 1 do
        if ESX.PlayerData.accounts[i].name == account then
            return ESX.PlayerData.accounts[i]
        end
    end
    return nil
end

function ESX.ShowInventory()
    if not Config.EnableDefaultInventory then
        return
    end

    exports.esx_inventory:ShowInventory()
end

RegisterNetEvent('esx:showNotification', ESX.ShowNotification)

RegisterNetEvent('esx:showAdvancedNotification', ESX.ShowAdvancedNotification)

RegisterNetEvent('esx:showHelpNotification', ESX.ShowHelpNotification)

AddEventHandler("onResourceStop", function(resourceName)
    for i = 1, #ESX.UI.Menu.Opened, 1 do
        if ESX.UI.Menu.Opened[i] then
            if ESX.UI.Menu.Opened[i].resourceName == resourceName or ESX.UI.Menu.Opened[i].namespace == resourceName then
                ESX.UI.Menu.Opened[i].close()
                ESX.UI.Menu.Opened[i] = nil
            end
        end
    end
end)
-- Credits to txAdmin for the list.
local mismatchedTypes = {
    [`airtug`] = "automobile", -- trailer
    [`avisa`] = "submarine", -- boat
    [`blimp`] = "heli", -- plane
    [`blimp2`] = "heli", -- plane
    [`blimp3`] = "heli", -- plane
    [`caddy`] = "automobile", -- trailer
    [`caddy2`] = "automobile", -- trailer
    [`caddy3`] = "automobile", -- trailer
    [`chimera`] = "automobile", -- bike
    [`docktug`] = "automobile", -- trailer
    [`forklift`] = "automobile", -- trailer
    [`kosatka`] = "submarine", -- boat
    [`mower`] = "automobile", -- trailer
    [`policeb`] = "bike", -- automobile
    [`ripley`] = "automobile", -- trailer
    [`rrocket`] = "automobile", -- bike
    [`sadler`] = "automobile", -- trailer
    [`sadler2`] = "automobile", -- trailer
    [`scrap`] = "automobile", -- trailer
    [`slamtruck`] = "automobile", -- trailer
    [`Stryder`] = "automobile", -- bike
    [`submersible`] = "submarine", -- boat
    [`submersible2`] = "submarine", -- boat
    [`thruster`] = "heli", -- automobile
    [`towtruck`] = "automobile", -- trailer
    [`towtruck2`] = "automobile", -- trailer
    [`tractor`] = "automobile", -- trailer
    [`tractor2`] = "automobile", -- trailer
    [`tractor3`] = "automobile", -- trailer
    [`trailersmall2`] = "trailer", -- automobile
    [`utillitruck`] = "automobile", -- trailer
    [`utillitruck2`] = "automobile", -- trailer
    [`utillitruck3`] = "automobile", -- trailer
}

---@param model number|string
---@return string | boolean
function ESX.GetVehicleTypeClient(model)
    model = type(model) == "string" and joaat(model) or model
    if not IsModelInCdimage(model) then
        return false
    end

    if not IsModelAVehicle(model) then
        return false
    end

    if mismatchedTypes[model] then
        return mismatchedTypes[model]
    end

    local vehicleType = GetVehicleClassFromName(model)
    local types = {
        [8] = "bike",
        [11] = "trailer",
        [13] = "bike",
        [14] = "boat",
        [15] = "heli",
        [16] = "plane",
        [21] = "train",
    }

    return types[vehicleType] or "automobile"
end

ESX.GetVehicleType = ESX.GetVehicleTypeClient
