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
]]
if Config.Furniture.Enabled then
  SpawnedFurniture = {}
  RegisterNetEvent("esx_property:syncFurniture", function(PropertyId, Furniture)
    if Properties[PropertyId] and Furniture then
      Properties[PropertyId].furniture = Furniture
    end
  end)

  RegisterNetEvent("esx_property:placeFurniture", function(Id, furniture, findex)
    if Properties[Id] and InProperty and CurrentId == Id then
      ESX.Game.SpawnLocalObject(furniture.Name, vector3(furniture.Pos.x, furniture.Pos.y, furniture.Pos.z - 0.1), function(object)
        SetEntityCoordsNoOffset(object, furniture.Pos.x, furniture.Pos.y, furniture.Pos.z)
        SetEntityHeading(object, furniture.Heading)
        SetEntityAsMissionEntity(object, true, true)
        FreezeEntityPosition(object, true)
        SpawnedFurniture[findex] = {obj = object, data = furniture}
      end)
    end
  end)

  RegisterNetEvent("esx_property:removeFurniture", function(Id, furniture)
    if Properties[Id] and InProperty and CurrentId == Id then
      if SpawnedFurniture[furniture] then
        DeleteEntity(SpawnedFurniture[furniture].obj)
        SpawnedFurniture[furniture] = nil
      end
    end
  end)

  RegisterNetEvent("esx_property:editFurniture", function(Id, furniture, Pos, Heading)
    if Properties[Id] and InProperty and CurrentId == Id then

      if SpawnedFurniture[furniture] then
        local obj = SpawnedFurniture[furniture].obj
        SetEntityCoordsNoOffset(obj, Pos.x, Pos.y, Pos.z)
        SetEntityHeading(obj, Heading)
        SpawnedFurniture[furniture].data.Pos = Pos
        SpawnedFurniture[furniture].data.Heading = Heading
      end
    end
  end)

  ------------------------ Furniture Start -------------------------------
  local inFurniture = false
  local CurrentlyEditing = nil

  function TempFurniturePlacement(PropertyId, PropName, PropIndex, PropCatagory, PropPrice, Existing, Pos, Heading)
    ESX.CloseContext()
    if CurrentlyEditing then
      DeleteEntity(CurrentlyEditing)
      CurrentlyEditing = nil
    end
    local function InstructionButtonMessage(text)
      BeginTextCommandScaleformString("STRING")
      AddTextComponentScaleform(text)
      EndTextCommandScaleformString()
    end

    local function CreateInstuctionScaleform(scaleform)
      local scaleform = RequestScaleformMovie(scaleform)
      while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
      end
      PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
      PushScaleformMovieFunctionParameterInt(200)
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(1)
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.MinusX, true))
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.PlusX, true))
      InstructionButtonMessage(TranslateCap("rot_left_right"))
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(3)
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.MinusY, true))
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.PlusY, true))
      InstructionButtonMessage(TranslateCap("rot_up_down"))
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(5)
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.Up, true))
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.Down, true))
      InstructionButtonMessage(TranslateCap("height"))
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(7)
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.RotateLeft, true))
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.RotateRight, true))
      InstructionButtonMessage(TranslateCap("rotate"))
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(9)
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.Confirm, true))
      InstructionButtonMessage(TranslateCap("place"))
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(0)
      N_0xe83a3e3557a56640(GetControlInstructionalButton(1, Config.Furniture.Controls.Exit, true))
      InstructionButtonMessage(TranslateCap("delete_furni"))
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
      PopScaleformMovieFunctionVoid()

      PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
      PushScaleformMovieFunctionParameterInt(0)
      PushScaleformMovieFunctionParameterInt(0)
      PushScaleformMovieFunctionParameterInt(0)
      PushScaleformMovieFunctionParameterInt(80)
      PopScaleformMovieFunctionVoid()

      return scaleform
    end
    function GetCameraDirection()
      local rotation = GetGameplayCamRot() * (math.pi / 180)

      return vector3(-math.sin(rotation.z), math.cos(rotation.z), math.sin(rotation.x))
    end
    local Position = GetEntityCoords(ESX.PlayerData.ped)
    local PropSpawn = Position - vector3(0.5, 0.5, 1.0)
    ESX.Game.SpawnLocalObject(PropName, PropSpawn, function(CurrentlyEditing)
      CurrentlyEditing = CurrentlyEditing
      NetworkSetObjectForceStaticBlend(CurrentlyEditing, true)
      SetEntityAsMissionEntity(CurrentlyEditing, true, true)
      SetEntityCollision(CurrentlyEditing, false, true)
      if Existing then
        SetEntityCoordsNoOffset(CurrentlyEditing, vector3(Pos.x, Pos.y, Pos.z))
        SetEntityHeading(CurrentlyEditing, Heading)
      else
        PlaceObjectOnGroundProperly(CurrentlyEditing)
      end
      FreezeEntityPosition(CurrentlyEditing, true)
      while true do
        HudForceWeaponWheel(false)
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        local CurrentPos = GetEntityCoords(CurrentlyEditing)
        local CurrentHeading = GetEntityHeading(CurrentlyEditing)
        local Rotation = GetEntityRotation(CurrentlyEditing, 2)
        SetEntityDrawOutline(CurrentlyEditing, true)
        SetEntityDrawOutlineColor(55, 140, 191, 200)
        SetEntityDrawOutlineShader(1)
        local instructions = CreateInstuctionScaleform("instructional_buttons")
        DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
        Wait(0)
        if IsControlJustPressed(0, 202) then
          DeleteObject(CurrentlyEditing)
        end

        if IsControlPressed(0, Config.Furniture.Controls.MinusY) then
          local direction = GetCameraDirection()
          CurrentPos = CurrentPos - vector3(direction.x * Config.Furniture.MovementSpeed, direction.y * Config.Furniture.MovementSpeed, 0)
          SetEntityCoordsNoOffset(CurrentlyEditing, CurrentPos.x, CurrentPos.y, CurrentPos.z)
        end

        if IsControlPressed(0, Config.Furniture.Controls.PlusY) then
          local direction = GetCameraDirection()
          CurrentPos = CurrentPos + vector3(direction.x * Config.Furniture.MovementSpeed, direction.y * Config.Furniture.MovementSpeed, 0)
          SetEntityCoordsNoOffset(CurrentlyEditing, CurrentPos)
        end

        if IsControlPressed(0, Config.Furniture.Controls.Up) then
          SetEntityCoordsNoOffset(CurrentlyEditing, CurrentPos.x, CurrentPos.y, CurrentPos.z + Config.Furniture.MovementZspeed)
        end

        if IsControlPressed(0, Config.Furniture.Controls.Down) then
          SetEntityCoordsNoOffset(CurrentlyEditing, CurrentPos.x, CurrentPos.y, CurrentPos.z - Config.Furniture.MovementZspeed)
        end
        if IsControlPressed(0, Config.Furniture.Controls.RotateLeft) then
          CurrentHeading = CurrentHeading + Config.Furniture.RotationSpeed
          SetEntityRotation(CurrentlyEditing, 0, 0, CurrentHeading, 1, true)
          -- SetEntityRotation(CurrentlyEditing, Rotation.x, Rotation.y, Rotation.z + Config.Furniture.RotationSpeed, 2, false)
          -- SetEntityHeading(CurrentlyEditing, CurrentHeading + Config.Furniture.RotationSpeed)
        end

        if IsControlPressed(0, Config.Furniture.Controls.RotateRight) then
          CurrentHeading = CurrentHeading - Config.Furniture.RotationSpeed
          SetEntityRotation(CurrentlyEditing, 0, 0, CurrentHeading, 1, true)
          -- SetEntityRotation(CurrentlyEditing, Rotation.x, Rotation.y, Rotation.z - Config.Furniture.RotationSpeed, 2, false)
          -- SetEntityHeading(CurrentlyEditing, CurrentHeading - Config.Furniture.RotationSpeed)
        end

        if IsControlPressed(0, Config.Furniture.Controls.PlusX) then
          local direction = GetCameraDirection()
          CurrentPos = CurrentPos + vector3(-direction.y * Config.Furniture.MovementSpeed, direction.x * Config.Furniture.MovementSpeed, 0)
          SetEntityCoordsNoOffset(CurrentlyEditing, CurrentPos)
        end

        if IsControlPressed(0, Config.Furniture.Controls.MinusX) then
          local direction = GetCameraDirection()
          CurrentPos = CurrentPos - vector3(-direction.y * Config.Furniture.MovementSpeed, direction.x * Config.Furniture.MovementSpeed, 0)
          SetEntityCoordsNoOffset(CurrentlyEditing, CurrentPos)
        end

        if IsControlJustPressed(0, Config.Furniture.Controls.Confirm) then
          if not Existing then
            ESX.OpenContext("right",
              {{unslectable = true, title = TranslateCap("confirm_buy",Config.FurnitureCatagories[PropCatagory][PropIndex].title),
                description = TranslateCap("price",Config.FurnitureCatagories[PropCatagory][PropIndex].price), icon = "fas fa-shopping-cart"},
               {title = TranslateCap("yes"), value = "buy", icon = "fas fa-check"}, {title = TranslateCap("no"), icon = "fas fa-minus"}}, function(menu, element)
                if element.value and element.value == "buy" then
                  ESX.TriggerServerCallback("esx_property:buyFurniture", function(response)
                    if response then
                      DeleteEntity(CurrentlyEditing)
                      ESX.ShowNotification(TranslateCap("bought_furni", Config.FurnitureCatagories[PropCatagory][PropIndex].title), "success")
                      ESX.CloseContext()
                    else
                      ESX.ShowNotification(TranslateCap("cannot_buy"), "error")
                    end
                  end, CurrentId, PropName, PropIndex, PropCatagory, vector3(CurrentPos.x, CurrentPos.y, CurrentPos.z), CurrentHeading)
                end
              end)
          else
            ESX.TriggerServerCallback("esx_property:editFurniture", function(response)
              if response then
                DeleteEntity(CurrentlyEditing)
                ESX.ShowNotification(TranslateCap("edited_furni"), "success")
                ESX.CloseContext()
              else
                ESX.ShowNotification(TranslateCap("cannot_edit"), "error")
              end
            end, CurrentId, PropIndex, vector3(CurrentPos.x, CurrentPos.y, CurrentPos.z), CurrentHeading)
          end
        end

        if DoesEntityExist(CurrentlyEditing) then
          inFurniture = true
        else
          inFurniture = false
          for _, Control in pairs(Config.Furniture.Controls) do
            EnableControlAction(0, Control, true)
          end
          break
        end
      end
    end)
  end

  function FurnitureItems(house, Store, StoreIndex, Catagory)
    local Items = {{unselectable = true, title = TranslateCap("store_title", Catagory), icon = "fas fa-store"},
                   {title = TranslateCap("back"), value = "go-back", icon = "fas fa-arrow-left"}}

    for k, v in pairs(Config.FurnitureCatagories[Catagory]) do
      table.insert(Items, {title = v.title, value = v.name, index = k, description = _U("price", v.price), icon = "fas fa-shopping-cart"})
    end

    ESX.OpenContext("right", Items, function(data, element)
      if element.value == "go-back" then
        FurnitureCatagories(house, Store, StoreIndex)
      else
        TempFurniturePlacement(house, element.value, element.index, Catagory)
      end
    end)
  end

  function FurnitureCatagories(house, Store, StoreIndex)
    local Catagories = {{unselectable = true, title = TranslateCap("store_title", Store), icon = "fas fa-store"},
    {title = TranslateCap("back"), value = "go-back", icon = "fas fa-arrow-left"}}

    for k, v in pairs(Config.FurnitureStores[StoreIndex].Catagories) do
      table.insert(Catagories, {title = v})
    end

    ESX.OpenContext("right", Catagories, function(data, element)
      if element.value == "go-back" then
        FurnitureStores(house)
      else
        FurnitureItems(house, Store, StoreIndex, element.title)
      end
    end)
  end

  function FurnitureEdit(propertyId, furniture)
    local furni = SpawnedFurniture[furniture]
    local Funiture = Config.FurnitureCatagories[furni.data.Catagory][furni.data.Index]
    local Catagories = {{unselectable = true, title = TranslateCap("edit_title",Funiture.title), icon = "fas fa-store"},
                        {title = TranslateCap("back"), value = "go-back", icon = "fas fa-arrow-left"},
                        {title = TranslateCap("move_title"), value = "rotate", icon = "fas fa-sync-alt"}, {title = TranslateCap("delete_furni"), value = "delete", icon = "fas fa-trash-alt"}}

    ESX.OpenContext("right", Catagories, function(data, element)
      if element.value == "go-back" then
        FurnitureEditSelect(propertyId)
      end
      if element.value == "delete" then
        ESX.TriggerServerCallback("esx_property:deleteFurniture", function(response)
          if response then
            ESX.ShowNotification(TranslateCap("delete_confirm", Funiture.title), "success")
            FurnitureEditSelect(propertyId)
          else
            ESX.ShowNotification(TranslateCap("delete_error", Funiture.title), "error")
          end
        end, propertyId, furniture)
      end
      if element.value == "rotate" then
        ESX.CloseContext()
        TempFurniturePlacement(propertyId, furni.data.Name, furniture, furni.data.Catagory, furni.data.Index, true, furni.data.Pos, furni.data.Heading)
      end
    end)
  end

  function FurnitureEditSelect(propertyId)
    local Furni = {{unselectable = true, title = TranslateCap("owned_furni"), icon = "far fa-edit"},
                   {title = TranslateCap("back"), value = "go-back", icon = "fas fa-arrow-left"}}

    for k, v in pairs(SpawnedFurniture) do
      local Funiture = Config.FurnitureCatagories[v.data.Catagory][v.data.Index]
      table.insert(Furni, {title = Funiture.title, value = k})
    end

    ESX.OpenContext("right", Furni, function(data, element)
      if element.value == "go-back" then
        FurnitureMenu(propertyId)
      else
        FurnitureEdit(propertyId, element.value)
      end
    end)
  end

  function FurnitureStores(house)
    local Options = {{unselectable = true, title = TranslateCap("menu_stores"), icon = "fas fa-store"},
                     {title = TranslateCap("back"), value = "go-back", icon = "fas fa-arrow-left"}}

    for k, v in pairs(Config.FurnitureStores) do
      table.insert(Options, {title = v.title, Store = k})
    end

    ESX.OpenContext("right", Options, function(data, element)
      if element.Store then
        FurnitureCatagories(house, element.title, element.Store)
      elseif element.value == "go-back" then
        FurnitureMenu(house)
      end
    end)
  end

  function FurnitureMenu(PropertyId)
    local Options = {{unselectable = true, title = TranslateCap("furni_management"), icon = "fas fa-lamp"},
                     {title = TranslateCap("menu_stores"), description = TranslateCap("menu_stores_desc"), icon = "fas fa-dollar-sign", value = "store"}}

    if #SpawnedFurniture > 0 then
      Options[#Options + 1] = {title = TranslateCap("menu_reset"), description = TranslateCap("menu_reset_desc"), icon = "fas fa-trash", value = "reset"}
      Options[#Options + 1] = {title = TranslateCap("menu_edit"), description = TranslateCap("menu_edit_desc"), icon = "fas fa-archive", value = "edit"}

    end
    ESX.OpenContext("right", Options, function(data, element)
      if element.value then
        if element.value == "store" then
          FurnitureStores(PropertyId)
        elseif element.value == "edit" then
          FurnitureEditSelect(PropertyId)
        elseif element.value == "reset" then
          ESX.TriggerServerCallback("esx_property:RemoveAllfurniture", function(Removed)
            if Removed then
              ESX.ShowNotification(TranslateCap("furni_reset_success"), "success")
            else
              ESX.ShowNotification(TranslateCap("furni_reset_error"), "error")
            end
          end, PropertyId)
        end
      end
    end)
  end

  ESX.RegisterInput(TranslateCap("furni_command"), TranslateCap("furni_command_desc"), "keyboard", "M", function()
    if InProperty then
      ESX.TriggerServerCallback('esx_property:CanOpenFurniture', function(Access)
        if Access then
          if not inFurniture then
            FurnitureMenu(CurrentId)
          else
            FurnitureStores(CurrentId)
          end
        else
          ESX.ShowNotification(TranslateCap("furni_command_permission"), 5000, "error")
        end
      end, CurrentId)
    else
      return
    end
  end)
end
