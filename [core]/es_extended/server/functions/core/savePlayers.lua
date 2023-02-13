function Core.SavePlayers(cb)
    local xPlayers <const> = ESX.Players
    if not next(xPlayers) then
        return
    end

    local startTime <const> = os.time()
    local parameters = {}

    for _, xPlayer in pairs(ESX.Players) do
        parameters[#parameters + 1] = {
            json.encode(xPlayer.getAccounts(true)),
            xPlayer.job.name,
            xPlayer.job.grade,
            xPlayer.group,
            json.encode(xPlayer.getCoords()),
            json.encode(xPlayer.getInventory(true)),
            json.encode(xPlayer.getLoadout(true)),
            xPlayer.identifier
        }
    end

    MySQL.prepare(
        "UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ? WHERE `identifier` = ?",
        parameters,
        function(results)
            if not results then
                return
            end

            if type(cb) == 'function' then
                return cb()
            end

            print(('[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms'):format(#parameters,
                #parameters > 1 and 'players' or 'player',
                ESX.Math.Round((os.time() - startTime) / 1000000, 2)))
        end
    )
end
