-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

function Core.PlayerClass.AttachNotifications(self)
    function self.showNotification(msg, notifyType, length, title, position)
        self.triggerEvent("esx:showNotification", msg, notifyType, length, title, position)
    end

    function self.showAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
        self.triggerEvent("esx:showAdvancedNotification", sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    end

    function self.showHelpNotification(msg, thisFrame, beep, duration)
        self.triggerEvent("esx:showHelpNotification", msg, thisFrame, beep, duration)
    end

end
