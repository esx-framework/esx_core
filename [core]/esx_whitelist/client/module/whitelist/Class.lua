-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Util <const> = xLib.require "@esx_whitelist.client.module.whitelist.util"

local WhitelistUI = {}
WhitelistUI.__index = WhitelistUI

---@description Helper function.
function WhitelistUI.new()
    local self = setmetatable({}, WhitelistUI)
    self.is_visible = false
    self.is_grace_active = false
    self.grace_thread_running = false
    self.grace_end_time = 0
    self.config = {}
    if Config then
        self.translations = Util.loadLocale(Config.Locale)
    else
        self.translations = {}
        print("^1[esx_whitelist] Config is nil in WhitelistUI.new^7")
    end
    return self
end

---@description Helper function.
function WhitelistUI:toggle(visible, data)
    self.is_visible = visible
    SetNuiFocus(visible, visible)
    SendNUIMessage({ action = visible and "openUI" or "closeUI", data = visible and data or nil })
    if visible then self:startControlDisabler() end
end

---@description Helper function.
function WhitelistUI:startControlDisabler()
    if self.control_thread_running then return end
    self.control_thread_running = true
    CreateThread(function()
        while self.is_visible do
            Wait(0)
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 106, true)
        end
        self.control_thread_running = false
    end)
end

---@description Helper function.
function WhitelistUI:startGracePeriod(seconds)
    self.is_grace_active = true
    self.grace_end_time = GetGameTimer() + math.max(0, tonumber(seconds) or 0) * 1000
    if self.grace_thread_running then return end
    self.grace_thread_running = true
    CreateThread(function()
        while self.is_grace_active and GetGameTimer() < self.grace_end_time do
            Wait(1000)
            local remaining = math.ceil((self.grace_end_time - GetGameTimer()) / 1000)
            if remaining > 0 and self.is_grace_active then
                ESX.ShowNotification(string.format("~r~%s~s~\n%s", Util.translate(self.translations, "whitelist_active"), Util.translate(self.translations, "remaining_time", remaining)))
            end
        end
        self.is_grace_active = false
        self.grace_thread_running = false
    end)
end

---@description Helper function.
function WhitelistUI:cancelGracePeriod()
    self.is_grace_active = false
    self.grace_end_time = 0
    ESX.ShowNotification("~g~" .. Util.translate(self.translations, "grace_cancelled"))
end

return { WhitelistUI = WhitelistUI }
