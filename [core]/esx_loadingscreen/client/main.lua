--[[
    ESX Loading Screen
--]]

local loadScreenActive = true

local SHUTDOWN_DELAY <const> = 2500

RegisterNUICallback('loadingComplete', function(_, cb)
    cb({})

    if not loadScreenActive then
        return
    end

    loadScreenActive = false

    CreateThread(function()
        Wait(SHUTDOWN_DELAY)
        ShutdownLoadingScreenNui()
    end)
end)