---@param index string
function ESX.SetPlayerFunctionOverride(index)
    if not index or not Core.PlayerFunctionOverrides[index] then
        return print('[^3WARNING^7] No valid index provided.')
    end

    Config.PlayerFunctionOverride = index
end
