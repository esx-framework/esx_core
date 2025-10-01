local class = {}
class.__index = class

function class:new(...)
	local instance = setmetatable({}, self)
	if instance.constructor then
		local ret = instance:constructor(...)
		if type(ret) == 'table' then
			return ret
		end
	end
	return instance
end

function Class(body, heritage)
	local prototype = body or {}
	prototype.__index = prototype
	return setmetatable(prototype, heritage or class)
end

return Class