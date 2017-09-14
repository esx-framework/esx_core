local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local GUI                     = {}
local PlayerData              = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

ESX                           = nil
GUI.Time                      = 0

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

function OpenRealestateAgentMenu()

  local elements = {
    {label = _U('properties'), value = 'properties'},
    {label = _U('clients'),    value = 'customers'},
  }

  if PlayerData.job ~= nil and PlayerData.job.name == 'realestateagent' and PlayerData.job.grade_name == 'boss' then
    table.insert(elements, {label = _U('boss_action'), value = 'boss_actions'})
  end

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'realestateagent',
    {
      title    = _U('realtor'),
      elements = elements
    },
    function(data, menu)

      if data.current.value == 'properties' then
        OpenPropertyMenu()
      end

      if data.current.value == 'customers' then
        OpenCustomersMenu()
      end

      if data.current.value == 'boss_actions' then
        TriggerEvent('esx_society:openBossMenu', 'realestateagent', function(data, menu)
          menu.close()
        end)
      end

    end,
    function(data, menu)

      menu.close()

      CurrentAction     = 'realestateagent_menu'
      CurrentActionMsg  = _U('press_to_access')
      CurrentActionData = {}

    end
  )

end

function OpenPropertyMenu()

  TriggerEvent('esx_property:getProperties', function(properties)

    local elements = {
      head = {_U('property'), 'Actions'},
      rows = {}
    }

    for i=1, #properties, 1 do
      table.insert(elements.rows, {
        data = properties[i],
        cols = {
          properties[i].label,
          _U('property_actions')
        }
      })
    end

    ESX.UI.Menu.Open(
      'list', GetCurrentResourceName(), 'properties',
      elements,
      function(data, menu)

        if data.value == 'sell' then

          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'sell_property_amount',
            {
              title = _U('amount')
            },
            function(data2, menu)

              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else

                menu.close()

                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 3.0 then
                  ESX.ShowNotification(_U('no_play_near'))
                else
                  TriggerServerEvent('esx_realestateagentjob:sell', GetPlayerServerId(closestPlayer), data.data.name, amount)
                end

                OpenPropertyMenu()

              end

            end,
            function(data2, menu)
              menu.close()
            end
          )

        end

        if data.value == 'rent' then

          menu.close()

          ESX.UI.Menu.Open(
            'dialog', GetCurrentResourceName(), 'rent_property_amount',
            {
              title = _U('amount')
            },
            function(data2, menu)

              local amount = tonumber(data2.value)

              if amount == nil then
                ESX.ShowNotification(_U('invalid_amount'))
              else

                menu.close()

                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 3.0 then
                  ESX.ShowNotification(_U('no_play_near'))
                else
                  TriggerServerEvent('esx_realestateagentjob:rent', GetPlayerServerId(closestPlayer), data.data.name, amount)
                end

                OpenPropertyMenu()

              end

            end,
            function(data2, menu)
              menu.close()
            end
          )

        end

        if data.value == 'gps' then

          TriggerEvent('esx_property:getProperty', data.data.name, function(property)

            if property.isSingle then
              SetNewWaypoint(property.entering.x,  property.entering.y)
            else
              TriggerEvent('esx_property:getGateway', property, function(gateway)
                SetNewWaypoint(gateway.entering.x,  gateway.entering.y)
              end)
            end

          end)

        end

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenCustomersMenu()

  ESX.TriggerServerCallback('esx_realestateagentjob:getCustomers', function(customers)

    local elements = {
      head = {'Client', _U('property'), 'Type', 'Actions'},
      rows = {}
    }

    for i=1, #customers, 1 do
      table.insert(elements.rows, {
        data = customers[i],
        cols = {
          customers[i].name,
          customers[i].propertyName,
          (customers[i].propertyRented and _U('rent') or _U('sell')),
          _U('contract')
        }
      })
    end

    ESX.UI.Menu.Open(
      'list', GetCurrentResourceName(), 'customers',
      elements,
      function(data, menu)

        if data.value == 'revoke' then
          TriggerServerEvent('esx_realestateagentjob:revoke', data.data.propertyName, data.data.propertyOwner)
          OpenCustomersMenu()
        end

        if data.value == 'gps' then

          TriggerEvent('esx_property:getProperty', data.data.propertyName, function(property)

            if property.isSingle then
              SetNewWaypoint(property.entering.x,  property.entering.y)
            else
              TriggerEvent('esx_property:getGateway', property, function(gateway)
                SetNewWaypoint(gateway.entering.x,  gateway.entering.y)
              end)
            end

          end)

        end

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)

  PlayerData = xPlayer

  if PlayerData.job.name == 'realestateagent' then
    Config.Zones.OfficeActions.Type = 1
  else
    Config.Zones.OfficeActions.Type = -1
  end

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)

  PlayerData.job = job

  if PlayerData.job.name == 'realestateagent' then
    Config.Zones.OfficeActions.Type = 1
  else
    Config.Zones.OfficeActions.Type = -1
  end

end)

AddEventHandler('esx_realestateagentjob:hasEnteredMarker', function(zone)

  if zone == 'OfficeEnter' then
    local playerPed = GetPlayerPed(-1)
    SetEntityCoords(playerPed,  Config.Zones.OfficeInside.Pos.x,  Config.Zones.OfficeInside.Pos.y,  Config.Zones.OfficeInside.Pos.z)
  end

  if zone == 'OfficeExit' then
    local playerPed = GetPlayerPed(-1)
    SetEntityCoords(playerPed,  Config.Zones.OfficeOutside.Pos.x,  Config.Zones.OfficeOutside.Pos.y,  Config.Zones.OfficeOutside.Pos.z)
  end

  if zone == 'OfficeActions' and PlayerData.job ~= nil and PlayerData.job.name == 'realestateagent' then
    CurrentAction     = 'realestateagent_menu'
    CurrentActionMsg  = _U('press_to_access')
    CurrentActionData = {}
  end

end)

AddEventHandler('esx_realestateagentjob:hasExitedMarker', function(zone)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)

  local specialContact = {
    name       = _U('realtor'),
    number     = 'realestateagent',
    base64Icon = 'data:image/png;base64,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'
  }

  TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)

end)

-- Create Blips
Citizen.CreateThread(function()

  local blip = AddBlipForCoord(Config.Zones.OfficeEnter.Pos.x, Config.Zones.OfficeEnter.Pos.y, Config.Zones.OfficeEnter.Pos.z)

  SetBlipSprite (blip, 357)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.0)
  SetBlipColour (blip, 59)
  SetBlipAsShortRange(blip, true)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(_U('realtors'))
  EndTextCommandSetBlipName(blip)

end)

-- Display markers
Citizen.CreateThread(function()
  while true do

    Wait(0)

    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k,v in pairs(Config.Zones) do
      if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
      end
    end

  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
  while true do

    Wait(0)

    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
        isInMarker  = true
        currentZone = k
      end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('esx_realestateagentjob:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_realestateagentjob:hasExitedMarker', LastZone)
    end

  end
end)

-- Key controls
Citizen.CreateThread(function()
  while true do

    Citizen.Wait(0)

    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 300 then

        if CurrentAction == 'realestateagent_menu' then
          OpenRealestateAgentMenu()
        end

        CurrentAction = nil
        GUI.Time      = GetGameTimer()

      end

    end

  end
end)

-- Load IPLS
Citizen.CreateThread(function()
  LoadMpDlcMaps()
  EnableMpDlcMaps(true)
  RequestIpl('ex_dt1_02_office_02c')
end)
