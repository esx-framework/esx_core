-- define the money fountain list (SHARED SCRIPT)
moneyFountains = {}

-- index to know what to remove
local fountainIdx = 1

AddEventHandler('getMapDirectives', function(add)
    -- add a 'money_fountain' map directive
    add('money_fountain', function(state, name)
        return function(data)
            local coords = data[1]
            local amount = data.amount or 100

            local idx = fountainIdx
            fountainIdx += 1

            moneyFountains[idx] = {
                id = name,
                coords = coords,
                amount = amount
            }

            state.add('idx', idx)
        end
    end, function(state)
        moneyFountains[state.idx] = nil
    end)
end)