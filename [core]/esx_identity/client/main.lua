-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local loadingScreenFinished = false
local ready = false
local guiEnabled = false
local registrationPending = false
local timecycleModifier = "hud_def_blur"
local themeDefaults = {
    secondaryColor = "#1b1c1a",
    backgroundColor = "#171918",
    accentColor = "#34342e",
}

ESX.SecureNetEvent("esx_identity:alreadyRegistered", function()
    while not loadingScreenFinished do
        Wait(100)
    end
    TriggerEvent("esx_skin:playerRegistered")
end)

ESX.SecureNetEvent("esx_identity:setPlayerData", function(data)
    SetTimeout(1, function()
        ESX.SetPlayerData("name", ("%s %s"):format(data.firstName, data.lastName))
        ESX.SetPlayerData("firstName", data.firstName)
        ESX.SetPlayerData("lastName", data.lastName)
        ESX.SetPlayerData("dateofbirth", data.dateOfBirth)
        ESX.SetPlayerData("sex", data.sex)
        ESX.SetPlayerData("height", data.height)
    end)
end)

AddEventHandler("esx:loadingScreenOff", function()
    loadingScreenFinished = true
end)

xLib.nui.register("ready", function()
    ready = true
    return 1
end)

function setGuiState(state)
        xLib.nui.focus(state, state)
        guiEnabled = state

        if state then
            SetTimecycleModifier(timecycleModifier)
        else
            ClearTimecycleModifier()
        end

        xLib.nui.send({
            type = "enableui",
            enable = state,
            theme = xLib.colors.getESXTheme(themeDefaults),
            settings = {
                maxNameLength = Config.MaxNameLength,
                minHeight = Config.MinHeight,
                maxHeight = Config.MaxHeight,
maxAge = Config.MaxAge,
                locale = Config.Locale,
                dateFormat = Config.DateFormat
            }
        })
end

RegisterNetEvent("esx_identity:showRegisterIdentity", function()
        TriggerEvent("esx_skin:resetFirstSpawn")
        while not (ready and loadingScreenFinished) do
            print("Waiting for esx_identity NUI..")
            Wait(100)
        end
        if not ESX.PlayerData.dead then
            setGuiState(true)
        end
end)

xLib.nui.register("register", function(data, reply)
        if not guiEnabled then
            return xLib.nui.fail("registrationClosed")
        end

        if registrationPending then
            return xLib.nui.fail("registrationPending")
        end
        registrationPending = true

        CreateThread(function()
            local ok, callback = pcall(xLib.callback.await, "esx_identity:registerIdentity", false, data)
            registrationPending = false
            if not ok or not callback then
                reply(xLib.nui.fail("registerFailed"))
                return
            end

            reply(xLib.nui.ok())
            ESX.ShowNotification(TranslateCap("thank_you_for_registering"))
            setGuiState(false)

            if not ESX.GetConfig().Multichar then
                TriggerEvent("esx_skin:playerRegistered")
            end
        end)
        return xLib.nui.defer
end)
