local ESX = exports["es_extended"]:getSharedObject()
local inDealership = false
local currentCategory = nil
local previewVehicle = nil
local previewCam = nil

-- Dealership marker and interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.DealershipLocation)

        if distance < 30.0 then
            DrawMarker(
                1, -- Type: cylinder
                Config.DealershipLocation.x, Config.DealershipLocation.y, Config.DealershipLocation.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                2.0, 2.0, 1.0,
                255, 107, 53, 100, -- Orange color (70s vibe)
                false, true, 2, nil, nil, false
            )

            if distance < 2.5 then
                ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to browse ~o~Groovy Rides~s~")

                if IsControlJustReleased(0, 38) then -- E key
                    OpenDealershipMenu()
                end
            end
        else
            Citizen.Wait(500)
        end
    end
end)

function OpenDealershipMenu()
    local elements = {}

    for _, cat in ipairs(Config.Categories) do
        table.insert(elements, {
            unselectable = false,
            icon = "fas fa-car",
            title = cat.label,
            value = cat.name
        })
    end

    ESX.OpenContext('right', elements, function(menu, element)
        currentCategory = element.value
        OpenCategoryMenu(currentCategory)
    end, function()
        CleanupPreview()
    end)
end

function OpenCategoryMenu(category)
    local elements = {}

    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.category == category then
            table.insert(elements, {
                unselectable = false,
                icon = "fas fa-car-side",
                title = vehicle.name,
                description = "Price: $" .. FormatMoney(vehicle.price),
                value = vehicle
            })
        end
    end

    if #elements == 0 then
        ESX.ShowNotification("~r~No rides available in this category, dig?")
        return
    end

    ESX.OpenContext('right', elements, function(menu, element)
        local vehicleData = element.value
        ConfirmPurchase(vehicleData)
    end, function()
        OpenDealershipMenu()
    end)
end

function ConfirmPurchase(vehicleData)
    local elements = {
        {
            unselectable = true,
            icon = "fas fa-car",
            title = vehicleData.name,
            description = "Price: ~o~$" .. FormatMoney(vehicleData.price)
        },
        {
            unselectable = false,
            icon = "fas fa-check",
            title = "~g~Buy this ride",
            value = "buy"
        },
        {
            unselectable = false,
            icon = "fas fa-eye",
            title = "~y~Preview",
            value = "preview"
        },
        {
            unselectable = false,
            icon = "fas fa-times",
            title = "~r~Go back",
            value = "back"
        }
    }

    ESX.OpenContext('right', elements, function(menu, element)
        if element.value == "buy" then
            ESX.CloseContext()
            TriggerServerEvent('trickem:buyVehicle', vehicleData.model, vehicleData.price, vehicleData.name)
        elseif element.value == "preview" then
            PreviewVehicle(vehicleData.model)
        elseif element.value == "back" then
            OpenCategoryMenu(currentCategory)
        end
    end, function()
        CleanupPreview()
        OpenCategoryMenu(currentCategory)
    end)
end

function PreviewVehicle(model)
    CleanupPreview()

    local modelHash = GetHashKey(model)
    RequestModel(modelHash)

    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Citizen.Wait(100)
        timeout = timeout + 1
    end

    if HasModelLoaded(modelHash) then
        local spawnCoords = Config.SpawnPoint
        previewVehicle = CreateVehicle(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, false, false)
        SetEntityAlpha(previewVehicle, 200, false)
        SetEntityCollision(previewVehicle, false, false)
        FreezeEntityPosition(previewVehicle, true)
        SetVehicleOnGroundProperly(previewVehicle)
        SetModelAsNoLongerNeeded(modelHash)

        ESX.ShowNotification("~y~Previewing ride. Close the menu to stop.")
    end
end

function CleanupPreview()
    if previewVehicle and DoesEntityExist(previewVehicle) then
        DeleteEntity(previewVehicle)
        previewVehicle = nil
    end
end

function FormatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        CleanupPreview()
    end
end)
