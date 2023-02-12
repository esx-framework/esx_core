---@param key string
function ESX.GetPlayerStateBag(key)
    return LocalPlayer.state[key]
end

---@param key string
---@param val string
---@param sync boolean
function ESX.SetPlayerStateBag(key, val, sync)
    if not sync then sync = true end
    LocalPlayer.state:set(key, val, sync)
end