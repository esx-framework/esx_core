ESX.Modules['accessories'] = {}
local self = ESX.Modules['accessories']

-- Properties
self.Config = ESX.EvalFile(GetCurrentResourceName(), 'modules/accessories/data/config.lua', {
  vector3 = vector3
})['Config']

