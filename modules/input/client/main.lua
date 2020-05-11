local self = ESX.Modules['input']

Citizen.CreateThread(function()
  while true do

    local events = {
      pressed   = {},
      released  = {},
      dpressed  = {},
      dreleased = {},
    }

    for group, ids in pairs(self.RegisteredControls) do

      for i=1, #ids, 1 do

        local id = ids[i]

        if self.IsControlEnabled(group, id) then

          if IsControlJustPressed(group, id) then
            events.pressed[#events.pressed + 1] = {group, id, self.LastPressed[group][id]}
          end

          if IsControlJustReleased(group, id) then
            events.released[#events.released + 1] = {group, id, self.LastReleased[group][id]}
          end

        else

          DisableControlAction(group, id, true);

          if IsDisabledControlJustPressed(group, id) then
            events.dpressed[#events.dpressed + 1] = {group, id, self.LastDisabledPressed[group][id]}
            self.LastDisabledPressed[group][id] = GetGameTimer()
          end

          if IsDisabledControlJustReleased(group, id) then
            events.dreleased[#events.dreleased + 1] = {group, id, self.LastDisabledReleased[group][id]}
            self.LastDisabledReleased[group][id] = GetGameTimer()
          end

        end

      end
    end

    for i=1, #events.pressed, 1 do
      TriggerEvent('esx:input:pressed:' .. events.pressed[i][1] .. ':' .. events.pressed[i][2], events.pressed[i][3])
    end

    for i=1, #events.released, 1 do
      TriggerEvent('esx:input:released:' .. events.released[i][1] .. ':' .. events.released[i][2], events.released[i][3])
    end

    for i=1, #events.dpressed, 1 do
      TriggerEvent('esx:input:disabled:pressed:' .. events.dpressed[i][1] .. ':' .. events.dpressed[i][2], events.dpressed[i][3])
    end

    for i=1, #events.dreleased, 1 do
      TriggerEvent('esx:input:disabled:released:' .. events.dreleased[i][1] .. ':' .. events.dreleased[i][2], events.dreleased[i][3])
    end

    Citizen.Wait(0)

  end
end)
