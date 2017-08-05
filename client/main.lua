local Components = { 
	{label = 'Sexe',               name = 'sex',          value = 0,  min = 0 },
	{label = 'Visage',             name = 'face',         value = 0,  min = 0 },
	{label = 'Peau',               name = 'skin',         value = 0,  min = 0 },
	{label = 'Type Barbe',         name = 'beard_1',      value = 0,  min = 0 },
	{label = 'Taille barbe',       name = 'beard_2',      value = 0,  min = 0 },
	{label = 'Couleur barbe 1',    name = 'beard_3',      value = 0,  min = 0 },
	{label = 'Couleur barbe 2',    name = 'beard_4',      value = 0,  min = 0 },
	{label = 'Cheveux 1',          name = 'hair_1',       value = 0,  min = 0 },
	{label = 'Cheveux 2',          name = 'hair_2',       value = 0,  min = 0 },
	{label = 'Couleur cheveux 1',  name = 'hair_color_1', value = 0,  min = 0 },
	{label = 'Couleur cheveux 2',  name = 'hair_color_2', value = 0,  min = 0 },
	{label = 'T-Shirt 1',          name = 'tshirt_1',     value = 0,  min = 0 },
	{label = 'T-Shirt 2',          name = 'tshirt_2',     value = 0,  min = 0 , textureof = 'tshirt_1'},
	{label = 'Torse 1',            name = 'torso_1',      value = 0,  min = 0 },
	{label = 'Torse 2',            name = 'torso_2',      value = 0,  min = 0 , textureof = 'torso_1'},
	{label = 'Calques 1',          name = 'decals_1',     value = 0,  min = 0 },
	{label = 'Calques 2',          name = 'decals_2',     value = 0,  min = 0 , textureof = 'decals_1'},
	{label = 'Bras',               name = 'arms',         value = 0,  min = 0 },
	{label = 'Jambes 1',           name = 'pants_1',      value = 0,  min = 0 },
	{label = 'Jambes 2',           name = 'pants_2',      value = 0,  min = 0 , textureof = 'pants_1'},
	{label = 'Chaussures 1',       name = 'shoes_1',      value = 0,  min = 0 },
	{label = 'Chaussures 2',       name = 'shoes_2',      value = 0,  min = 0 , textureof = 'shoes_1'},
	{label = 'Masque 1',           name = 'mask_1',       value = 0,  min = 0 },
	{label = 'Masque 2',           name = 'mask_2',       value = 0,  min = 0 , textureof = 'mask_1'},
	{label = 'Gilet pare-balle 1', name = 'bproof_1',     value = 0,  min = 0 },
	{label = 'Gilet pare-balle 2', name = 'bproof_2',     value = 0,  min = 0 , textureof = 'bproof_1'},
	{label = 'Chaine 1',           name = 'chain_1',      value = 0,  min = 0 },
	{label = 'Chaine 2',           name = 'chain_2',      value = 0,  min = 0 , textureof = 'chain_1'},
	{label = 'Casque 1',           name = 'helmet_1',     value = -1, min = -1, componentId = 0},
	{label = 'Casque 2',           name = 'helmet_2',     value = 0,  min = 0 , textureof = 'helmet_1'},
	{label = 'Lunettes 1',         name = 'glasses_1',    value = 0,  min = 0 },
	{label = 'Lunettes 2',         name = 'glasses_2',    value = 0,  min = 0 , textureof = 'glasses_1'},
}

local LastSex     = 0
local LoadSkin    = nil
local LoadClothes = nil
local Character   = {}

for i=1, #Components, 1 do
	Character[Components[i].name] = Components[i].value
end

