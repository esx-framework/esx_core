---@class interactionslib
xLib.interactions = {}

local interactions = {}

---@param name string
function xLib.interactions.remove(name)
    if not interactions[name] then return end
    interactions[name] = nil
end

---@param name string
---@param onPress function
---@param condition? function
function xLib.interactions.register(name, onPress, condition)
    interactions[name] = {
        condition = condition or function() return true end,
        onPress = onPress,
        creator = GetInvokingResource() or "es_extended"
    }
end

---@return string
function xLib.interactions.getInteractKey()
    local hash = joaat("esx_interact") | 0x80000000
    return GetControlInstructionalButton(0, hash, true):sub(3)
end

xLib.addKeybind({
    name = "esx_interact",
    description = "Interact",
    defaultMapper = "keyboard",
    defaultKey = "e",
    onPressed = function()
        for _, interaction in pairs(interactions) do
            local success, result = pcall(interaction.condition)
            if success and result then
                interaction.onPress()
            end
        end
    end
})

AddEventHandler("onResourceStop", function(resource)
    for name, interaction in pairs(interactions) do
        if interaction.creator == resource then
            interactions[name] = nil
        end
    end
end)

return xLib.interactions
