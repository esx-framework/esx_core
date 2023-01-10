--[[
      ESX Property - Properties Made Right!
    Copyright (C) 2022 ESX-Framework

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]] local GameBuild = GetGameBuildNumber()
Properties = {}
CurrentId = 0
local CurrentDrawing = {}
InProperty = false
PlayerKeys = {}
InCCTV = false
local Blips = {}
local Shell = nil
local PM = Config.PlayerManagement
local CreateThread = CreateThread
local Wait = Wait
local ShowingUIs = {Exit = false, Wardrobe = false, Storage = false, ExitShell = false}
local ox_inventory = exports.ox_inventory
local DoScreenFadeIn = DoScreenFadeIn
local PlayerPedId = PlayerPedId
local GetEntityCoords = GetEntityCoords
local GetEntityHeading = GetEntityHeading
local IsControlJustPressed = IsControlJustPressed
local IsControlPressed = IsControlPressed
local DoScreenFadeOut = DoScreenFadeOut
function RefreshBlips()
  for i = 1, #Blips, 1 do
    RemoveBlip(Blips[i])
    Blips[i] = nil
  end

  for k, v in pairs(Properties) do
    if v.Owned and Config.OwnedBlips then
      if v.Owner == ESX.PlayerData.identifier then
        local Blip = AddBlipForCoord(v.Entrance.x, v.Entrance.y, v.Entrance.z)
        SetBlipSprite(Blip, 40)
        SetBlipAsShortRange(Blip, true)
        SetBlipScale(Blip, 0.8)
        SetBlipColour(Blip, 0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.Name)
        EndTextCommandSetBlipName(Blip)
        SetBlipCategory(Blip, 11)
        Blips[#Blips + 1] = Blip
      elseif PlayerKeys[k] then
        local Blip = AddBlipForCoord(v.Entrance.x, v.Entrance.y, v.Entrance.z)
        SetBlipSprite(Blip, GameBuild >= 2699 and 811 or 134)
        SetBlipAsShortRange(Blip, true)
        SetBlipScale(Blip, 0.9)
        SetBlipColour(Blip, 26)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.Name)
        EndTextCommandSetBlipName(Blip)
        SetBlipCategory(Blip, 11)
        Blips[#Blips + 1] = Blip
      end
    elseif not v.Owned and Config.ForSaleBlips then
      local Blip = AddBlipForCoord(v.Entrance.x, v.Entrance.y, v.Entrance.z)
      SetBlipSprite(Blip, 350)
      SetBlipAsShortRange(Blip, true)
      SetBlipScale(Blip, 0.7)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(v.Name)
      EndTextCommandSetBlipName(Blip)
      SetBlipCategory(Blip, 10)
      Blips[#Blips + 1] = Blip
    end
  end

  if PM.Enabled then
    local Blip = AddBlipForCoord(PM.Locations.Entrance)
    SetBlipSprite(Blip, 374)
    SetBlipColour(Blip, 45)
    SetBlipAsShortRange(Blip, true)
    SetBlipScale(Blip, 0.7)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(TranslateCap("office_blip",PM.joblabel))
    EndTextCommandSetBlipName(Blip)
    Blips[#Blips + 1] = Blip
  end
end

RegisterNetEvent("esx_property:syncProperties", function(properties, lastProperty)
  while not ESX.PlayerLoaded and not ESX.PlayerData.identifier do
    Wait(0)
  end
  Properties = properties
  for house, data in pairs(Properties) do
    if data.Keys then
      for ident, vaues in pairs(data.Keys) do
        if vaues and ident == ESX.PlayerData.identifier then
          PlayerKeys[house] = true
        end
      end
    end
  end
  if lastProperty then
    if Properties[lastProperty.id] and (Properties[lastProperty.id].Owner == ESX.PlayerData.identifier or PlayerKeys[lastProperty.id]) then
      AttemptHouseEntry(lastProperty.id)
    else
      ESX.TriggerServerCallback('esx_property:RemoveLastProperty', function()
        SetEntityCoords(ESX.PlayerData.ped, vector3(lastProperty.coords.x, lastProperty.coords.y, lastProperty.coords.z))
      end)
    end
  end
  RefreshBlips()
end)

RegisterNetEvent("esx_property:giveKeyAccess", function(Property)
  ESX.TriggerServerCallback("esx_property:ShouldHaveKey", function(Should)
    if Should then
      PlayerKeys[Property] = true
    end
  end, Property)
end)

RegisterNetEvent("esx_property:RemoveKey", function(Property)
  PlayerKeys[Property] = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  RefreshBlips()
end)

exports("GetProperties", function()
  return Properties
end)

function OpenInteractionMenu(PropertyId, Interaction)
  local Property = Properties[PropertyId]
  if Property.Owned then
    if Interaction == "Wardrobe" then
      Config.WardrobeInteraction(PropertyId, Interaction)
    elseif Interaction == "Storage" then
      if Config.OxInventory then
        exports.ox_inventory:openInventory('stash', {id = 'property-' .. PropertyId, owner = Property.Owner})
      end
    end
  end
end

function GiveKeysMenu(Property)
  ESX.TriggerServerCallback("esx_property:GetInsidePlayers", function(Players)
    local Elements = {{unselectable = true, title = TranslateCap("nearby"), icon = "fas fa-user-plus"},
                      {title = TranslateCap("back"), icon = "fas fa-arrow-left", value = "go_back"}}
    for i = 1, #Players, 1 do
      Elements[#Elements + 1] = {title = Players[i].Name, icon = "far fa-user", index = Players[i].Id, value = "user"}
    end
    ESX.OpenContext("right", Elements, function(menu, element)
      if element.value == "go_back" then
        ManageKeys(Property)
      elseif element.value == "user" then
        ESX.TriggerServerCallback("esx_property:GiveKey", function(KeyGiven)
          if KeyGiven then
            ESX.ShowNotification(TranslateCap("gave_key",element.title), "success")
            ESX.CloseContext()
          else
            ESX.ShowNotification(TranslateCap("key_cannot_give"), "error")
          end
        end, Property, element.index)
      end
    end)
  end, Property)
end

function RemoveKeysMenu(Property)
  ESX.TriggerServerCallback("esx_property:GetPlayersWithKeys", function(Players)
    local Elements = {{unselectable = true, title = TranslateCap("remove_title"), icon = "fas fa-user-plus"},
                      {title = TranslateCap("back"), icon = "fas fa-arrow-left", value = "go_back"}}
    for k, v in pairs(Players) do
      local name = v.name
      local Id = k
      Elements[#Elements + 1] = {title = name, icon = "far fa-user", value = "user", id = Id}
    end
    ESX.OpenContext("right", Elements, function(menu, element)
      if element.value == "go_back" then
        ManageKeys(Property)
      elseif element.value == "user" then
        ESX.TriggerServerCallback("esx_property:RemoveKey", function(KeyGiven)
          if KeyGiven then
            ESX.ShowNotification(TranslateCap("key_revoke_success", element.title), "success")
            ESX.CloseContext()
          else
            ESX.ShowNotification(TranslateCap("key_revoke_error"), "error")
          end
        end, Property, element.id)
      end
    end)
  end, Property)
end

function ManageKeys(Property)
  ESX.HideUI()
  local Elements = {{unselectable = true, title = TranslateCap("key_management"), icon = "fas fa-key"},
                    {title = TranslateCap("back"), icon = "fas fa-arrow-left", value = "go_back"},
                    {title = TranslateCap("give_keys"), icon = "fas fa-plus", value = "give_keys"},
                    {title = TranslateCap("remove_keys"), icon = "fas fa-minus", value = "remove_keys"}}

  ESX.OpenContext("right", Elements, function(menu, element)
    if element.value == "go_back" then
      OpenPropertyMenu(Property)
    end
    if element.value == "give_keys" then
      GiveKeysMenu(Property)
    end
    if element.value == "remove_keys" then
      RemoveKeysMenu(Property)
    end
  end)
end

function SetPropertyName(Property)
  local Name = Properties[Property].setName ~= "" and Properties[Property].setName or Properties[Property].Name
  local Elements = {{unselectable = true, title = TranslateCap("name_edit"), icon = "fa-solid fa-signature"},
                    {icon = "", title = TranslateCap("name"), input = true, inputType = "text", inputValue = Name, inputPlaceholder = Properties[Property].Name,
                     name = "setName"}, {icon = "fa-solid fa-check", title = TranslateCap("confirm"), name = "confirm"}}

  ESX.OpenContext("right", Elements, function(menu, element)
    if element.name == "confirm" then
      ESX.TriggerServerCallback("esx_property:SetPropertyName", function(Set)
        if Set then
          ESX.ShowNotification(TranslateCap("name_edit_success",menu.eles[2].inputValue), "success")
          ESX.CloseContext()
        else
          ESX.ShowNotification(TranslateCap("name_edit_error",menu.eles[2].inputValue), "error")
        end
      end, Property, menu.eles[2].inputValue)
    end
  end)
end

local SettingValue = ""

function PropertyMenuElements(PropertyId)
  local Property = Properties[PropertyId]
  local elements = {{unselectable = true, title = Property.setName ~= "" and Property.setName or Property.Name, icon = "fas fa-home"}}
  if Property.Owned then
    if Property.Locked then
      table.insert(elements, {title = TranslateCap("door_locked"), icon = "fas fa-lock", value = 'property_unlock'})
    else
      table.insert(elements, {title = TranslateCap("door_unlocked"), icon = "fas fa-unlock", value = 'property_lock'})
    end
    if ESX.PlayerData.identifier == Property.Owner then
      table.insert(elements,
        {title = TranslateCap("name_manage"), description = TranslateCap("name_manage_desc"), icon = "fa-solid fa-signature", value = 'property_name'})
    end
    if not InProperty then
      if ESX.PlayerData.identifier == Property.Owner then
        table.insert(elements, {title = TranslateCap("key_management"), description = TranslateCap("key_management_desc"), icon = "fas fa-key", value = 'property_keys'})
        table.insert(elements,
          {title = TranslateCap("sell_title"), description = TranslateCap("sell_desc", ESX.Math.GroupDigits(ESX.Round(Property.Price * 0.6))),
           icon = "fas fa-dollar-sign", value = 'property_sell'})
      end
      if Config.Raiding.Enabled and Property.Locked and ESX.PlayerData.job and ESX.GetPlayerData().job.name == "police" then
        table.insert(elements, {title = TranslateCap("raid_title"), description = TranslateCap("raid_desc"), icon = "fas fa-bomb", value = 'property_raid'})
      end
    else
      if (Config.CCTV.Enabled and Properties[PropertyId].cctv.enabled) and (ESX.PlayerData.identifier == Property.Owner or PlayerKeys[PropertyId]) then
        table.insert(elements, {title = TranslateCap("cctv_title"), description = TranslateCap("cctv_desc"), icon = "fas fa-video", value = 'property_cctv'})
      end
      if (ESX.PlayerData.identifier == Property.Owner or PlayerKeys[PropertyId]) then
        if Config.CanCustomiseInventoryAndWardrobePositions then
          if Config.OxInventory then
            table.insert(elements, {title = TranslateCap("inventory_title"), description = TranslateCap("inventory_desc"),
                                    icon = "fa-solid fa-up-down-left-right", value = 'property_inventory'})
          end
          table.insert(elements, {title = TranslateCap("wardrobe_title"), description = TranslateCap("wardrobe_desc"), icon = "fa-solid fa-up-down-left-right",
                                  value = 'property_wardrobe'})
        end
        table.insert(elements,
          {title = TranslateCap("furniture_title"), description = TranslateCap("furniture_desc"), icon = "fas fa-boxes-stacked", value = 'property_furniture'})
      end
    end
    if (not Property.Locked or Config.OwnerCanAlwaysEnter and ESX.PlayerData.identifier == Property.Owner) and not InProperty then
      table.insert(elements, {title = TranslateCap("enter_title"), icon = "fas fa-door-open", value = 'property_enter'})
    end
    if Property.Locked and not InProperty and
      not (Config.OwnerCanAlwaysEnter and ESX.PlayerData.identifier == Property.Owner or PlayerKeys[PropertyId]) then
      table.insert(elements, {title = TranslateCap("knock_title"), icon = "fa-solid fa-hand-sparkles", value = 'property_knock'})
    end
  else
    if not PM.Enabled then
      table.insert(elements,
        {title = TranslateCap("buy_title"), description = TranslateCap("buy_desc", ESX.Math.GroupDigits(ESX.Round(Property.Price))), icon = "fas fa-shopping-cart",
         value = 'property_buy'})
    else
      if ESX.PlayerData.job.name == PM.job and ESX.PlayerData.job.grade >= PM.Permissions.SellProperty then
        table.insert(elements, {title = TranslateCap("sellplayer_title"), description = TranslateCap("sellplayer_desc", ESX.Math.GroupDigits(ESX.Round(Property.Price))),
                                icon = "fas fa-shopping-cart", value = 'property_sell_re'})
      end
    end
    if not Property.Locked and not InProperty then
      table.insert(elements, {title = TranslateCap("view_title"), icon = "fas fa-door-open", value = 'property_enter'})
    end
  end

  if InProperty and (not Property.Locked or Config.CanAlwaysExit) then
    table.insert(elements, {title = TranslateCap("exit_title"), icon = "fas fa-sign-out-alt", value = 'property_exit'})
  end

  return elements
end

function OpenPropertyMenu(PropertyId)
  if SettingValue ~= "" then
    ESX.ShowNotification(TranslateCap("property_editing_error"))
    return
  end
  ESX.HideUI()
  local Property = Properties[PropertyId]
  local elements = PropertyMenuElements(PropertyId)

  ESX.OpenContext("right", elements, function(menu, element)
    if element.value == "property_unlock" then
      ESX.TriggerServerCallback("esx_property:toggleLock", function(IsUnlocked)
        if IsUnlocked then
          local eles = PropertyMenuElements(PropertyId)
          exports["esx_context"]:Refresh(eles)
        else
          ESX.ShowNotification(TranslateCap("unlock_error"), "error")
        end
      end, PropertyId)
    end
    if element.value == "property_lock" then
      ESX.TriggerServerCallback("esx_property:toggleLock", function(IsUnlocked)
        if IsUnlocked then
          local eles = PropertyMenuElements(PropertyId)
          exports["esx_context"]:Refresh(eles)
        else
          ESX.ShowNotification(TranslateCap("lock_error"), "error")
        end
      end, PropertyId)
    end
    if element.value == "property_cctv" then
      CCTV(PropertyId)
    end
    if element.value == "property_raid" then
      ESX.TriggerServerCallback("esx_property:CanRaid", function(CanRaid)
        if CanRaid then
          ESX.Progressbar(TranslateCap("prep_raid"), 15000, {FreezePlayer = true, animation = Config.Raiding.Animation, onFinish = function()
            ESX.ShowNotification(TranslateCap("raiding"), "success")
            AttemptHouseEntry(PropertyId)
          end, onCancel = function()
            ESX.ShowNotification(TranslateCap("cancel_raiding"), "error")
          end})
        else
          ESX.ShowNotification(TranslateCap("cannot_raid"), "error")
        end
      end, PropertyId)
    end
    if element.value == "property_enter" then
      ESX.CloseContext()
      AttemptHouseEntry(PropertyId)
    end
    if element.value == "property_keys" then
      ESX.CloseContext()
      ManageKeys(PropertyId)
    end
    if element.value == "property_name" then
      ESX.CloseContext()
      SetPropertyName(PropertyId)
    end
    if element.value == "property_furniture" then
      ESX.CloseContext()
      FurnitureMenu(PropertyId)
    end
    if element.value == "property_inventory" then
      ESX.CloseContext()
      ShowingUIs.Exit = false
      SettingValue = "Storage"
      Wait(20)
      ESX.TextUI(TranslateCap("storage_pos_textui"))
      while SettingValue ~= "" do
        Wait(1)
        if IsControlJustPressed(0, 47) then
          SettingValue = ""
          ESX.HideUI()
          ESX.TriggerServerCallback("esx_property:SetInventoryPosition", function(Success)
            if Success then
              ESX.ShowNotification(TranslateCap("storage_pos_success"), "success")
            else
              ESX.ShowNotification(TranslateCap("storage_pos_error"), "error")
            end
          end, PropertyId, GetEntityCoords(ESX.PlayerData.ped))
          break
        end
      end
    end
    if element.value == "property_wardrobe" then
      ESX.CloseContext()
      ShowingUIs.Exit = false
      SettingValue = "Wardrobe"
      Wait(20)
      ESX.TextUI(TranslateCap("wardrobe_pos_textui"))
      while SettingValue ~= "" do
        Wait(1)
        if IsControlJustPressed(0, 47) then
          SettingValue = ""
          ESX.HideUI()
          ESX.TriggerServerCallback("esx_property:SetWardrobePosition", function(Success)
            if Success then
              ESX.ShowNotification(TranslateCap("wardrobe_pos_success"), "success")
            else
              ESX.ShowNotification(TranslateCap("wardrobe_pos_error"), "error")
            end
          end, PropertyId, GetEntityCoords(ESX.PlayerData.ped))
          break
        end
      end
    end
    if element.value == "property_exit" then
      ESX.CloseContext()
      if SettingValue == "" then
        AttemptHouseExit(PropertyId)
      else
        ESX.ShowNotification(TranslateCap("please_finish", SettingValue))
      end
    end
    if element.value == "property_buy" then
      ESX.TriggerServerCallback("esx_property:buyProperty", function(IsBought)
        if IsBought then
          local eles = PropertyMenuElements(PropertyId)
          exports["esx_context"]:Refresh(eles)
        else
          ESX.ShowNotification(TranslateCap("cannot_afford"), "error")
        end
      end, PropertyId)
    end
    if element.value == "property_sell_re" then
      local Elements = {{unselectable = true, title = TranslateCap("select_player")}}
      ESX.TriggerServerCallback("esx_property:GetNearbyPlayers", function(Players)
        if Players then
          for i = 1, #Players do
            Elements[#Elements + 1] = {title = Players[i].name, value = Players[i].source}
          end

          ESX.OpenContext("right", Elements, function(menu, element)
            if element.value then
              ESX.TriggerServerCallback("esx_property:attemptSellToPlayer", function(IsBought)
                if IsBought then
                  local eles = PropertyMenuElements(PropertyId)
                  exports["esx_context"]:Refresh(eles)
                else
                  ESX.ShowNotification(TranslateCap("cannot_sell"), "error")
                end
              end, PropertyId, element.value)
            end
          end)
        end
      end, PropertyId)
    end
    if element.value == "property_knock" then
      ESX.ShowNotification(TranslateCap("knock_on_door"), "success")
      ESX.TriggerServerCallback("esx_property:KnockOnDoor", function(HasKnocked)
        if not HasKnocked then
          ESX.ShowNotification(TranslateCap("nobody_home"), "error")
        end
      end, PropertyId)
    end
    if element.value == "property_sell" then
      ESX.TriggerServerCallback("esx_property:sellProperty", function(IsSold)
        if IsSold then
          local eles = PropertyMenuElements(PropertyId)
          exports["esx_context"]:Refresh(eles)
        else
          ESX.ShowNotification(TranslateCap("cannot_sell"), "error")
        end
      end, PropertyId)
    end
  end, function(menu)
    CurrentDrawing.Showing = false
  end)
end

function AttemptHouseExit(PropertyId)
  local Property = Properties[PropertyId]

  ESX.ShowNotification(TranslateCap("exiting"), "success")
  FreezeEntityPosition(ESX.PlayerData.ped, true)
  InProperty = false
  CurrentId = 0
  SettingValue = ""
  ESX.HideUI()
  ESX.UI.Menu.CloseAll()
  SetRainLevel(-1)
  DoScreenFadeOut(1500)
  Wait(1500)
  TriggerServerEvent("esx_property:leave", PropertyId)
  if Shell then
    DeleteObject(Shell)
    Shell = nil
  end
  if Config.Furniture.Enabled then
    for k, v in pairs(SpawnedFurniture) do
      DeleteObject(v.obj)
    end
    SpawnedFurniture = {}
  end
  Wait(1500)
  FreezeEntityPosition(ESX.PlayerData.ped, false)
  DoScreenFadeIn(1500)
end

RegisterCommand("getoffset", function(source)
  if InProperty then
    local PlayerPed = ESX.PlayerData.ped
    local Pcoords = GetEntityCoords(PlayerPed)
    local Property = Properties[CurrentId]
    local Interior = GetInteriorValues(Property.Interior)
    print(vector3(Property.Entrance.x, Property.Entrance.y, 2000) - Pcoords)
  end
end)

function AttemptHouseEntry(PropertyId)
  local Property = Properties[PropertyId]
  local Interior = GetInteriorValues(Property.Interior)
  if Interior.type == "shell" and not Config.Shells then
    ESX.ShowNotification(TranslateCap("shell_disabled"), "error")
    return
  end
  ESX.ShowNotification(TranslateCap("entering"), "success")
  CurrentId = PropertyId
  ESX.UI.Menu.CloseAll()
  local Property = Properties[CurrentId]
  FreezeEntityPosition(ESX.PlayerData.ped, true)
  DoScreenFadeOut(1500)
  Wait(1500)
  if Interior.type == "shell" then
    ESX.Streaming.RequestModel(joaat(Property.Interior), function()
      if Shell then
        DeleteObject(Shell)
        Shell = nil
      end
      local Pos = vector3(Property.Entrance.x, Property.Entrance.y, 2000)
      Shell = CreateObjectNoOffset(joaat(Property.Interior), Pos + Interior.pos, false, false, false)
      SetEntityHeading(Shell, 0.0)
      while not DoesEntityExist(Shell) do
        Wait(1)
      end
      FreezeEntityPosition(Shell, true)
    end)
  end
  if Properties[PropertyId].furniture then
    for k, v in pairs(Properties[PropertyId].furniture) do
      ESX.Game.SpawnLocalObject(v.Name, v.Pos, function(object)
        SetEntityCoordsNoOffset(object, v.Pos.x, v.Pos.y, v.Pos.z)
        SetEntityHeading(object, v.Heading)
        SetEntityAsMissionEntity(object, true, true)
        FreezeEntityPosition(object, true)
        SpawnedFurniture[k] = {obj = object, data = v}
      end)
    end
  end
  local ShowingTextUI2 = false
  FreezeEntityPosition(ESX.PlayerData.ped, false)
  TriggerServerEvent("esx_property:enter", PropertyId)
  Wait(1500)
  DoScreenFadeIn(1800)
  InProperty = true
  if not Config.OxInventory then
    Interior.positions.Storage = nil
    Properties[CurrentId].positions.Storage = nil
  end

  CreateThread(function()
    while InProperty do
      local Property = Properties[CurrentId]
      local Sleep = 1000
      local Near = false
      SetRainLevel(0.0)
      local PlayerPed = ESX.PlayerData.ped
      local PlayerCoords = GetEntityCoords(PlayerPed)
      if Interior.type == "shell" then
        if #(PlayerCoords - vector3(Property.Entrance.x, Property.Entrance.y, 1999)) < 5.0 then
          Sleep = 0
          DrawMarker(27, vector3(Property.Entrance.x, Property.Entrance.y, 2000.2), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 200, 200,
            false, false, 2, true, nil, nil, false)
          if #(PlayerCoords.xy - vector2(Property.Entrance.x, Property.Entrance.y)) <= 2.5 then
            Near = true
            if not ShowingUIs.Exit then

              local Pname = Properties[CurrentId].setName ~= "" and Properties[CurrentId].setName or Properties[CurrentId].Name
              ESX.TextUI(TranslateCap("access_textui", Pname))
              ShowingUIs.Exit = true
            end
            if IsControlJustPressed(0, 38) then
              OpenPropertyMenu(CurrentId)
            end
          else
            if not Near and ShowingUIs.Exit and SettingValue == "" then
              ShowingUIs.Exit = false
              ESX.HideUI()
              ESX.CloseContext()
            end
          end
        end

        if Property.Owned then
          for k, v in pairs(Properties[CurrentId].positions) do
            local v = vector3(v.x, v.y, v.z)
            local CanDo = true
            if CanDo then
              local Poss = vector3(Property.Entrance.x, Property.Entrance.y, 1999) - v
              if #(PlayerCoords - Poss) < 5.0 then
                Sleep = 0
                DrawMarker(27, Poss, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 200, 50, 50, 200, false, false, 2, true, nil, nil, false)
                if #(PlayerCoords - Poss) < 2.0 and SettingValue == "" then
                  Near = true
                  if not ShowingUIs[k] then
                    ShowingUIs[k] = true

                    ESX.TextUI(TranslateCap("access_textui", k))
                  end
                  if IsControlJustPressed(0, 38) then
                    OpenInteractionMenu(CurrentId, k)
                  end
                else
                  if not Near and ShowingUIs[k] and SettingValue == "" then
                    ShowingUIs[k] = false
                    ESX.HideUI()
                  end
                end
              end
            end
          end
          if not Near and ShowingUIs and SettingValue == "" then
            ShowingTextUI2 = false
            ESX.HideUI()
          end
        end
      else
        if #(PlayerCoords - Interior.pos) < 5.0 then
          Sleep = 0
          DrawMarker(27, vector3(Interior.pos.xy, Interior.pos.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 50, 200, 200, false, false,
            2, true, nil, nil, false)
          if #(PlayerCoords - Interior.pos) < 2.0 then
            if not ShowingUIs.Exit then
              ShowingUIs.Exit = true
              local Pname = Properties[CurrentId].setName ~= "" and Properties[CurrentId].setName or Properties[CurrentId].Name
              ESX.TextUI(TranslateCap("access_textui", Pname))
            end
            if IsControlJustPressed(0, 38) then
              OpenPropertyMenu(CurrentId)
            end
          else
            if ShowingUIs.Exit and SettingValue == "" then
              ShowingUIs.Exit = false
              ESX.HideUI()
              ESX.CloseContext()
            end
          end
        end

        if Property.Owned then
          for k, v in pairs(Properties[CurrentId].positions) do
            v = vector3(v.x, v.y, v.z)
            local CanDo = true

            if CanDo then
              if #(PlayerCoords - v) < 5.0 then
                Sleep = 0
                DrawMarker(27, vector3(v.xy, v.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 200, 50, 50, 200, false, false, 2, true, nil,
                  nil, false)
                if #(PlayerCoords - v) < 2.0 then
                  if not ShowingUIs[k] then
                    ShowingUIs[k] = true
                    ESX.TextUI(TranslateCap("access_textui", k))
                  end
                  if IsControlJustPressed(0, 38) then
                    OpenInteractionMenu(CurrentId, k)
                  end
                else
                  if ShowingUIs[k] and SettingValue == "" then
                    ShowingUIs[k] = false
                    ESX.HideUI()
                  end
                end
              end
            end
          end
        end
      end
      Wait(Sleep)
    end
  end)
end

function StoreVehicle(PropertyId)
  local Vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
  if Vehicle then
    local VehProperties = ESX.Game.GetVehicleProperties(Vehicle)
    VehProperties.DisplayName = GetLabelText(GetDisplayNameFromVehicleModel(VehProperties.model))
    ESX.TriggerServerCallback("esx_property:StoreVehicle", function(result)
      if result then
        SetEntityAsMissionEntity(Vehicle, true, true)
        DeleteVehicle(Vehicle)
        ESX.ShowNotification(TranslateCap("store_success"), "success")
        return
      else
        ESX.ShowNotification(TranslateCap("store_error"), "error")
        return
      end
    end, PropertyId, VehProperties)
  end
end

function AccessGarage(PropertyId)
  ESX.TriggerServerCallback("esx_property:AccessGarage", function(Vehicles)
    if Vehicles then
      local elements = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("property_garage")}}
      for k, v in pairs(Vehicles) do
        elements[#elements + 1] = {title = v.vehicle.DisplayName .. " | " .. v.vehicle.plate, Properties = v.vehicle, index = k}
      end
      ESX.OpenContext("right", elements, function(menu, element)
        if element.Properties then
          ESX.CloseContext()
          ESX.ShowNotification(TranslateCap("retriving_notify",element.Properties.DisplayName))
          if ESX.Game.IsSpawnPointClear(vector3(Properties[PropertyId].garage.pos.x, Properties[PropertyId].garage.pos.y,
            Properties[PropertyId].garage.pos.z), 3.0) then
            ESX.Game.SpawnVehicle(element.Properties.model, Properties[PropertyId].garage.pos, Properties[PropertyId].garage.Heading,
              function(vehicle)
                SetEntityAsMissionEntity(vehicle, true, true)
                ESX.Game.SetVehicleProperties(vehicle, element.Properties)
                TaskWarpPedIntoVehicle(ESX.PlayerData.ped, vehicle, -1)
                SetModelAsNoLongerNeeded(element.Properties.model)
                TriggerServerEvent("esx_property:SetVehicleOut", PropertyId, element.index)
              end)
          end
        end
      end)
    else
      ESX.ShowNotification(TranslateCap("cannot_access"), "error")
      return
    end
  end, PropertyId)
end

CreateThread(function()
  local ShowingTextUI = false
  while true do
    local Sleep = 2000

    if #(Properties) > 0 then
      Sleep = 800
      local nearby = false
      for i = 1, #(Properties) do
        if Properties[i].Entrance then
          local GetEntityCoords = GetEntityCoords
          local IsControlJustPressed = IsControlJustPressed
          local DrawMarker = DrawMarker
          local Coords = GetEntityCoords(ESX.PlayerData.ped)
          local Entrance = vector3(Properties[i].Entrance.x, Properties[i].Entrance.y, Properties[i].Entrance.z)
          if not InCCTV then
            if #(Coords - Entrance) < 10.0 then
              Sleep = 0
              DrawMarker(27, Entrance, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 200, 50, 200, false, false, 2, true, nil, nil, false)
              if #(Coords - Entrance) < 1.5 then
                nearby = true
                local PropertyName = Properties[i].setName ~= "" and Properties[i].setName or Properties[i].Name
                if not CurrentDrawing.Showing or CurrentDrawing.Name ~= PropertyName then
                  CurrentDrawing.Name = PropertyName
                  CurrentDrawing.Showing = true
                  ESX.TextUI(TranslateCap("access_textui", PropertyName))
                end
                if IsControlJustPressed(0, 38) then
                    OpenPropertyMenu(i)
                end
              end
            end
          end
          if Properties[i].garage.enabled and Properties[i].garage.pos and (ESX.PlayerData.identifier == Properties[i].Owner or PlayerKeys[i]) then
            local Garage = vector3(Properties[i].garage.pos.x, Properties[i].garage.pos.y, Properties[i].garage.pos.z)
            if #(Coords - Garage) < 10.0 then
              Sleep = 0
              DrawMarker(36, Garage, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 50, 200, 50, 200, false, false, 2, true, nil, nil, false)
              if #(Coords - Garage) < 3.0 then
                nearby = true
                if GetVehiclePedIsUsing(ESX.PlayerData.ped) ~= 0 then
                  local veh = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
                  local vehmodel = GetEntityModel(veh)
                  local DisplayName = GetLabelText(GetDisplayNameFromVehicleModel(vehmodel))
                  if not CurrentDrawing.Showing or CurrentDrawing.Name ~= DisplayName then
                    CurrentDrawing.Name = DisplayName
                    CurrentDrawing.Showing = true
                    ESX.TextUI(TranslateCap("store_textui", DisplayName))
                  end
                else
                  if not CurrentDrawing.Showing or CurrentDrawing.Name ~= "Garage" then
                    CurrentDrawing.Name = "Garage"
                    CurrentDrawing.Showing = true
                    ESX.TextUI(TranslateCap("access_textui", "garage"))
                  end
                end
                if IsControlJustPressed(0, 38) then
                  if GetVehiclePedIsUsing(ESX.PlayerData.ped) ~= 0 then
                    StoreVehicle(i)
                  else
                    AccessGarage(i)
                  end
                end
              end
            end
          end
        end
      end
      if not nearby and CurrentDrawing.Showing and SettingValue == "" then
        ESX.HideUI()
        CurrentDrawing.Showing = false
        ESX.CloseContext()
      end
    end
    Wait(Sleep)
  end
end)

function OpenPMQuickMenu(Action)
  if Action == "Entrance" then
    DoScreenFadeOut(1500)
    Wait(1500)
    ESX.TriggerServerCallback("esx_property:PMenterOffice", function(HasEntered)
      if HasEntered then
        ESX.ShowNotification(TranslateCap("enter_office"), "success")
      else
        ESX.ShowNotification(TranslateCap("enter_office_error"), "error")
      end
      Wait(1500)
      DoScreenFadeIn(1500)
    end)
  elseif Action == "Exit" then
    DoScreenFadeOut(1500)
    Wait(1500)
    ESX.TriggerServerCallback("esx_property:PMexitOffice", function(HasExited)
      if HasExited then
        ESX.ShowNotification(TranslateCap("exit_office"), "success")
      else
        ESX.ShowNotification(TranslateCap("exit_office_error"), "error")
      end
      Wait(1500)
      DoScreenFadeIn(1500)
    end)
  elseif Action == "Properties" then
    TriggerEvent("esx_property:AdminMenu")

  elseif Action == "ActionsMenu" then
    local elements = {{unselectable = true, title = TranslateCap("actions"), value = "RealEstateActions"}}

    if ESX.PlayerData.job.name == PM.job then
      if ESX.PlayerData.job.grade >= PM.Permissions.CreateProperty then
        elements[#elements + 1] = {title = TranslateCap("property_create"), value = "CreateProperty"}
      end
      if ESX.PlayerData.job.grade >= PM.Permissions.ManagePropertiesFromQuickActions then
        elements[#elements + 1] = {title = TranslateCap("property_manage"), value = "manage"}
      end
    end
    ESX.OpenContext("right", elements, function(menu, element)
      if element.value == "CreateProperty" then
        TriggerEvent("esx_property:CreateProperty")
      end
      if element.value == "manage" then
        TriggerEvent("esx_property:AdminMenu")
      end
    end)
  end
end

ESX.RegisterInput(TranslateCap("realestate_command"), TranslateCap("realestate_command_desc"), "keyboard", "F5", function()
  ESX.TriggerServerCallback('esx_property:CanAccessRealEstateMenu', function(Access)
    if Access then
      OpenPMQuickMenu("ActionsMenu")
    end
  end)
end)

local PMdrawing = {Entrance = false, Exit = false}
CreateThread(function()
  while PM.Enabled do
    local Sleep = 2500
    local DrawMarker = DrawMarker
    if ESX.IsPlayerLoaded() then
      if ESX.PlayerData.job and ESX.PlayerData.job.name == PM.job then
        Sleep = 1500

        local Coords = GetEntityCoords(ESX.PlayerData.ped)
        local nearby = false

        for k, v in pairs(PM.Locations) do
          local Dist = #(Coords - v)
          if Dist <= 10.0 then
            nearby = true
            Sleep = 0
            DrawMarker(27, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 50, 200, 50, 200, false, false, 2, true, nil, nil, false)
            if Dist <= 1.5 then
              if not PMdrawing[k] then
                PMdrawing[k] = true
                ESX.TextUI(TranslateCap("realestate_textui", k))
              end
              if IsControlJustPressed(0, 38) then
                OpenPMQuickMenu(k)
              end
            end
          else
            if not nearby and PMdrawing[k] then
              ESX.HideUI()
              PMdrawing[k] = false
              ESX.CloseContext()
            end
          end
        end
      end
    end
    Wait(Sleep)
  end
end)

local HouseData = {}

RegisterNetEvent("esx_property:CreateProperty", function()
  ESX.TriggerServerCallback('esx_property:CanCreateProperty', function(data)
    if data then
      local GetEntityCoords = GetEntityCoords
      local GetStreetNameAtCoord = GetStreetNameAtCoord
      local GetStreetNameFromHashKey = GetStreetNameFromHashKey
      local Pcoords = GetEntityCoords(ESX.PlayerData.ped)
      local StreetHash = GetStreetNameAtCoord(Pcoords.x, Pcoords.y, Pcoords.z)
      local StreetName = GetStreetNameFromHashKey(StreetHash)
      local Zone = GetZoneAtCoords(Pcoords.x, Pcoords.y, Pcoords.z)
      local ZoneScum = GetZoneScumminess(Zone)
      local SuggestedPrice = Config.ZonePriceOptions.Enabled and Config.ZonePriceOptions.Default * Config.ZonePrices[ZoneScum] or nil
      HouseData = {}
      local Property = {{unselectable = true, icon = "fas fa-plus", title = TranslateCap("menu_title")},
                        {value = 0, title = TranslateCap("element_title1"), icon = "fas fa-list-ol", description = TranslateCap("element_description1"), input = true,
                         inputType = "number", inputPlaceholder = "Number...", inputValue = nil, inputMin = 1, inputMax = 90000, index = "hnumber"},
                        {title = TranslateCap("element_title2"), icon = "fas fa-dollar-sign", input = true, inputType = "number",description = TranslateCap("element_description2"),
                         inputPlaceholder = "Price...", inputValue = SuggestedPrice, inputMin = 1, inputMax = 900000000, index = "price"},
                        {title = TranslateCap("element_title3"), description = TranslateCap("element_description3"), icon = "fas fa-home", index = "interior"},
                        {title = TranslateCap("element_title4"), description = TranslateCap("element_description4"), icon = "fas fa-warehouse", value = {enabled = false},
                         index = "garage", disabled = not (Config.Garage.Enabled)},
                        {title = TranslateCap("element_title5"), description = TranslateCap("element_description5"), icon = "fas fa-video",
                         value = {enabled = false, rot = GetGameplayCamRot(2), maxleft = 80, maxright = -20}, index = "cctv",
                         disabled = not (Config.CCTV.Enabled)},
                        {title = TranslateCap("element_title6"),description = TranslateCap("element_description6"), icon = "fas fa-map-marker-alt", index = "entrance"},
                        {title = TranslateCap("element_create_title"), icon = "fas fa-check", description = TranslateCap("element_create_desc_1"), index = "creation"}}
      local function OpenCreate()
        local opos = {}
        ESX.OpenContext("right", Property, function(menu, element)
          if menu.eles[2] and menu.eles[2].inputValue and menu.eles[1].title == TranslateCap("menu_title") then
            Property[2].inputValue = menu.eles[2].inputValue
            HouseData.name = menu.eles[2].inputValue .. " " .. StreetName
          end
          if menu.eles[3] and menu.eles[3].inputValue and menu.eles[1].title ==  TranslateCap("menu_title") then
            Property[3].inputValue = menu.eles[3].inputValue
            HouseData.price = menu.eles[3].inputValue
          end
          if element.index then
            if element.index == "entrance" then
              local PlayerPos = GetEntityCoords(ESX.PlayerData.ped)
              HouseData.entrance = {x = ESX.Math.Round(PlayerPos.x, 2), y = ESX.Math.Round(PlayerPos.y, 2), z = ESX.Math.Round(PlayerPos.z, 2) - 0.98}
              Property[7].title = TranslateCap("entrance_set_title")
              Property[7].description = TranslateCap("entrance_set_description",HouseData.entrance.x, HouseData.entrance.y, HouseData.entrance.z)
              OpenCreate()
            end
            if element.index == "selectedinterior" then
              HouseData.interior = element.value
              Property[4].title = TranslateCap("interior_set_title")
              Property[4].description = TranslateCap("interior_set_description",element.title)
              OpenCreate()
            end
            if element.index == "IPL" then
              local ints = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("ipl_title")}}
              for i = 1, #(Config.Interiors.IPL) do
                ints[#ints + 1] = {title = Config.Interiors.IPL[i].label, index = "selectedinterior", value = Config.Interiors.IPL[i].value}
                exports["esx_context"]:Refresh(ints, "right")
              end
            end
            if element.index == "Shells" then
              local ints = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("shell_title")}}
              for i = 1, #(Config.Interiors.Shells) do
                ints[#ints + 1] = {title = Config.Interiors.Shells[i].label, index = "selectedinterior", value = Config.Interiors.Shells[i].value}
                exports["esx_context"]:Refresh(ints, "right")
              end
            end
            if element.index == "interior" then
              local catsa = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("types_title")},
                             {title = TranslateCap("ipl_title"), description = TranslateCap("ipl_description"), index = "IPL"}}
              if Config.Shells then
                catsa[3] = {title = TranslateCap("shell_title"), description = TranslateCap("shell_description"), index = "Shells"}
              end
              exports["esx_context"]:Refresh(catsa, "right")
            end
            if element.index == "return" then
              OpenCreate()
            end
            if element.index == "cctv" then
              local status = Property[6].value.enabled and TranslateCap("enabled") or TranslateCap("disabled")
              opos = {{unselectable = true, icon = "fas fa-video", title = TranslateCap("cctv_settings")},
                      {title = TranslateCap("toggle_title"), icon = status == TranslateCap("enabled") and "fas fa-eye" or "fas fa-eye-slash",
                       description = TranslateCap("toggle_description",status), index = "ToggleCCTV"},
                      {title = TranslateCap("cctv_set_title"), icon = "fas fa-rotate", disabled = not Property[6].value.enabled,
                       description = TranslateCap("cctv_set_description"), index = "SetCCTVangle"},
                      {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = TranslateCap("back_description"), index = "return"}}
              exports["esx_context"]:Refresh(opos, "right")
            end
            if element.index == "ToggleCCTV" then
              Property[6].value.enabled = not Property[6].value.enabled
              local status = Property[6].value.enabled and TranslateCap("enabled") or TranslateCap("disabled")
              opos = {{unselectable = true, icon = "fas fa-video", title = TranslateCap("cctv_settings")},
                      {title = TranslateCap("toggle_title"), icon = status == TranslateCap("enabled") and "fas fa-eye" or "fas fa-eye-slash",
                       description = TranslateCap("toggle_description",status), index = "ToggleCCTV"},
                      {title = TranslateCap("cctv_set_title"), icon = "fas fa-rotate", disabled = not Property[6].value.enabled,
                       description = TranslateCap("cctv_set_description"), index = "SetCCTVangle"},
                      {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = TranslateCap("back_description"), index = "return"}}
              exports["esx_context"]:Refresh(opos, "right")
            end
            if Config.Garage.Enabled and element.index == "garage" then
              local status = Property[5].value.enabled and TranslateCap("enabled") or TranslateCap("disabled")
              opos = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("garage_settings")},
                      {title = TranslateCap("toggle_title"), icon = status == TranslateCap("enabled") and "fa-solid fa-toggle-on" or "fa-solid fa-toggle-off",
                       description = TranslateCap("toggle_description",status), index = "ToggleGarage"}}
              if Property[5].value.enabled then
                opos[#opos + 1] = {title = TranslateCap("garage_set_title"), icon = "fas fa-map-marker-alt", disabled = not Property[5].value.enabled,
                                   description = TranslateCap("garage_set_description"), index = "SetGaragePos"}
                if Property[5].value.pos then
                  opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = TranslateCap("back_description"), index = "return"}
                end
              else
                opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = TranslateCap("back_description"), index = "return"}
              end
              exports["esx_context"]:Refresh(opos, "right")
            end
            if element.index == "ToggleGarage" then
              Property[5].value.enabled = not Property[5].value.enabled
              local status = Property[5].value.enabled and TranslateCap("enabled") or TranslateCap("disabled")
              opos = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("garage_settings")},
                      {title = TranslateCap("toggle_title"), icon = status == TranslateCap("enabled") and "fa-solid fa-toggle-on" or "fa-solid fa-toggle-off",
                       description = TranslateCap("toggle_description",status), index = "ToggleGarage"}}
              if Property[5].value.enabled then
                opos[#opos + 1] = {title = TranslateCap("garage_set_title"), icon = "fas fa-map-marker-alt", disabled = not Property[5].value.enabled,
                                   description = TranslateCap("garage_set_description"), index = "SetGaragePos"}
              else
                opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = TranslateCap("back_description"), index = "return"}
              end
              exports["esx_context"]:Refresh(opos, "right")
            end
            if element.index == "SetGaragePos" then
              ESX.CloseContext()
              ESX.TextUI(TranslateCap("garage_textui"))
              while true do
                Wait(0)
                if IsControlJustPressed(0, 38) then
                  local PlayerPos = GetEntityCoords(ESX.PlayerData.ped)
                  Property[5].value.pos = GetEntityCoords(ESX.PlayerData.ped)
                  Property[5].value.heading = GetEntityHeading(ESX.PlayerData.ped)
                  ESX.HideUI()
                  OpenCreate()
                  break
                end
              end
            end
            if element.index == "SetCCTVangle" then
              ESX.CloseContext()
              ESX.TextUI(TranslateCap("cctv_textui_1"))
              local stage = "angle"
              while true do
                Wait(0)
                if IsControlJustPressed(0, 38) then
                  if stage == "angle" then
                    Property[6].value.rot = GetGameplayCamRot(2)
                    ESX.TextUI(TranslateCap("cctv_textui_2"))
                    stage = "maxright"
                  elseif stage == "maxright" then
                    Property[6].value.maxright = GetGameplayCamRot(2).z
                    ESX.TextUI(TranslateCap("cctv_textui_3"))
                    stage = "maxleft"
                  elseif stage == "maxleft" then
                    Property[6].value.maxleft = GetGameplayCamRot(2).z
                    ESX.HideUI()
                    OpenCreate()
                    break
                  end
                end
              end
            end
            if element.index == "creation" then
              if HouseData.price and HouseData.name and HouseData.entrance and HouseData.interior then
                local newProperty = {name = HouseData.name, price = HouseData.price, interior = HouseData.interior, entrance = HouseData.entrance,
                                     cctv = Property[6].value, garage = Property[5].value}
                TriggerServerEvent("esx_property:server:createProperty", newProperty)
                ESX.ShowNotification(TranslateCap("create_success"), "success")
                ESX.CloseContext()
                HouseData = {}
              else
                ESX.ShowNotification(TranslateCap("missing_data"), "error")
              end
            end
          end
        end)
      end
      OpenCreate()
    end
  end)