function LoadDefaultModel(loadMale)
	
	local playerPed = GetPlayerPed(-1)
  local characterModel

  if loadMale then
    characterModel = GetHashKey('mp_m_freemode_01')
  else
    characterModel = GetHashKey('mp_f_freemode_01');
   end

  RequestModel(characterModel)

  Citizen.CreateThread(function()
  	
  	while not HasModelLoaded(characterModel) do
  		RequestModel(characterModel)
  		Citizen.Wait(0)
  	end

	  if IsModelInCdimage(characterModel) and IsModelValid(characterModel) then
	  	SetPlayerModel(PlayerId(), characterModel)
	  	SetPedDefaultComponentVariation(playerPed)
	  end

	  SetModelAsNoLongerNeeded(characterModel)

	  TriggerEvent('skinchanger:modelLoaded')

  end)

end

function GetMaxVals()

  local playerPed = GetPlayerPed(-1)

	local data = {
		sex          = 1,
		face         = 45,
		skin         = 45,
		beard_1      = GetNumHeadOverlayValues(1),
		beard_2      = 10,
		beard_3      = 63,
		beard_4      = 63,
		hair_1       = GetNumberOfPedDrawableVariations(playerPed, 2) - 1,
		hair_2       = GetNumberOfPedTextureVariations(playerPed, 2, Character['hair_1']) - 1,
		hair_color_1 = 22,
		hair_color_2 = 4,
		tshirt_1     = GetNumberOfPedDrawableVariations(playerPed, 8) - 1,
		tshirt_2     = GetNumberOfPedTextureVariations(playerPed, 8, Character['tshirt_1']) - 1,
		torso_1      = GetNumberOfPedDrawableVariations(playerPed, 11) - 1,
		torso_2      = GetNumberOfPedTextureVariations(playerPed, 11, Character['torso_1']) - 1,
		decals_1     = GetNumberOfPedDrawableVariations(playerPed, 10) - 1,
		decals_2     = GetNumberOfPedTextureVariations(playerPed, 10, Character['decals_1']) - 1,
		arms         = GetNumberOfPedDrawableVariations(playerPed, 3) - 1,
		pants_1      = GetNumberOfPedDrawableVariations(playerPed, 4) - 1,
		pants_2      = GetNumberOfPedTextureVariations(playerPed, 4, Character['pants_1']) - 1,
		shoes_1      = GetNumberOfPedDrawableVariations(playerPed, 6) - 1,
		shoes_2      = GetNumberOfPedTextureVariations(playerPed, 6, Character['shoes_1']) - 1,
	  mask_1       = GetNumberOfPedDrawableVariations(playerPed, 1) - 1,
	  mask_2       = GetNumberOfPedTextureVariations(playerPed, 1, Character['mask_1']) - 1,
	  bproof_1     = GetNumberOfPedDrawableVariations(playerPed, 9) - 1,
	  bproof_2     = GetNumberOfPedTextureVariations(playerPed, 9, Character['bproof_1']) - 1,
	  chain_1      = GetNumberOfPedDrawableVariations(playerPed, 7) - 1,
	  chain_2      = GetNumberOfPedTextureVariations(playerPed, 7, Character['chain_1']) - 1,
		helmet_1     = GetNumberOfPedPropDrawableVariations(playerPed, 0) - 1,
		helmet_2     = GetNumberOfPedTextureVariations(playerPed, 0, Character['helmet_1']) - 1,
		glasses_1    = GetNumberOfPedPropDrawableVariations(playerPed, 1) - 1,
		glasses_2    = GetNumberOfPedTextureVariations(playerPed, 1, Character['glasses_1'] - 1),
	}

	return data

end

