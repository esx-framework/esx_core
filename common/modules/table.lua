ESX.Table = {}

-- nil proof alternative to #table
function ESX.Table.SizeOf(table)
	local keys = {}

	for k,v in pairs(table) do
		table.insert(keys, tonumber(k))
	end

	table.sort(keys, function(a,b) return a < b end)

	if #keys > 0 then
		return keys[#keys]
	else
		return 0
	end
end

function ESX.Table.IndexOf(table, value)
	for i=1, #table, 1 do
		if table[i] == value then
			return i
		end
	end

	return -1
end

function ESX.Table.LastIndexOf(table, value)
	for i=#table, 1, -1 do
		if table[i] == value then
			return i
		end
	end

	return -1
end

function ESX.Table.Find(table, cb)
	for i=1, #table, 1 do
		if cb(table[i]) then
			return table[i]
		end
	end

	return nil
end

function ESX.Table.FindIndex(table, cb)
	for i=1, #table, 1 do
		if cb(table[i]) then
			return i
		end
	end

	return -1
end

function ESX.Table.Filter(table, cb)
	local newTable = {}

	for i=1, #table, 1 do
		if cb(table[i]) then
			table.insert(newTable, table[i])
		end
	end

	return newTable
end

function ESX.Table.Map(table, cb)
	local newTable = {}

	for i=1, #table, 1 do
		newTable[i] = cb(table[i], i)
	end

	return newTable
end

function ESX.Table.Reverse(table)
	local newTable = {}

	for i=#table, 1, -1 do
		table.insert(newTable, table[i])
	end

	return newTable
end

function ESX.Table.Clone(table)
	if type(table) ~= 'table' then return table end

	local meta = getmetatable(table)
	local target = {}

	for k,v in pairs(table) do
		if type(v) == 'table' then
			target[k] = ESX.Table.Clone(v)
		else
			target[k] = v
		end
	end

	setmetatable(target, meta)

	return target
end

function ESX.Table.Concat(table1, table2)
	local table3 = ESX.Table.Clone(table1)

	for i=1, #table2, 1 do
		table.insert(table3, table2[i])
	end

	return t3
end

function ESX.Table.Join(table, sep)
	local sep = sep or ','
	local str = ''

	for i=1, #table, 1 do
		if i > 1 then
			str = str .. sep
		end

		str = str .. table[i]
	end

	return str
end