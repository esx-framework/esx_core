function CreateDataStore(name, owner, data)

	local self = {}

	self.name  = name
	self.owner = owner
	self.data  = data

	self.set = function(key, val)
		data[key] = val
		self.save()
	end

	self.get = function(key)
		return data[key]
	end

	self.save = function()

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

	end

	return self

end

