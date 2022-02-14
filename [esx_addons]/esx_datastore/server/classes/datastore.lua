function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

function CreateDataStore(name, owner, data)
	local self = {}

	self.name  = name
	self.owner = owner
	self.data  = type(data) == 'string' and json.decode(data) or data

	local timeoutCallbacks = {}

	function self.set(key, val)
		data[key] = val
		self.save()
	end

	function self.get(key, i)
		local path = stringsplit(key, '.')
		local obj  = self.data

		for i=1, #path, 1 do
			obj = obj[path[i]]
		end

		if i == nil then
			return obj
		else
			return obj[i]
		end
	end

	function self.count(key, i)
		local path = stringsplit(key, '.')
		local obj  = self.data

		for i=1, #path, 1 do
			obj = obj[path[i]]
		end

		if i ~= nil then
			obj = obj[i]
		end

		if obj == nil then
			return 0
		else
			return #obj
		end
	end

	function self.save()
		for i=1, #timeoutCallbacks, 1 do
			ESX.ClearTimeout(timeoutCallbacks[i])
			timeoutCallbacks[i] = nil
		end

		local timeoutCallback = ESX.SetTimeout(10000, function()
			if self.owner == nil then
				MySQL.update('UPDATE datastore_data SET data = ? WHERE name = ?', {json.encode(self.data), self.name})
			else
				MySQL.update('UPDATE datastore_data SET data = ? WHERE name = ? and owner = ?', {json.encode(self.data), self.name, self.owner})
			end
		end)

		table.insert(timeoutCallbacks, timeoutCallback)
	end

	return self
end
