-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@param message string
---@param length? number Timeout in milliseconds
---@param options? ProgressBarOptions
---@return boolean Success Whether the progress bar was successfully created or not
function ESX.Progressbar(message, length, options)
    return Core.IsResourceFound("esx_progressbar") and exports["esx_progressbar"]:Progressbar(message, length, options)
end

function ESX.CancelProgressbar()
    return Core.IsResourceFound("esx_progressbar") and exports["esx_progressbar"]:CancelProgressbar()
end

---@param message string The message to show
---@param notifyType? string The type of notification to show
---@param length? number The length of the notification
---@param title? string The title of the notification
---@param position? string The position of the notification
---@return nil
function ESX.ShowNotification(message, notifyType, length, title, position)
    return Core.IsResourceFound("esx_notify") and exports["esx_notify"]:Notify(notifyType or "info", length or 5000, message, title, position)
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
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, true)
end

function ESX.TextUI(...)
    return Core.IsResourceFound("esx_textui") and exports["esx_textui"]:TextUI(...)
end

---@return nil
function ESX.HideUI()
    return Core.IsResourceFound("esx_textui") and exports["esx_textui"]:HideUI()
end

RegisterNetEvent("esx:showNotification", ESX.ShowNotification)
RegisterNetEvent("esx:showAdvancedNotification", ESX.ShowAdvancedNotification)
RegisterNetEvent("esx:showHelpNotification", ESX.ShowHelpNotification)
