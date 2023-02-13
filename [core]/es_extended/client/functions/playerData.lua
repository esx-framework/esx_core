ESX.PlayerData = {}

---@param key string
---@param val any
function ESX.SetPlayerData(key, val)
    local current = ESX.PlayerData[key]
    ESX.PlayerData[key] = val
    if key == 'inventory' or key == 'loadout' then return end
    ESX.SetPlayerStateBag(key, val, true)
    if type(val) ~= 'table' or val == current then return end
    TriggerEvent('esx:setPlayerData', key, val, current)
end

---@param key string
function ESX.GetPlayerData(key)
    return key and ESX.PlayerData[key] or ESX.PlayerData
end
