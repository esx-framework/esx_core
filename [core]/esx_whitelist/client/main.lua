---@diagnostic disable: undefined-global, missing-parameter

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
    local translatedText = translations[key] or key
    if ... then
        return string.format(translatedText, ...)
    end
    return translatedText
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
    TriggerServerEvent('esx_whitelist:updateConfig', configData)
    cb('ok')
end)

RegisterNUICallback('testWebhook', function(data, cb)
    TriggerServerEvent('esx_whitelist:testWebhook')
    ESX.ShowNotification('~g~' .. T('webhook_sent'))
    cb('ok')
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
    TriggerServerEvent('esx_whitelist:managePlayer', data)
    cb('ok')
end)

RegisterNUICallback('toggleWhitelistStatus', function(data, cb)
    TriggerServerEvent('esx_whitelist:toggleWhitelistStatus', data)
    cb('ok')
end)

CreateThread(function()
    loadLocaleFile()
    
    while true do
        Wait(0)
        if isUIVisible then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 322, true)
            DisableControlAction(0, 106, true)
        end
    end
end)