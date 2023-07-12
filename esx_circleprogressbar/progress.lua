ESX = nil

ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('esx_circleprogressbar:updateProgress')
AddEventHandler('esx_circleprogressbar:updateProgress', function(progress)
    TriggerClientEvent('esx_circleprogressbar:updateProgress', -1, progress)
end)

-- Edited & Created by Its_Cehic