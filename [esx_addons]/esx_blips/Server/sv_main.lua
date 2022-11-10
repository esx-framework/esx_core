RegisterCommand(Config.OpenContext, function(source, args, rawmessage)
    if (source > 0) then
        local ped = GetPlayerPed(source)
        local coordenadas = GetEntityCoords(ped)
        TriggerClientEvent('Esx_Blips:MenuBlip', source)
    end
end, true)

RegisterCommand(Config.DeleteBlip, function(source, args, rawCommand)
    if (source > 0) then
        if not candelete then
            candelete = true
        else
            candelete = false
        end
        Wait(100)
        TriggerClientEvent('Esx_Blips:Sinc', source, candelete)
    end
end, true)

RegisterServerEvent('Esx_Blips:TO_Client')
AddEventHandler('Esx_Blips:TO_Client', function (source, bool)
    local loadFile= LoadResourceFile(GetCurrentResourceName(), "./Blips.json")
    local extract = {}
    extract = json.decode(loadFile)
    TriggerClientEvent("Esx_Blips:Load_Table", source, extract)
end)

RegisterServerEvent('Esx_Blips:To_Json')
AddEventHandler('Esx_Blips:To_Json', function (title, coords, color, sprite, size)
    local tableblip = {}
    local archivo = LoadResourceFile(GetCurrentResourceName(), "Blips.json")
    tableblip = json.decode(archivo)
	local inserting = {
        Coords = coords,
        Size = size,
        Sprite = sprite,
        Color = color,
        Title = title
    }
	table.insert(tableblip, inserting)
	SaveResourceFile(GetCurrentResourceName(), "Blips.json", json['encode'](tableblip, { indent = true }), -1)
    TriggerClientEvent('Esx_Blips:Client:Removeblips', -1)
    Wait(250)
    TriggerEvent('Esx_Blips:TO_Client', -1)
end)

RegisterServerEvent('Esx_Blips:delete')
AddEventHandler('Esx_Blips:delete', function (id)
    local loadz = LoadResourceFile(GetCurrentResourceName(), "Blips.json")
    tableblip = json.decode(loadz)
    table['remove'](tableblip, id)
    SaveResourceFile(GetCurrentResourceName(), "Blips.json", json['encode'](tableblip, { indent = true }), -1)
    TriggerClientEvent('Esx_Blips:Client:Removeblips', -1)
    Wait(250)
    TriggerEvent('Esx_Blips:TO_Client', -1)
end)