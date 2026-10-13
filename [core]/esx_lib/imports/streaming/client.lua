<<<<<<< HEAD:[core]/es_extended/client/modules/streaming.lua
ESX.Streaming = {}
local StreamTimeoutMS = 5000
local StreamWaitStepMs = 50

---@param cond fun():boolean
---@param timeout number|nil
---@param step number|nil
---@return boolean loaded -- false on timeout
local function waitForLoaded(cond, timeout, step)
    local start = GetGameTimer()
    local to = timeout or StreamTimeoutMS
    local st = step or StreamWaitStepMs
    while not cond() do
        if GetGameTimer() - start >= to then
            return false
        end
        Wait(st)
    end
    return true
end

---@generic T
---@param cb fun(val:T):any|nil
---@param val T
---@return T|any
local function ret(cb, val)
    return cb and cb(val) or val
end
=======
---@class streaminglib
xLib.streaming = {}
>>>>>>> fe59ca0bd6da59e2ec6eb4a8d06ece312e96ae7a:[core]/esx_lib/imports/streaming/client.lua

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
<<<<<<< HEAD:[core]/es_extended/client/modules/streaming.lua
function ESX.Streaming.RequestStreamedTextureDict(textureDict, cb)
	if HasStreamedTextureDictLoaded(textureDict) then
		return ret(cb, textureDict)
	end

=======
xLib.streaming.requestStreamedTextureDict = function(textureDict, cb)
>>>>>>> fe59ca0bd6da59e2ec6eb4a8d06ece312e96ae7a:[core]/esx_lib/imports/streaming/client.lua
	RequestStreamedTextureDict(textureDict, false)
	if not waitForLoaded(function() return HasStreamedTextureDictLoaded(textureDict) end) then
		return
	end

	return ret(cb, textureDict)
end

---@param assetName string
---@param cb? function
---@return string | nil
<<<<<<< HEAD:[core]/es_extended/client/modules/streaming.lua
function ESX.Streaming.RequestNamedPtfxAsset(assetName, cb)
	if HasNamedPtfxAssetLoaded(assetName) then
		return ret(cb, assetName)
	end

=======
xLib.streaming.requestNamedPtfxAsset = function(assetName, cb)
>>>>>>> fe59ca0bd6da59e2ec6eb4a8d06ece312e96ae7a:[core]/esx_lib/imports/streaming/client.lua
	RequestNamedPtfxAsset(assetName)
	if not waitForLoaded(function() return HasNamedPtfxAssetLoaded(assetName) end) then
		return
	end

	return ret(cb, assetName)
end

---@param animSet string
---@param cb? function
---@return string | nil
<<<<<<< HEAD:[core]/es_extended/client/modules/streaming.lua
function ESX.Streaming.RequestAnimSet(animSet, cb)
	if HasAnimSetLoaded(animSet) then
		return ret(cb, animSet)
	end

=======
xLib.streaming.requestAnimSet = function(animSet, cb)
>>>>>>> fe59ca0bd6da59e2ec6eb4a8d06ece312e96ae7a:[core]/esx_lib/imports/streaming/client.lua
	RequestAnimSet(animSet)
	if not waitForLoaded(function() return HasAnimSetLoaded(animSet) end) then
		return 
	end

	return ret(cb, animSet)
end

---@param animDict string
---@param cb? function
---@return string | nil
<<<<<<< HEAD:[core]/es_extended/client/modules/streaming.lua
function ESX.Streaming.RequestAnimDict(animDict, cb)
    if HasAnimDictLoaded(animDict) then
        return ret(cb, animDict)
    end

=======
xLib.streaming.requestAnimDict = function(animDict, cb)
>>>>>>> fe59ca0bd6da59e2ec6eb4a8d06ece312e96ae7a:[core]/esx_lib/imports/streaming/client.lua
	RequestAnimDict(animDict)
	if not waitForLoaded(function() return HasAnimDictLoaded(animDict) end) then
		return
	end

	return ret(cb, animDict)
end

---@param weaponHash number | string
---@param cb? function
---@return string | number | nil
<<<<<<< HEAD:[core]/es_extended/client/modules/streaming.lua
function ESX.Streaming.RequestWeaponAsset(weaponHash, cb)
	if HasWeaponAssetLoaded(weaponHash) then
		return ret(cb, weaponHash)
	end

=======
xLib.streaming.requestWeaponAsset = function(weaponHash, cb)
>>>>>>> fe59ca0bd6da59e2ec6eb4a8d06ece312e96ae7a:[core]/esx_lib/imports/streaming/client.lua
	RequestWeaponAsset(weaponHash, 31, 0)
	if not waitForLoaded(function() return HasWeaponAssetLoaded(weaponHash) end) then
		return
	end

<<<<<<< HEAD:[core]/es_extended/client/modules/streaming.lua
	return ret(cb, weaponHash)
end
=======
	while not HasWeaponAssetLoaded(weaponHash) do Wait(500) end

	return cb and cb(weaponHash) or weaponHash
end

---@param bankName string
---@param cb? function
---@return string | nil
xLib.streaming.requestAudioBank = function(bankName, cb)
    RequestAudioBank(bankName, false) 

    while not RequestScriptAudioBank(bankName, false) do Wait(500) end

    return cb and cb(bankName) or bankName
end


return xLib.streaming
>>>>>>> fe59ca0bd6da59e2ec6eb4a8d06ece312e96ae7a:[core]/esx_lib/imports/streaming/client.lua
