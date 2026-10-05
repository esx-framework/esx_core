-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local EVENT_PREFIX <const> = "esxwl:"

return function()
    local Nui = {}
    local isOpen = false

    ---@return boolean
    function Nui:IsOpen()
        return isOpen
    end

    ---Opens the panel 
    ---@param state table sanitized panel state from the server
    ---@param theme table theme convars resolved by NuiUtil.ReadTheme()
    function Nui:Open(state, theme)
        isOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "open",
            state = state,
            theme = theme,
        })
    end

    ---Closes the panel
    function Nui:Close()
        if not isOpen then
            return
        end
        isOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" })
    end

    ---Pushes a full state refresh into an open panel.
    ---@param state table
    function Nui:SendState(state)
        if isOpen then
            SendNUIMessage({ action = "state", state = state })
        end
    end

    ---Pushes the result of a config update into an open panel.
    ---@param ack table { ok: boolean, key: string?, error: string?, state: table? }
    function Nui:SendAck(ack)
        if isOpen then
            SendNUIMessage({ action = "ack", ack = ack })
        end
    end

    RegisterNUICallback("close", function(_, cb)
        Nui:Close()
        cb({ ok = true })
    end)

    RegisterNUICallback("requestState", function(_, cb)
        TriggerServerEvent(EVENT_PREFIX .. "sv:requestState")
        cb({ ok = true })
    end)

    RegisterNUICallback("updateConfig", function(data, cb)
        if type(data) == "table" and type(data.key) == "string" and #data.key <= 64 then
            TriggerServerEvent(EVENT_PREFIX .. "sv:updateConfig", {
                key = data.key,
                value = data.value,
            })
        end
        cb({ ok = true })
    end)

    return Nui
end
