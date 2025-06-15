Menu = {}

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

    TriggerServerEvent("esx_multicharacter:CharacterChosen", slot, true)
    TriggerEvent("esx_identity:showRegisterIdentity")

    local playerPed = PlayerPedId()

    SetPedAoBlobRendering(playerPed, false)
    SetEntityAlpha(playerPed, 0, false)

    Multicharacter:CloseUI()
end


function Menu:InitCharacter()
    local Characters = Multicharacter.Characters
    local Character = next(Characters)
    self:CheckModel(Characters[Character])

    if not Multicharacter.spawned then
        Multicharacter:SetupCharacter(Character)
    end
    Wait(500)
    
    SendNUIMessage({
        action = "ToggleMulticharacter",
        data = {
            show = true,
            Characters = Characters,
            CanDelete = Config.CanDelete,
            AllowedSlot = Multicharacter.slots,
            Locale = Locales[Config.Locale].UI,
        }
    })

    SetNuiFocus(true, true)
end

function Menu:SelectCharacter(index)
    Multicharacter:SetupCharacter(index)
    local playerPed = PlayerPedId()
    SetPedAoBlobRendering(playerPed, true)
    ResetEntityAlpha(playerPed)
end

function Menu:PlayCharacter()
    Multicharacter:CloseUI()
    TriggerServerEvent("esx_multicharacter:CharacterChosen", Multicharacter.spawned, false)
end

function Menu:DeleteCharacter()
    TriggerServerEvent("esx_multicharacter:DeleteCharacter", Multicharacter.spawned)
    Multicharacter.spawned = false
end