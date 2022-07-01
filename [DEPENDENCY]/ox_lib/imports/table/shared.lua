----------------------------------------------------------
--- Add additional functions to the standard table library
----------------------------------------------------------

local table = table
local pairs = pairs

local function contains(tbl, value)
	if type(value) ~= 'table' then
		for _, v in pairs(tbl) do
			if v == value then return true end
		end
	else
		local matched_values = 0
		local values = 0
		for _, v1 in pairs(value) do
			values += 1

			for _, v2 in pairs(tbl) do
				if v1 == v2 then matched_values += 1 end
			end
		end
		if matched_values == values then return true end
	end
	return false
end
table.contains = contains

local function table_matches(t1, t2)
	local type1, type2 = type(t1), type(t2)
	if type1 ~= type2 then return false end
	if type1 ~= 'table' and type2 ~= 'table' then return t1 == t2 end

	for k1,v1 in pairs(t1) do
	   local v2 = t2[k1]
	   if v2 == nil or not table_matches(v1,v2) then return false end
	end

	for k2,v2 in pairs(t2) do
	   local v1 = t1[k2]
	   if v1 == nil or not table_matches(v1,v2) then return false end
	end
	return true
end
table.matches = table_matches

local function table_deepclone(tbl)
	tbl = table.clone(tbl)
	for k, v in pairs(tbl) do
		if type(v) == 'table' then
			tbl[k] = table_deepclone(v)
		end
	end
	return tbl
end
table.deepclone = table_deepclone

return table