---@diagnostic disable: duplicate-set-field
local HasModelLoaded = HasModelLoaded
local IsModelInCdimage = IsModelInCdimage
local RequestModel = RequestModel
local HasStreamedTextureDictLoaded = HasStreamedTextureDictLoaded
local RequestStreamedTextureDict = RequestStreamedTextureDict
local HasNamedPtfxAssetLoaded = HasNamedPtfxAssetLoaded
local RequestNamedPtfxAsset = RequestNamedPtfxAsset
local HasAnimSetLoaded = HasAnimSetLoaded
local RequestAnimSet = RequestAnimSet
local HasAnimDictLoaded = HasAnimDictLoaded
local RequestAnimDict = RequestAnimDict
local HasWeaponAssetLoaded = HasWeaponAssetLoaded
local RequestWeaponAsset = RequestWeaponAsset

function ESX.Streaming.RequestModel(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or joaat(modelHash))

	if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Wait(100)
		end
	end

	if cb then
		cb()
	end
end

function ESX.Streaming.RequestStreamedTextureDict(textureDict, cb)
	if not HasStreamedTextureDictLoaded(textureDict) then
		RequestStreamedTextureDict(textureDict, true)

		while not HasStreamedTextureDictLoaded(textureDict) do
			Wait(100)
		end
	end

	if cb then
		cb()
	end
end

function ESX.Streaming.RequestNamedPtfxAsset(assetName, cb)
	if not HasNamedPtfxAssetLoaded(assetName) then
		RequestNamedPtfxAsset(assetName)

		while not HasNamedPtfxAssetLoaded(assetName) do
			Wait(100)
		end
	end

	if cb then
		cb()
	end
end

function ESX.Streaming.RequestAnimSet(animSet, cb)
	if not HasAnimSetLoaded(animSet) then
		RequestAnimSet(animSet)

		while not HasAnimSetLoaded(animSet) do
			Wait(100)
		end
	end

	if cb then
		cb()
	end
end

function ESX.Streaming.RequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Wait(100)
		end
	end

	if cb then
		cb()
	end
end

function ESX.Streaming.RequestWeaponAsset(weaponHash, cb)
	if not HasWeaponAssetLoaded(weaponHash) then
		RequestWeaponAsset(weaponHash, 31, 0)

		while not HasWeaponAssetLoaded(weaponHash) do
			Wait(100)
		end
	end

	if cb then
		cb()
	end
end
