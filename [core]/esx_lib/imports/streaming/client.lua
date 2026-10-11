-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class streaminglib
xLib.streaming = {}

local STREAMING_TIMEOUT <const> = GetConvarInt("xLib:streamingTimeout", 10000)

local function waitForStreamingAsset(isLoaded, interval, onWait)
    local startedAt = GetGameTimer()

    while not isLoaded() do
        if STREAMING_TIMEOUT > 0 and GetGameTimer() - startedAt >= STREAMING_TIMEOUT then
            return false
        end

        if onWait then
            onWait()
        end

        Wait(interval or 0)
    end

    return true
end

---@param modelHash number | string
---@param cb? function
---@return number | nil
xLib.streaming.requestModel = function(modelHash, cb)
    modelHash = type(modelHash) == "number" and modelHash or joaat(modelHash)

    if not IsModelInCdimage(modelHash) then return end

	RequestModel(modelHash)
	if not waitForStreamingAsset(function() return HasModelLoaded(modelHash) end, 500) then return end

	return cb and cb(modelHash) or modelHash
end

---@param modelHash number | string
---@param message? string
---@param cb? function
---@return number | nil
xLib.streaming.requestModelWithSpinner = function(modelHash, message, cb)
    if type(message) == "function" then
        cb = message
        message = nil
    end

    modelHash = type(modelHash) == "number" and modelHash or joaat(modelHash)

    if not IsModelInCdimage(modelHash) then return end

    if HasModelLoaded(modelHash) then
        return cb and cb(modelHash) or modelHash
    end

    BeginTextCommandBusyspinnerOn("STRING")
    AddTextComponentSubstringPlayerName(message or "Loading model")
    EndTextCommandBusyspinnerOn(4)

    RequestModel(modelHash)
    local loaded = waitForStreamingAsset(function() return HasModelLoaded(modelHash) end, 0, function()
        DisableAllControlActions(0)
    end)

    BusyspinnerOff()

    if not loaded then return end

    return cb and cb(modelHash) or modelHash
end

---@param textureDict string
---@param cb? function
---@return string | nil
xLib.streaming.requestStreamedTextureDict = function(textureDict, cb)
	RequestStreamedTextureDict(textureDict, false)

	if not waitForStreamingAsset(function() return HasStreamedTextureDictLoaded(textureDict) end, 500) then return end

	return cb and cb(textureDict) or textureDict
end

---@param assetName string
---@param cb? function
---@return string | nil
xLib.streaming.requestNamedPtfxAsset = function(assetName, cb)
	RequestNamedPtfxAsset(assetName)

	if not waitForStreamingAsset(function() return HasNamedPtfxAssetLoaded(assetName) end, 500) then return end

	return cb and cb(assetName) or assetName
end

---@param animSet string
---@param cb? function
---@return string | nil
xLib.streaming.requestAnimSet = function(animSet, cb)
	RequestAnimSet(animSet)

	if not waitForStreamingAsset(function() return HasAnimSetLoaded(animSet) end, 500) then return end

	return cb and cb(animSet) or animSet
end

---@param animDict string
---@param cb? function
---@return string | nil
xLib.streaming.requestAnimDict = function(animDict, cb)
	RequestAnimDict(animDict)

	if not waitForStreamingAsset(function() return HasAnimDictLoaded(animDict) end, 500) then return end

	return cb and cb(animDict) or animDict
end

---@param weaponHash number | string
---@param cb? function
---@return string | number | nil
xLib.streaming.requestWeaponAsset = function(weaponHash, cb)
	RequestWeaponAsset(weaponHash, 31, 0)

	if not waitForStreamingAsset(function() return HasWeaponAssetLoaded(weaponHash) end, 500) then return end

	return cb and cb(weaponHash) or weaponHash
end

---@param bankName string
---@param cb? function
---@return string | nil
xLib.streaming.requestAudioBank = function(bankName, cb)
    RequestAudioBank(bankName, false) 

    if not waitForStreamingAsset(function() return RequestScriptAudioBank(bankName, false) end, 500) then return end

    return cb and cb(bankName) or bankName
end


return xLib.streaming
