-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Menu = {}

local function requestAction(event, ...)
    if Menu.pendingAction then return { success = false, error = 'busy' } end

    Menu.pendingAction = true

    local ok, result = pcall(xLib.callback.await, event, false, ...)

    Menu.pendingAction = false

    if not ok or type(result) ~= 'table' then
        return { success = false, error = 'database_error' }
    end

    return result
end

function Menu:CheckModel(character)
    if not character.model and character.skin then
        if character.skin.model then
            character.model = character.skin.model
        elseif character.skin.sex == 1 then
            character.model = `mp_f_freemode_01`
        else
            character.model = `mp_m_freemode_01`
        end
    end
end

local GetSlot = function()
    for i = 1, Multicharacter.slots do
        if not Multicharacter.Characters[i] then
            return i
        end
    end
end

function Menu:NewCharacter()
    local slot = GetSlot()
    if not slot then return { success = false, error = 'invalid_character' } end

    local result = requestAction('esx_multicharacter:chooseCharacter', slot, true)
    if not result.success then return result end
    TriggerEvent("esx_identity:showRegisterIdentity")

    local playerPed = PlayerPedId()

    SetPedAoBlobRendering(playerPed, false)
    SetEntityAlpha(playerPed, 0, false)

    Multicharacter:CloseUI()
    return result
end


function Menu:InitCharacter()
    local Characters = Multicharacter.Characters
    local Character
    for i = 1, Multicharacter.slots do
        if Characters[i] then Character = i break end
    end

    Multicharacter.spawned = false
    self:CheckModel(Characters[Character])

    if not Multicharacter.spawned then
        Multicharacter:SetupCharacter(Character)
    end
    Wait(500)
    
    xLib.nui.send({
        action = "ToggleMulticharacter",
        data = {
            show = true,
            Characters = Characters,
            CanDelete = Config.CanDelete,
            AllowedSlot = Multicharacter.slots,
            Locale = Locales[Config.Locale].UI,
        }
    })

    xLib.nui.focus(true, true)
end

function Menu:SelectCharacter(index)
    if self.pendingAction or not Multicharacter.Characters[index] then
        return { success = false, error = 'busy' }
    end

    Multicharacter:SetupCharacter(index)

    local playerPed = PlayerPedId()
    SetPedAoBlobRendering(playerPed, true)
    ResetEntityAlpha(playerPed)

    return { success = true }
end

function Menu:PlayCharacter(index)
    index = tonumber(index) or Multicharacter.spawned
    if not index or not Multicharacter.Characters[index] then
        return { success = false, error = 'invalid_character' }
    end

    local result = requestAction('esx_multicharacter:chooseCharacter', index, false)
    if not result.success then return result end

    Multicharacter.spawned = index
    Multicharacter:CloseUI()

    return result
end

function Menu:DeleteCharacter(index)
    index = tonumber(index) or Multicharacter.spawned

    if not index or not Multicharacter.Characters[index] then
        return { success = false, error = 'invalid_character' }
    end
    
    return requestAction('esx_multicharacter:deleteCharacter', index)
end
