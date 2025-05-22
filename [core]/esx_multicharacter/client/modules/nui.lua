RegisterNuiCallback('SelectCharacter', function (data, cb)
    local selectedIndex = tonumber(data.id)
    
    if selectedIndex then
        Menu:SelectCharacter(selectedIndex)
    end
    cb('ok')
end)

RegisterNuiCallback('PlayCharacter', function (data, cb)
    Menu:PlayCharacter()
    cb('ok')
end)

RegisterNuiCallback('DeleteCharacter', function (data, cb)
    Menu:DeleteCharacter()
    cb('ok')
end)

RegisterNuiCallback('CreateCharacter', function (data, cb)
    Menu:NewCharacter()
    cb('ok')
end)