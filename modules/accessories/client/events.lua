local self = ESX.Modules['accessories']

local Input = ESX.Modules['input']

AddEventHandler('esx_accessories:hasEnteredMarker', function(zone)
	self.CurrentAction     = 'shop_menu'
	self.CurrentActionMsg  = _U('press_access')
	self.CurrentActionData = { accessory = zone }
end)

AddEventHandler('esx_accessories:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	self.CurrentAction = nil
end)

-- Key Controls
Input.On('released', Input.Groups.MOVE, Input.Controls.PICKUP, function(lastPressed)

  if self.CurrentAction and (not ESX.IsDead) then
    self.CurrentAction()
    self.CurrentAction = nil
  end

end)

if self.Config.EnableControls then

  Input.On('released', Input.Groups.MOVE, Input.Controls.REPLAY_SHOWHOTKEY, function(lastPressed)

    if not ESX.IsDead then
      self.OpenAccessoryMenu()
    end

  end)

end



