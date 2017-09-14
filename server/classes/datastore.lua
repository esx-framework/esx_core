function CreateDataStore(name, owner, data)

  local self = {}

  self.name  = name
  self.owner = owner
  self.data  = data

  local timeoutCallbacks = {}

  self.set = function(key, val)
    data[key] = val
    self.save()
  end

  self.get = function(key)
    return data[key]
  end

  self.save = function()

    for i=1, #timeoutCallbacks, 1 do
      ESX.ClearTimeout(timeoutCallbacks[i])
      timeoutCallbacks[i] = nil
    end

    local timeoutCallback = ESX.SetTimeout(10000, function()

      if self.owner == nil then
        MySQL.Async.execute(
          'UPDATE datastore_data SET data = @data WHERE name = @name',
          {
            ['@data'] = json.encode(self.data),
            ['@name'] = self.name,
          }
        )
      else
        MySQL.Async.execute(
          'UPDATE datastore_data SET data = @data WHERE name = @name and owner = @owner',
          {
            ['@data']  = json.encode(self.data),
            ['@name']  = self.name,
            ['@owner'] = self.owner,
          }
        )
      end

    end)

    table.insert(timeoutCallbacks, timeoutCallback)

  end

  return self

end

