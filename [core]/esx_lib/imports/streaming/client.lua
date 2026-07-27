---@class streaminglib
xLib.streaming = {}

local StreamTimeoutMs = 5000
local StreamWaitStepMs = 50

---@param cond fun():boolean
---@param timeout? number
---@param step? number
---@return boolean loaded false on timeout
local function waitForLoaded(cond, timeout, step)
	local start = GetGameTimer()
	local limit = timeout or StreamTimeoutMs
	local step_ = step or StreamWaitStepMs

	while not cond() do
		if GetGameTimer() - start >= limit then
			return false
		end

		Wait(step_)
	end

	return true
end

---@generic T
---@param cb? fun(val: T): any
---@param val T
---@return T | any
local function ret(cb, val)
	return cb and cb(val) or val
end

---@param modelHash number | string
---@param cb? function
---@return number | nil
xLib.streaming.requestModel = function(modelHash, cb)
    modelHash = type(modelHash) == "number" and modelHash or joaat(modelHash)

    if not IsModelInCdimage(modelHash) then return end

	if HasModelLoaded(modelHash) then
		return ret(cb, modelHash)
	end

	RequestModel(modelHash)

	if not waitForLoaded(function() return HasModelLoaded(modelHash) end) then
		return
	end

	return ret(cb, modelHash)
end

---@param textureDict string
---@param cb? function
---@return string | nil
xLib.streaming.requestStreamedTextureDict = function(textureDict, cb)
	if HasStreamedTextureDictLoaded(textureDict) then
		return ret(cb, textureDict)
	end

	RequestStreamedTextureDict(textureDict, false)

	if not waitForLoaded(function() return HasStreamedTextureDictLoaded(textureDict) end) then
		return
	end

	return ret(cb, textureDict)
end

---@param assetName string
---@param cb? function
---@return string | nil
xLib.streaming.requestNamedPtfxAsset = function(assetName, cb)
	if HasNamedPtfxAssetLoaded(assetName) then
		return ret(cb, assetName)
	end

	RequestNamedPtfxAsset(assetName)

	if not waitForLoaded(function() return HasNamedPtfxAssetLoaded(assetName) end) then
		return
	end

	return ret(cb, assetName)
end

---@param animSet string
---@param cb? function
---@return string | nil
xLib.streaming.requestAnimSet = function(animSet, cb)
	if HasAnimSetLoaded(animSet) then
		return ret(cb, animSet)
	end

	RequestAnimSet(animSet)

	if not waitForLoaded(function() return HasAnimSetLoaded(animSet) end) then
		return
	end

	return ret(cb, animSet)
end

---@param animDict string
---@param cb? function
---@return string | nil
xLib.streaming.requestAnimDict = function(animDict, cb)
	if HasAnimDictLoaded(animDict) then
		return ret(cb, animDict)
	end

	RequestAnimDict(animDict)

	if not waitForLoaded(function() return HasAnimDictLoaded(animDict) end) then
		return
	end

	return ret(cb, animDict)
end

---@param weaponHash number | string
---@param cb? function
---@return string | number | nil
xLib.streaming.requestWeaponAsset = function(weaponHash, cb)
	if HasWeaponAssetLoaded(weaponHash) then
		return ret(cb, weaponHash)
	end

	RequestWeaponAsset(weaponHash, 31, 0)

	if not waitForLoaded(function() return HasWeaponAssetLoaded(weaponHash) end) then
		return
	end

	return ret(cb, weaponHash)
end

---@param bankName string
---@param cb? function
---@return string | nil
xLib.streaming.requestAudioBank = function(bankName, cb)
    RequestAudioBank(bankName, false)

    if not waitForLoaded(function() return RequestScriptAudioBank(bankName, false) end) then
        return
    end

    return ret(cb, bankName)
end


return xLib.streaming
