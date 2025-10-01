---@param playerId integer
---@param data { identifier: string, ssn: string, group: string, accounts: ESXAccount[], inventory: table, weight: number, job: ESXJob, loadout: ESXInventoryWeapon[], steamName: string, coords: vector4|{x: number, y: number, z: number, heading: number}, metadata: table }
---@return xPlayer
function GetXPlayer(playerId, data)
    local xPlayer <const> = {
        playerId = playerId,
        source = playerId,
        variables = {},
        job = {},
        metadata = {},
        maxWeight = Config.MaxWeight,
        lastPlaytime = 0,
        paycheckEnabled = true,
        admin = Core.IsPlayerAdmin(playerId),
        state = Player(playerId).state,
        license = GetPlayerIdentifierByType(tostring(playerId), 'license')
    }

    for k,v in pairs(data) do
        xPlayer[k] = v
    end

    if type(data.metadata.jobDuty) ~= 'boolean' then
        xPlayer.metadata.jobDuty = data.job.name ~= 'unemployed' and Config.DefaultJobDuty or false
    end

    IsAuthorized[#IsAuthorized+1] = true

    for k,v in pairs(XPlayerClass) do
        if type(v) == 'function' then
            xPlayer[k] = XPlayerClass(xPlayer, k)
        end
    end

    return xPlayer
end