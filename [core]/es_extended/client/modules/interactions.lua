local interactions = {}
local pressedInteractions = {}

function ESX.RemoveInteraction(name)
    if not interactions[name] then return end
    interactions[name] = nil
end

ESX.RegisterInteraction = function(name, onPress, condition)
    interactions[name] = {
        condition = condition or function() return true end,
        onPress = onPress,
        creator = GetInvokingResource() or "es_extended"
    }
end

function ESX.GetInteractKey()
    local hash = joaat('esx_interact') | 0x80000000
    return GetControlInstructionalButton(0, hash, true):sub(3)
end

ESX.RegisterInput("esx_interact", "Interact", "keyboard", "e", function()
    for _, interaction in pairs(interactions) do
        local success, result = pcall(interaction.condition)
        if success and result then
            pressedInteractions[#pressedInteractions+1] = interaction
            interaction.onPress()
        end
    end
end)

AddEventHandler("onResourceStop", function(resource)
    for name, interaction in pairs(interactions) do
        if interaction.creator == resource then
            interactions[name] = nil
        end
    end
end)