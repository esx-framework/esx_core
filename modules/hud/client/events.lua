local self = ESX.Modules['hud']

AddEventHandler('esx:nui_ready', function()
  ESX.CreateFrame('hud', 'nui://' .. GetCurrentResourceName() .. '/modules/hud/data/html/ui.html')
end)
