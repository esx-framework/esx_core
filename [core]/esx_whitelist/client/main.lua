-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local RESOURCE_NAME <const> = GetCurrentResourceName()
local EVENT_PREFIX <const> = "esxwl:"

local NuiUtil = xLib.require("@esx_whitelist.client.module.nui.util")
local Nui = xLib.require("@esx_whitelist.client.module.nui.main")()

RegisterCommand(Config.Panel.Command or "whitelist", function(_, args)
    if #args == 0 then
        TriggerServerEvent(EVENT_PREFIX .. "sv:requestPanel")
    else
        TriggerServerEvent(EVENT_PREFIX .. "sv:command", args)
    end
end, false)

RegisterNetEvent(EVENT_PREFIX .. "cl:openPanel", function(state)
    if type(state) ~= "table" then
        return
    end
    Nui:Open(state, NuiUtil.ReadTheme())
end)

RegisterNetEvent(EVENT_PREFIX .. "cl:requestOpen", function()
    TriggerServerEvent(EVENT_PREFIX .. "sv:requestPanel")
end)

RegisterNetEvent(EVENT_PREFIX .. "cl:stateUpdate", function(state)
    if type(state) == "table" then
        Nui:SendState(state)
    end
end)

RegisterNetEvent(EVENT_PREFIX .. "cl:configAck", function(ack)
    if type(ack) ~= "table" then
        return
    end
    if ack.ok and type(ack.state) == "table" then
        Nui:SendState(ack.state)
    end
    Nui:SendAck(ack)
end)

RegisterNetEvent(EVENT_PREFIX .. "cl:notify", function(message)
    if type(message) ~= "string" then
        return
    end
    TriggerEvent("chat:addMessage", {
        color = { 251, 155, 4 },
        multiline = false,
        args = { _("whitelist_title"), message },
    })
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == RESOURCE_NAME and Nui:IsOpen() then
        SetNuiFocus(false, false)
    end
end)
