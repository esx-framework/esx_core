-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Chunks = {}

RegisterNUICallback("__chunk", function(data, cb)
    Chunks[data.id] = Chunks[data.id] or ""
    Chunks[data.id] = Chunks[data.id] .. data.chunk

    if data["end"] then
        local msg = json.decode(Chunks[data.id])
        TriggerEvent(GetCurrentResourceName() .. ":message:" .. data.__type, msg)
        Chunks[data.id] = nil
    end

    cb("")
end)
