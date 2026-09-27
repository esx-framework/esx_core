-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Class <const> = xLib.require "@esx_whitelist.client.module.whitelist.Class"
local Util <const> = xLib.require "@esx_whitelist.client.module.whitelist.util"

local Service = {}
local ui = Class.WhitelistUI.new()
local updatesSubscribed = false
local theme = {
    primaryColor = GetConvar("esx:ui:primaryColor", "#FB9B04"),
    secondaryColor = GetConvar("esx:ui:secondaryColor", "#252525"),
    backgroundColor = GetConvar("esx:ui:backgroundColor", "#161616"),
    accentColor = GetConvar("esx:ui:accentColor", "#FB9B04"),
    logoUrl = GetConvar("esx:ui:logoUrl", "")
}

local function triggerServerCallback(action, data, callback)
    ESX.TriggerServerCallback(action, callback, type(data) == "table" and data or {})
end

local function sendUiMessage(action, data)
    if ui.isVisible then SendNUIMessage({ action = action, data = data }) end
end

local function setUpdatesSubscribed(subscribed)
    if updatesSubscribed == subscribed then return end
    updatesSubscribed = subscribed
    TriggerServerEvent(subscribed and "esx_whitelist:subscribeUpdates" or "esx_whitelist:unsubscribeUpdates")
end

local function openUI()
    if ui.isVisible then return end
    triggerServerCallback("esx_whitelist:getConfig", nil, function(config)
        if not config then
            ESX.ShowNotification("~r~" .. Util.Translate(ui.translations, "no_permission"))
            return
        end
        config.theme = theme
        ui:toggle(true, config)
        setUpdatesSubscribed(true)
    end)
end

local function registerEvents()
    ESX.SecureNetEvent("esx_whitelist:startGracePeriod", function(seconds) ui:startGracePeriod(seconds) end)
    ESX.SecureNetEvent("esx_whitelist:cancelGracePeriod", function() ui:cancelGracePeriod() end)
    ESX.SecureNetEvent("esx_whitelist:stateChanged", function(enabled)
        ui.config.whitelistEnabled = enabled == true
        sendUiMessage("whitelistStateChanged", { whitelistEnabled = ui.config.whitelistEnabled })
    end)
    ESX.SecureNetEvent("esx_whitelist:entryChanged", function()
        sendUiMessage("whitelistEntryChanged")
    end)
end

local function registerNui()
    RegisterNUICallback("closeUI", function(_, cb)
        setUpdatesSubscribed(false)
        ui:toggle(false)
        cb("ok")
    end)
    RegisterNUICallback("getConfig", function(_, cb)
        triggerServerCallback("esx_whitelist:getConfig", nil, function(config)
            if config then config.theme = theme end
            cb(config or {})
        end)
    end)
    RegisterNUICallback("updateConfig", function(data, cb)
        triggerServerCallback("esx_whitelist:updateConfig", data, function(success) cb(success == true) end)
    end)
    RegisterNUICallback("testWebhook", function(_, cb)
        triggerServerCallback("esx_whitelist:testWebhook", nil, function(success)
            if success then ESX.ShowNotification("~g~" .. Util.Translate(ui.translations, "webhook_sent")) end
            cb(success == true)
        end)
    end)
    RegisterNUICallback("getWhitelistEntries", function(data, cb)
        data = type(data) == "table" and data or {}
        triggerServerCallback("esx_whitelist:getWhitelistEntries", {
            cursor = tonumber(data.cursor),
            limit = tonumber(data.limit) or 50,
            search = type(data.search) == "string" and data.search or "",
            status = tonumber(data.status)
        }, function(result)
            cb(result or { entries = {}, cursor = nil, nextCursor = nil, hasMore = false, limit = 50 })
        end)
    end)
    RegisterNUICallback("managePlayer", function(data, cb)
        triggerServerCallback("esx_whitelist:managePlayer", data, function(success, message)
            cb({ success = success == true, message = message })
        end)
    end)
    RegisterNUICallback("toggleWhitelistStatus", function(data, cb)
        triggerServerCallback("esx_whitelist:toggleWhitelistStatus", data, function(success) cb(success == true) end)
    end)
end

function Service.Init()
    registerEvents()
    registerNui()

    AddEventHandler("onResourceStop", function(resourceName)
        if GetCurrentResourceName() == resourceName then
            setUpdatesSubscribed(false)
        end
    end)

    RegisterCommand(Config.UICommand, function()
        openUI()
    end, false)
end

return Service
