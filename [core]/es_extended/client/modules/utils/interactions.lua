local interactions = {}
local pressedInteractions = {}

---@param name string
function ESX.RemoveInteraction(name)
    if not interactions[name] then return end
    interactions[name] = nil
end

---@param name string
---@param onPress fun():nil
---@param condition fun():boolean
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

---@param command_name string The command name
---@param label string The label to show
---@param input_group string The input group
---@param key string The key to bind
---@param on_press function The function to call on press
---@param on_release? function The function to call on release
function ESX.RegisterInput(command_name, label, input_group, key, on_press, on_release)
	local command = on_release and '+' .. command_name or command_name
    RegisterCommand(command, on_press, false)
    Core.Input[command_name] = ESX.HashString(command)
    if on_release then
        RegisterCommand('-' .. command_name, on_release, false)
    end
    RegisterKeyMapping(command, label or '', input_group or 'keyboard', key or '')
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