end)

RegisterNetEvent("esx_property:AdminMenu", function()
  ESX.TriggerServerCallback('esx_property:IsAdmin', function(data)
    if data then

      function ManageProperty(currentProperty)
        local Interior = GetInteriorValues(Properties[currentProperty].Interior)
        ESX.TriggerServerCallback('esx_property:IsAdmin', function(data)
          if data then
            local opos = {}
            local function GetData()
              local elements = {{unselectable = true, icon = "fas fa-cogs", title = "Property Management"},
                                {title = TranslateCap("back"), icon = "fas fa-arrow-left", value = "back"},
                                {title = "Toggle Lock", icon = (Properties[currentProperty].Locked and "fas fa-lock") or "fas fa-unlock",
                                 description = "Lock/Unlock The Property.", value = "lock"},
                                {title = "Enter", description = "Force Entry Into The Property.", icon = "fas fa-door-open", value = "enter"},
                                {title = "Price", icon = "fas fa-dollar-sign", description = "Alter The Price Of The Property.", value = "price"},
                                {title = "Set Interior", description = "Renovate The Property`s Interior.", icon = "fas fa-home", value = "interior"},
                                {title = "Entrance", description = "Set The Entrance As Your Position.", icon = "fas fa-map-marker-alt",
                                 value = "entrance"}}
              if Properties[currentProperty].setName ~= "" then
                elements[#elements + 1] = {title = "Clear Custom Name", icon = "fa-solid fa-ban",
                                           description = "Current Name: " .. Properties[currentProperty].setName, value = "remove_custom_name"}
              end
              if Config.Furniture.Enabled and #(Properties[currentProperty].furniture) > 0 then
                elements[#elements + 1] = {title = "Reset Furniture", description = "Delete All Property Furniture", icon = "fas fa-eraser",
                                           value = "refurni"}
              end
              if Config.Garage.Enabled then
                elements[#elements + 1] = {title = "Garage", description = "Change Garage Settings", icon = "fa-solid fa-warehouse", value = "garage"}
              end
              if Config.CCTV.Enabled then
                elements[#elements + 1] = {title = "CCTV", description = "Change CCTV Settings", icon = "fa-solid fa-camera", value = "cctv"}
              end
              if (Config.OxInventory) and Properties[currentProperty].positions.Storage and
                (ESX.Round(Interior.positions.Storage.x, 2) ~= Properties[currentProperty].positions.Storage.x or
                  ESX.Round(Interior.positions.Storage.y, 2) ~= Properties[currentProperty].positions.Storage.y) then
                elements[#elements + 1] = {title = "Reset Storage Position", description = "Set Storage Position To Interior Default.",
                                           icon = "fas fa-eraser", value = "restorage"}
              end
              if Interior.positions.Wardrobe then
                if ESX.Round(Interior.positions.Wardrobe.x, 2) ~= ESX.Round(Properties[currentProperty].positions.Wardrobe.x, 2) or
                  ESX.Round(Interior.positions.Wardrobe.y, 2) ~= ESX.Round(Properties[currentProperty].positions.Wardrobe.y, 2) then
                  elements[#elements + 1] = {title = "Reset Wardrobe Position", description = "Set Wardrobe Position To Interior Default.",
                                             icon = "fas fa-eraser", value = "rewardrobe"}
                end
              end
              if Properties[currentProperty].Owned then
                elements[#elements + 1] = {title = "Remove Owner", icon = "fas fa-user-times", description = "Evict The Owner Of The Property.",
                                           value = "removeowner"}
              end
              return elements
            end
            ESX.OpenContext("right", GetData(), function(menu, element)
              if element.value then
                if element.value == "lock" then
                  ESX.TriggerServerCallback("esx_property:toggleLock", function(IsUnlocked)
                    if IsUnlocked then
                      ESX.ShowNotification("Lock Toggled!", "success")
                      exports["esx_context"]:Refresh(GetData())
                    else
                      ESX.ShowNotification("You Cannot Lock This Property", "error")
                    end
                  end, currentProperty)
                end
                if element.value == "enter" then
                  AttemptHouseEntry(currentProperty)
                end
                if element.value == "removeowner" then
                  ESX.TriggerServerCallback("esx_property:evictOwner", function(Evicted)
                    if Evicted then
                      ESX.ShowNotification("Owner Evicted!", "success")
                      exports["esx_context"]:Refresh(GetData())
                    else
                      ESX.ShowNotification("You Cannot Evict This Owner!", "error")
                    end
                  end, currentProperty)
                end
                if element.value == "garage" then
                  local status = Properties[currentProperty].garage.enabled and TranslateCap("enabled") or TranslateCap("disabled")
                  opos = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("garage_settings")},
                          {title = "Toggle Usage", icon = status == TranslateCap("enabled") and "fa-solid fa-toggle-on" or "fa-solid fa-toggle-off",
                           description = "Current Status: " .. status, value = "ToggleGarage"}}
                  if Properties[currentProperty].garage.enabled then
                    opos[#opos + 1] = {title = "Set Position", icon = "fas fa-map-marker-alt",
                                       disabled = not Properties[currentProperty].garage.enabled,
                                       description = "Sets the Garage Position to your Players Position", value = "SetGaragePos"}
                    if Properties[currentProperty].garage.pos then
                      opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management.",
                                         value = "return"}
                    end
                  else
                    opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management", value = "return"}
                  end
                  exports["esx_context"]:Refresh(opos, "right")
                end
                if element.value == "cctv" then
                  local status = Properties[currentProperty].cctv.enabled and TranslateCap("enabled") or TranslateCap("disabled")
                  opos = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("cctv_settings")},
                          {title = "Toggle Usage", icon = status == TranslateCap("enabled") and "fa-solid fa-toggle-on" or "fa-solid fa-toggle-off",
                           description = "Current Status: " .. status, value = "ToggleCCTV"}}
                  if Properties[currentProperty].cctv.enabled then
                    opos[#opos + 1] = {title = "Set Angle", icon = "fas fa-map-marker-alt", disabled = not Properties[currentProperty].cctv.enabled,
                                       description = "Sets the Angle of the Camera.", value = "SetCCTVangle"}
                    if Properties[currentProperty].cctv.rot then
                      opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management.",
                                         value = "return"}
                    end
                  else
                    opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management", value = "return"}
                  end
                  exports["esx_context"]:Refresh(opos, "right")
                end
                if element.value == "ToggleGarage" then
                  ESX.TriggerServerCallback("esx_property:toggleGarage", function(IsUnlocked, enabled)
                    if IsUnlocked then
                      ESX.ShowNotification("Garage Toggled!", "success")
                      local status = enabled and TranslateCap("enabled") or TranslateCap("disabled")
                      opos = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("garage_settings")},
                              {title = "Toggle Usage", icon = status == TranslateCap("enabled") and "fa-solid fa-toggle-on" or "fa-solid fa-toggle-off",
                               description = "Current Status: " .. status, value = "ToggleGarage"}}
                      if enabled then
                        opos[#opos + 1] = {title = "Set Position", icon = "fas fa-map-marker-alt", disabled = not enabled,
                                           description = "Sets the Garage Position to your Players Position", value = "SetGaragePos"}
                        if Properties[currentProperty].garage.pos then
                          opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management.",
                                             value = "return"}
                        end
                      else
                        opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management",
                                           value = "return"}
                      end
                      exports["esx_context"]:Refresh(opos, "right")
                    else
                      ESX.ShowNotification("You ~r~Cannot~s~ Toggle This Option!", "error")
                    end
                  end, currentProperty)
                end
                if element.value == "ToggleCCTV" then
                  ESX.TriggerServerCallback("esx_property:toggleCCTV", function(IsUnlocked, enabled)
                    if IsUnlocked then
                      ESX.ShowNotification("CCTV Toggled!", "success")
                      local status = enabled and TranslateCap("enabled") or TranslateCap("disabled")
                      opos = {{unselectable = true, icon = "fas fa-warehouse", title = TranslateCap("cctv_settings")},
                              {title = "Toggle Usage", icon = status == TranslateCap("enabled") and "fa-solid fa-toggle-on" or "fa-solid fa-toggle-off",
                               description = "Current Status: " .. status, value = "ToggleCCTV"}}
                      if enabled then
                        opos[#opos + 1] = {title = "Set Angle", icon = "fas fa-map-marker-alt", disabled = not enabled,
                                           description = "Sets the Angle of the Camera.", value = "SetCCTVangle"}
                        if Properties[currentProperty].cctv.rot then
                          opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management.",
                                             value = "return"}
                        end
                      else
                        opos[#opos + 1] = {title = TranslateCap("back"), icon = "fas fa-arrow-left", description = "return to Property Management",
                                           value = "return"}
                      end
                      exports["esx_context"]:Refresh(opos, "right")
                    else
                      ESX.ShowNotification("You ~r~Cannot~s~ Toggle This Option!", "error")
                    end
                  end, currentProperty)
                end
                if element.value == "SetGaragePos" then
                  ESX.CloseContext()
                  ESX.TextUI("Press ~b~[E]~s~ to Set Position")
                  SettingValue = "Garage"
                  while SettingValue ~= "" do
                    Wait(0)
                    if IsControlJustPressed(0, 38) then
                      ESX.TriggerServerCallback("esx_property:SetGaragePos", function(IsChanged)
                        if IsChanged then
                          ESX.HideUI()
                          SettingValue = ""
                          ESX.ShowNotification("Position Changed!", "success")
                          ManageProperty(currentProperty)
                        else
                          ESX.ShowNotification("You ~r~Cannot~s~ Change This Option!", "error")
                        end
                      end, currentProperty, GetEntityHeading(ESX.PlayerData.ped))
                      break
                    end
                  end
                end
                if element.value == "SetCCTVangle" then
                  ESX.CloseContext()
                  ESX.TextUI("Press ~b~[E]~s~ to Set Angle")
                  local stage = "angle"
                  SettingValue = "cctv"
                  local Angles = {}
                  while stage do
                    Wait(0)
                    if IsControlJustPressed(0, 38) then
                      if stage == "angle" then
                        Angles.rot = GetGameplayCamRot(2)
                        ESX.TextUI("Press ~b~[E]~s~ to Set Max Right Roation")
                        stage = "maxright"
                      elseif stage == "maxright" then
                        Angles.maxright = GetGameplayCamRot(2).z
                        ESX.TextUI("Press ~b~[E]~s~ to Set Max Left Roation")
                        stage = "maxleft"
                      elseif stage == "maxleft" then
                        Angles.maxleft = GetGameplayCamRot(2).z
                        ESX.TriggerServerCallback("esx_property:SetCCTVangle", function(IsChanged)
                          if IsChanged then
                            SettingValue = ""
                            stage = nil
                            ESX.HideUI()
                            ESX.ShowNotification("Angle Changed!", "success")
                            ManageProperty(currentProperty)
                          else
                            ESX.ShowNotification("You ~r~Cannot~s~ Change This Option!", "error")
                          end
                        end, currentProperty, Angles)
                        break
                      end
                    end
                  end
                end
                if element.value == "remove_custom_name" then
                  ESX.TriggerServerCallback("esx_property:RemoveCustomName", function(Cleared)
                    if Cleared then
                      ESX.ShowNotification("Property Name Reset!", "success")
                      exports["esx_context"]:Refresh(GetData())
                    else
                      ESX.ShowNotification("You Cannot Reset This Property`s Name!", "error")
                    end
                  end, currentProperty)
                end
                if element.value == "refurni" then
                  ESX.TriggerServerCallback("esx_property:RemoveAllfurniture", function(Removed)
                    if Removed then
                      ESX.ShowNotification("Furniture Reset!", "success")
                      exports["esx_context"]:Refresh(GetData())
                    else
                      ESX.ShowNotification("You Cannot Reset This Property!", "error")
                    end
                  end, currentProperty)
                end
                if element.value == "restorage" then
                  ESX.TriggerServerCallback("esx_property:SetInventoryPosition", function(Reset)
                    if Reset then
                      ESX.ShowNotification("~b~Storage~s~ Position Reset!", "success")
                      exports["esx_context"]:Refresh(GetData())
                    else
                      ESX.ShowNotification("You Cannot Reset This Property!", "error")
                    end
                  end, currentProperty, Interior.positions.Storage, true)
                end
                if element.value == "rewardrobe" then
                  ESX.TriggerServerCallback("esx_property:SetWardrobePosition", function(Reset)
                    if Reset then
                      ESX.ShowNotification("~b~Wardrobe~s~ Position Reset!", "success")
                      exports["esx_context"]:Refresh(GetData())
                    else
                      ESX.ShowNotification("You Cannot Reset This Property!", "error")
                    end
                  end, currentProperty, Interior.positions.Wardrobe, true)
                end
                if element.value == "back" then
                  AdminOptions(currentProperty)
                end
                if element.value == "return" then
                  exports["esx_context"]:Refresh(GetData())
                end
                if element.value == "price" then
                  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'PropertyPrice', {title = "Property Price"}, function(data4, menu4)
                    if data4.value then
                      ESX.TriggerServerCallback("esx_property:ChangePrice", function(IsChanged)
                        if IsChanged then
                          ESX.ShowNotification("Price Changed!", "success")
                          menu4.close()
                        else
                          ESX.ShowNotification("You Cannot Change this property!", "error")
                        end
                      end, currentProperty, tonumber(data4.value))
                    end
                  end, function(data4, menu4)
                    menu4.close()
                  end)
                end
                if element.value == "interior" then
                  local elements = {{unselectable = true, icon = "fas fa-warehouse", title = "Interior Types"},
                                    {title = "IPL Interiors", description = "Native GTA Interiors, Made by R*", value = "IPL"}}
                  if Config.Shells then
                    elements[3] = {title = "Custom Interiors", description = "Custom Interiors, Made by You", value = "Shells"}
                  end
                  ESX.OpenContext("right", elements, function(menu, element)
                    if element.value then
                      local elements = {{unselectable = true, icon = "fas fa-warehouse", title = "Interiors"}}
                      for i = 1, #(Config.Interiors[element.value]) do
                        elements[#elements + 1] = {title = Config.Interiors[element.value][i].label, value = Config.Interiors[element.value][i].value}
                      end
                      ESX.OpenContext("right", elements, function(menu, element)
                        if element.value then
                          ESX.TriggerServerCallback("esx_property:ChangeInterior", function(IsChanged)
                            if IsChanged then
                              ESX.ShowNotification("Interior Changed!", "success")
                              ESX.CloseContext()
                            else
                              ESX.ShowNotification("You Cannot Change this property!", "error")
                            end
                          end, currentProperty, element.value)
                        end
                      end)
                    end
                  end, function()
                    ManageProperty(currentProperty)
                  end)
                end
                if element.value == "entrance" then
                  ESX.TriggerServerCallback("esx_property:ChangeEntrance", function(IsChanged)
                    if IsChanged then
                      ESX.ShowNotification("Entrance Changed!", "success")
                    else
                      ESX.ShowNotification("You Cannot Change this property!", "error")
                    end
                  end, currentProperty, GetEntityCoords(ESX.PlayerData.ped))
                end
              end
            end)
          end
        end)
      end

      function AdminOptions(currentProperty)
        ESX.TriggerServerCallback('esx_property:IsAdmin', function(data)
          if data then
            local elements = {{unselectable = true, icon = "fas fa-home", title = "Property Options"},
                              {title = TranslateCap("back"), icon = "fas fa-arrow-left", value = "back"},
                              {title = "Manage", icon = "fas fa-cogs", description = "Alter This Property's Settings.", value = "manage"},
                              {title = "Teleport", description = "Teleport To This Property.", icon = "fas fa-map-marker-alt", value = "goto"},
                              {title = "Set GPS", description = "Set GPS position To Property.", icon = "fa-solid fa-location-dot", value = "gps"},
                              {title = "Delete", icon = "fas fa-trash-alt", description = "Remove Current Property.", value = "delete"}}

            ESX.OpenContext("right", elements, function(menu, element)
              if element.value then
                if element.value == "goto" then
                  SetEntityCoords(ESX.PlayerData.ped, Properties[currentProperty].Entrance.x, Properties[currentProperty].Entrance.y,
                    Properties[currentProperty].Entrance.z)
                  ESX.ShowNotification("Teleported to Property!")
                end
                if element.value == "gps" then
                  SetNewWaypoint(Properties[currentProperty].Entrance.x, Properties[currentProperty].Entrance.y)
                  ESX.ShowNotification("GPS Set!")
                end
                if element.value == "back" then
                  AdminMenu()
                end
                if element.value == "delete" then
                  ESX.TriggerServerCallback("esx_property:deleteProperty", function(response)
                    if response then
                      ESX.ShowNotification("Property Deleted!", "success")
                      ESX.CloseContext()
                    else
                      ESX.ShowNotification("You Cannot Delete This Property", "error")
                    end
                  end, currentProperty)
                end

                if element.value == "manage" then
                  ManageProperty(currentProperty)
                end
              end
            end)
          end
        end)
      end

      function AdminMenu()
        ESX.TriggerServerCallback('esx_property:IsAdmin', function(data)
          if data then
            local elements = {{unselectable = true, icon = "fas fa-home", title = "Properties Management"}}
            for i = 1, #(Properties) do
              if Properties[i].Entrance then
                local description = ""
                if Properties[i].setName ~= "" then
                  description = description .. "\nName: " .. Properties[i].setName
                end
                if Properties[i].Owned then
                  description = description .. "\nOwner: " .. Properties[i].OwnerName
                end
                table.insert(elements, {title = Properties[i].Name, value = i, description = description, icon = "fas fa-home"})
              end
            end
            ESX.OpenContext("right", elements, function(menu, element)
              if element.value then
                ESX.CloseContext()
                AdminOptions(element.value)
              end
            end)
          end
        end)
      end

      AdminMenu()
    else
      ESX.ShowNotification("You ~r~Cannot~s~ Access This Menu!", 5000, "error")
    end
  end)
end)