function ApplySkin(skin, clothes)
	
	local playerPed = GetPlayerPed(-1)

	for k,v in pairs(skin) do
		Character[k] = v
	end
	
	if clothes ~= nil then

		for k,v in pairs(clothes) do
			if
				k ~= 'sex'          and
				k ~= 'face'         and
				k ~= 'skin'         and
				k ~= 'beard_1'      and
				k ~= 'beard_2'      and
				k ~= 'beard_3'      and
				k ~= 'beard_4'      and
				k ~= 'hair_1'       and
				k ~= 'hair_2'       and
				k ~= 'hair_color_1' and
				k ~= 'hair_color_2'
			then
				Character[k] = v
			end
		end

	end

	SetPedHeadBlendData(playerPed, Character['face'], Character['face'], Character['face'], Character['skin'], Character['skin'], Character['skin'], 1.0, 1.0, 1.0, true)
	SetPedHeadOverlay(playerPed,  1,  Character['beard_1'],  (Character['beard_2'] / 10) + 0.0) -- Beard
	SetPedHeadOverlayColor(playerPed,  1,  1,  Character['beard_3'],  Character['beard_4'])     -- Beard Color
	SetPedComponentVariation(playerPed, 2, Character['hair_1'], Character['hair_2'], 2)	      	-- Hair
	SetPedHairColor(playerPed, Character['hair_color_1'], Character['hair_color_2']) 		      	-- Hair Color
	SetPedComponentVariation(playerPed, 8,  Character['tshirt_1'],Character['tshirt_2'], 2)     -- Tshirt
	SetPedComponentVariation(playerPed, 11, Character['torso_1'], Character['torso_2'], 2)      -- torso parts
	SetPedComponentVariation(playerPed, 3, Character['arms'], 0, 2)                             -- torso
	SetPedComponentVariation(playerPed, 10, Character['decals_1'], Character['decals_2'], 2)    -- decals
	SetPedComponentVariation(playerPed, 4, Character['pants_1'], Character['pants_2'], 2)       -- pants
	SetPedComponentVariation(playerPed, 6, Character['shoes_1'], Character['shoes_2'], 2)       -- shoes
	SetPedComponentVariation(playerPed, 1, Character['mask_1'], Character['mask_2'], 2) 			  -- mask
	SetPedComponentVariation(playerPed, 9, Character['bproof_1'], Character['bproof_2'], 2) 	  -- bulletproof
	SetPedComponentVariation(playerPed, 7, Character['chain_1'], Character['chain_2'], 2) 	    -- chain
	
	if Character['helmet_1'] == -1 then
		ClearPedProp(playerPed,  0)
	else
		SetPedPropIndex(playerPed, 0, Character['helmet_1'], Character['helmet_2'], 2)              -- Helmet
	end

	SetPedPropIndex(playerPed, 1, Character['glasses_1'], Character['glasses_2'], 2)            -- Glasses

end

AddEventHandler('skinchanger:loadDefaultModel', function(loadMale)
	LoadDefaultModel(loadMale)
end)

AddEventHandler('skinchanger:getData', function(cb)
	
	local components = json.decode(json.encode(Components))

	for k,v in pairs(Character) do
		for i=1, #components, 1 do
			if k == components[i].name then
				components[i].value = v
			end
		end
	end

	cb(components, GetMaxVals())
end)

AddEventHandler('skinchanger:change', function(key, val)

	Character[key] = val

	if key == 'sex' then
		TriggerEvent('skinchanger:loadSkin', Character)
	else
		ApplySkin(Character)
	end

end)

AddEventHandler('skinchanger:getSkin', function(cb)
	cb(Character)
end)

AddEventHandler('skinchanger:modelLoaded', function()

	if LoadSkin ~= nil then

		ApplySkin(LoadSkin)
		LoadSkin = nil
	
	end

	if LoadClothes ~= nil then
		
		ApplySkin(LoadClothes.playerSkin, LoadClothes.clothesSkin)
		LoadClothes = nil

	end

end)

RegisterNetEvent('skinchanger:loadSkin')
AddEventHandler('skinchanger:loadSkin', function(skin)
	
	LoadSkin = skin

	if skin['sex'] == 0 then
		LoadDefaultModel(true)
	else
		LoadDefaultModel(false)
	end

	LastSex = skin['sex']

end)

RegisterNetEvent('skinchanger:loadClothes')
AddEventHandler('skinchanger:loadClothes', function(playerSkin, clothesSkin)
	
	LoadClothes = {
		playerSkin  = playerSkin,
		clothesSkin = clothesSkin
	}

	if playerSkin['sex'] == 0 then
		LoadDefaultModel(true)
	else
		LoadDefaultModel(false)
	end

	LastSex = playerSkin['sex']

end)