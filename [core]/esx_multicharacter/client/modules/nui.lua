-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

RegisterNuiCallback('SelectCharacter', function (data, cb)
    local selectedIndex = type(data) == 'table' and tonumber(data.id)
    
    if selectedIndex then
        cb(Menu:SelectCharacter(selectedIndex))
        return
    end
    cb({ success = false, error = 'invalid_character' })
end)

RegisterNuiCallback('PlayCharacter', function (data, cb)
    cb(Menu:PlayCharacter(type(data) == 'table' and data.id))
end)

RegisterNuiCallback('DeleteCharacter', function (data, cb)
    cb(Menu:DeleteCharacter(type(data) == 'table' and data.id))
end)

RegisterNuiCallback('CreateCharacter', function (data, cb)
    cb(Menu:NewCharacter())
end)
