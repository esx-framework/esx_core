ESX.Modules['interact'] = {};
local self = ESX.Modules['interact']

self.Id    = 0
self.Data  = {}

self.Cache = {
  player = {
    ped    = 0,
    coords = vector3(0.0, 0.0, 0.0)
  },
  current = {
    marker = {},
    npc    = {},
  },
  using   = {},
}

self.Register = function(data)

  local idx = -1

  for i=1, #self.Data, 1 do
    if self.Data[i].name == data.name then
      idx = i
      break
    end
  end

  if self.Id >= 65535 then
    data.__id = 1
  else
    data.__id = self.Id + 1
  end

  data.size = (type(data.size) == 'number') and {x = data.size, y = data.size, z = data.size} or data.size

  if data.faceCamera   == nil then data.faceCamera   = false end
  if data.bobUpAndDown == nil then data.bobUpAndDown = false end
  if data.rotate       == nil then data.rotate       = false end

  self.Id = data.__id

  if idx == -1 then
    self.Data[#self.Data + 1] = data
  else
    self.Data[idx] = data
  end

end
