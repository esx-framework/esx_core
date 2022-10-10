local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local ShopOpen = false

function OpenBuyLicenseMenu(zone)
    ShopOpen = true
    local Elements = {{
        icon = "fa-regular fa-money-bill-alt",
        unselectable = true,
        title = TranslateCap("license_shop_title")
	}, {
		icon = "fa-regular fa-id-card",
		title = TranslateCap("buy_license"),
        description = "Price: $"..Config.LicensePrice,
		value = "buylicense"
	}, {
		icon = "fa-solid fa-xmark",
		title = TranslateCap("menu_cancel"),
		value = "cancel"
    }}

    ESX.OpenContext(Config.MenuPosition, Elements, function(menu, element)
        if element.value == "buylicense" then
			ESX.TriggerServerCallback('esx_weaponshop:buyLicense', function(bought)
                if bought then
                    ESX.CloseContext()
                end
            end)
		end
		if element.value == "cancel" then
          ESX.CloseContext()
		end
    end)
end



function OpenShopMenu(zone)
    ShopOpen = true
    local Elements = {{
        icon = "fa-solid fa-bullseye",
        unselectable = true,
        description = TranslateCap("weapon_shop_menu_description"),
        title = TranslateCap("weapon_shop_menu_title")
    }}
    for i = 1, #Config.Zones[zone].Items, 1 do
        local item = Config.Zones[zone].Items[i]
        item.label = ESX.GetWeaponLabel(item.name)
        Elements[#Elements + 1] = {
            icon = "fa-solid fa-gun",
            title = item.label,
            description = "Price: $".. ESX.Math.GroupDigits(item.price),
            price = item.price,
            weaponName = item.name,
            value = "buy"
        }
    end

    ESX.OpenContext(Config.MenuPosition, Elements, function(menu, element)

        if element.value == "buy" then
            ESX.TriggerServerCallback('esx_weaponshop:buyWeapon', function(bought)
                if bought then
                    DisplayBoughtScaleform(element.weaponName, element.price)
					ESX.CloseContext()
                else
                    PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)
                end
            end, element.weaponName, zone)
        end

    end, function(menu)
        ShopOpen = false
        CurrentAction = 'shop_menu'
        CurrentActionMsg = TranslateCap('shop_menu_prompt')
        CurrentActionData = {
            zone = zone
        }
    end)
end

function DisplayBoughtScaleform(weaponName, price)
    local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
    local sec = 4

    BeginScaleformMovieMethod(scaleform, 'SHOW_WEAPON_PURCHASED')

    ScaleformMovieMethodAddParamTextureNameString(TranslateCap('weapon_bought', ESX.Math.GroupDigits(price)))
    ScaleformMovieMethodAddParamTextureNameString(ESX.GetWeaponLabel(weaponName))
    ScaleformMovieMethodAddParamInt(joaat(weaponName))
    ScaleformMovieMethodAddParamTextureNameString('')
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()

    PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)

    CreateThread(function()
        while sec > 0 do
            Wait(0)
            sec = sec - 0.01

            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if ShopOpen then
            ESX.CloseContext()
        end
    end
end)

-- Create Blips
CreateThread(function()
    for k, v in pairs(Config.Zones) do
        local blipSettings = v.Blip
        if blipSettings.Enabled then
            for i = 1, #v.Locations, 1 do
                local blip = AddBlipForCoord(v.Locations[i])

                SetBlipSprite(blip, blipSettings.Sprite)
                SetBlipDisplay(blip, blipSettings.Display)
                SetBlipScale(blip, blipSettings.Scale)
                SetBlipColour(blip, blipSettings.Colour)
                SetBlipAsShortRange(blip, blipSettings.ShortRange)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(TranslateCap('map_blip'))
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)

local TextShown = false
local GetEntityCoords = GetEntityCoords
local CreateThread = CreateThread
local Wait = Wait
local IsControlJustReleased = IsControlJustReleased

-- Display markers
CreateThread(function()
    while true do
        local Sleep = 1500
        local InShop = false
        local CurrentShop = nil
        local coords = GetEntityCoords(ESX.PlayerData.ped)

        for k, v in pairs(Config.Zones) do
            for i = 1, #v.Locations, 1 do
                if (Config.Type ~= -1 and #(coords - v.Locations[i]) < Config.DrawDistance) then
                    InShop = true
                    CurrentShop = v.Locations[i]
                    Sleep = 0
                    if #(coords - CurrentShop) < 2.0 then
                        if not TextShown then
                            ESX.TextUI(TranslateCap('shop_menu_prompt'))
                            TextShown = true
                        end
                        if IsControlJustReleased(0, 38) then
                            if Config.LicenseEnable and v.Legal then
                                ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
                                    if hasWeaponLicense then
                                        OpenShopMenu(k)
                                    else
                                        OpenBuyLicenseMenu(k)
                                    end
                                end, GetPlayerServerId(PlayerId()), 'weapon')
                            else
                                OpenShopMenu(k)
                            end
                        end
                    end
                end
                DrawMarker(Config.Type, v.Locations[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y,
                    Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false,
                    false, false)
            end
        end
        if not CurrentShop and TextShown then
            TextShown = false
            ESX.HideUI()
        end
        if not InShop and ShopOpen then
            if ShopOpen then
                TextShown = false
                ESX.HideUI()
                ESX.CloseContext()
                ShopOpen = false
            end
        end
        Wait(Sleep)
    end
end)
