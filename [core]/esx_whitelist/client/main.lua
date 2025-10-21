local isWhitelistEnabled = false
local isGracePeriodActive = false
local gracePeriodEndTime = 0
local isUIVisible = false
local translations = {}

local function loadLocaleFile()
    local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. Config.Locale .. '.json')
    if localeFile then
        translations = json.decode(localeFile)
    end
end

local function T(key, ...)
    local str = translations[key] or key
    if not str then return key end
    if ... then
        local success, result = pcall(string.format, str, ...)
        return success and result or str
    end
    return str
end

RegisterNetEvent('esx_whitelist:stateChanged', function(enabled)
    isWhitelistEnabled = enabled
end)

RegisterNetEvent('esx_whitelist:startGracePeriod', function(seconds)
    isGracePeriodActive = true
    gracePeriodEndTime = GetGameTimer() + (seconds * 1000)
    
    CreateThread(function()
        while isGracePeriodActive and GetGameTimer() < gracePeriodEndTime do
            Wait(1000)
            local remainingSeconds = math.ceil((gracePeriodEndTime - GetGameTimer()) / 1000)
            if remainingSeconds > 0 then
                ESX.ShowNotification(string.format('~r~%s~s~\n%s', T('whitelist_active'), T('remaining_time', remainingSeconds)))
            end
        end
        isGracePeriodActive = false
    end)
end)

RegisterNetEvent('esx_whitelist:cancelGracePeriod', function()
    isGracePeriodActive = false
    gracePeriodEndTime = 0
    ESX.ShowNotification('~g~' .. T('grace_cancelled'))
end)

local function toggleUI(visible)
    isUIVisible = visible
    SetNuiFocus(visible, visible)
    
    if not visible then
        SendNUIMessage({
            action = 'closeUI'
        })
    end
end

RegisterCommand(Config.UICommand, function()
    if isUIVisible then return end
    
    ESX.TriggerServerCallback('esx_whitelist:getConfig', function(serverConfig)
        if not serverConfig then
            ESX.ShowNotification('~r~' .. T('no_permission'))
            return
        end
        
        toggleUI(true)
        SendNUIMessage({
            action = 'openUI',
            data = serverConfig
        })
    end)
end)

RegisterNUICallback('closeUI', function(data, cb)
    toggleUI(false)
    cb('ok')
end)

RegisterNUICallback('updateConfig', function(configData, cb)
    ESX.TriggerServerCallback('esx_whitelist:updateConfig', function(success)
        cb(success)
    end, configData)
end)

RegisterNUICallback('testWebhook', function(data, cb)
    ESX.TriggerServerCallback('esx_whitelist:testWebhook', function(success)
        if success then
            ESX.ShowNotification('~g~' .. T('webhook_sent'))
        end
        cb(success)
    end)
end)

RegisterNUICallback('getWhitelistEntries', function(data, cb)
    ESX.TriggerServerCallback('esx_whitelist:getWhitelistEntries', function(entries)
        cb(entries or {})
    end)
end)

RegisterNUICallback('getConfig', function(data, cb)
    ESX.TriggerServerCallback('esx_whitelist:getConfig', function(serverConfig)
        cb(serverConfig or {})
    end)
end)

RegisterNUICallback('managePlayer', function(data, cb)
    ESX.TriggerServerCallback('esx_whitelist:managePlayer', function(success, message)
        cb({success = success, message = message})
    end, data)
end)

RegisterNUICallback('toggleWhitelistStatus', function(data, cb)
    ESX.TriggerServerCallback('esx_whitelist:toggleWhitelistStatus', function(success)
        cb(success)
    end, data)
end)

local function DisableControls()
    while isUIVisible do
        Wait(0)
        DisableControlAction(0, 1, true)
        DisableControlAction(0, 2, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 18, true)
        DisableControlAction(0, 322, true)
        DisableControlAction(0, 106, true)
    end
end

CreateThread(function()
    loadLocaleFile()
    
    while true do
        Wait(100)
        if isUIVisible then
            DisableControls()
        end
    end
end)