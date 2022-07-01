local function hasLoaded(fn, type, request, limit)
	local timeout = limit or 100
	while not fn(request) do
		Wait(0)
		timeout -= 1
		if timeout < 1 then
			return print(('Unable to load %s after %s ticks (%s)'):format(type, limit or 100, request))
		end
	end
	return request
end

---@param dict string
---@param timeout number
--- Loads an animation dictionary.
function lib.requestAnimDict(dict, timeout)
	if HasAnimDictLoaded(dict) then return dict end
	assert(DoesAnimDictExist(dict), ('Attempted to load an invalid animdict (%s)'):format(dict))
	RequestAnimDict(dict)
	return hasLoaded(HasAnimDictLoaded, 'animdict', dict, timeout)
end

---@param set string
---@param timeout number
--- Loads an animation clipset.
function lib.requestAnimSet(set, timeout)
	if HasAnimSetLoaded(set) then return set end
	RequestAnimSet(set)
	return hasLoaded(HasAnimSetLoaded, 'animset', set, timeout)
end

---@param model string|number
---@param timeout number
--- Loads a model.
function lib.requestModel(model, timeout)
	model = tonumber(model) or joaat(model)
	if HasModelLoaded(model) then return model end
	assert(IsModelValid(model), ('Attempted to load an invalid model (%s)'):format(model))
	RequestModel(model)
	return hasLoaded(HasModelLoaded, 'model', model, timeout)
end

---@param dict string
---@param timeout number
--- Loads a texture dictionary.
function lib.requestStreamedTextureDict(dict, timeout)
	if HasStreamedTextureDictLoaded(dict) then return dict end
	RequestStreamedTextureDict(dict)
	return hasLoaded(HasStreamedTextureDictLoaded, 'texture dict', dict, timeout)
end

---@param fxName string
---@param timeout number
--- Loads a named particle effect.
function lib.requestNamedPtfxAsset(fxName, timeout)
	if HasNamedPtfxAssetLoaded(fxName) then return fxName end
	RequestNamedPtfxAsset(fxName)
	return hasLoaded(RequestNamedPtfxAsset, 'named ptfx', fxName, timeout)
end