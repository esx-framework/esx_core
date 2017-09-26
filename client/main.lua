local Components = {
	{label = _U('sex'),               		name = 'sex',          value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('face'),             		  name = 'face',         value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('skin'),               		name = 'skin',         value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('wrinkles'),              name = 'age_1',        value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('wrinkle_thickness'),    	name = 'age_2',        value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('beard_type'),         		name = 'beard_1',      value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('beard_size'),       		  name = 'beard_2',      value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('beard_color_1'),    		  name = 'beard_3',      value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('beard_color_2'),    			name = 'beard_4',      value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('hair_1'),          			name = 'hair_1',       value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('hair_2'),          			name = 'hair_2',       value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('hair_color_1'),  				name = 'hair_color_1', value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('hair_color_2'),  				name = 'hair_color_2', value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('eyebrow_type'),	   			name = 'eyebrows_1',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('eyebrow_size'),    			name = 'eyebrows_2',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('eyebrow_color_1'), 			name = 'eyebrows_3',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('eyebrow_color_2'), 			name = 'eyebrows_4',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('makeup_type'),	     			name = 'makeup_1',     value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('makeup_thickness'), 			name = 'makeup_2',     value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('makeup_color_1'), 				name = 'makeup_3',     value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('makeup_color_2'), 				name = 'makeup_4',     value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('lipstick_type'),	   			name = 'lipstick_1',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('lipstick_thickness'), 		name = 'lipstick_2',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('lipstick_color_1'), 			name = 'lipstick_3',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('lipstick_color_2'), 			name = 'lipstick_4',   value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('ear_accessories'),  		  name = 'ears_1',   	   value = -1, min = -1, zoomOffset = 0.4, camOffset = 0.65}, --
	{label = _U('ear_accessories_color'), name = 'ears_2',       value = 0, min = 0, zoomOffset = 0.4, camOffset = 0.65, textureof = 'ears_1'}, --
	{label = _U('tshirt_1'),          		name = 'tshirt_1',     value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15}, --
	{label = _U('tshirt_2'),          		name = 'tshirt_2',     value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = 'tshirt_1'}, --
	{label = _U('torso_1'),            		name = 'torso_1',      value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15}, --
	{label = _U('torso_2'),            		name = 'torso_2',      value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = 'torso_1'}, --
	{label = _U('decals_1'),          		name = 'decals_1',     value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15}, --
	{label = _U('decals_2'),          		name = 'decals_2',     value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = 'decals_1'}, --
	{label = _U('arms'),               		name = 'arms',         value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15}, --
	{label = _U('pants_1'),           		name = 'pants_1',      value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.5}, --
	{label = _U('pants_2'),           		name = 'pants_2',      value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.5, textureof = 'pants_1'}, --
	{label = _U('shoes_1'),       				name = 'shoes_1',      value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.8},
	{label = _U('shoes_2'),       				name = 'shoes_2',      value = 0, min = 0, zoomOffset = 0.8, camOffset = -0.8, textureof = 'shoes_1'},
	{label = _U('mask_1'),           			name = 'mask_1',       value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('mask_2'),           			name = 'mask_2',       value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = 'mask_1'}, --
	{label = _U('bproof_1'), 							name = 'bproof_1',     value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15}, --
	{label = _U('bproof_2'), 							name = 'bproof_2',     value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = 'bproof_1'}, --
	{label = _U('chain_1'),           		name = 'chain_1',      value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('chain_2'),           		name = 'chain_2',      value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = 'chain_1'}, --
	{label = _U('helmet_1'),           		name = 'helmet_1',     value = -1, min = -1, componentId = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('helmet_2'),           		name = 'helmet_2',     value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = 'helmet_1'}, --
	{label = _U('glasses_1'),         		name = 'glasses_1',    value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65}, --
	{label = _U('glasses_2'),         		name = 'glasses_2',    value = 0, min = 0, zoomOffset = 0.6, camOffset = 0.65, textureof = 'glasses_1'}, --
	{label = _U('bag'),         	   			name = 'bags_1',       value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15},
	{label = _U('bag_color'),        			name = 'bags_2',       value = 0, min = 0, zoomOffset = 0.75, camOffset = 0.15, textureof = 'bags_1'}
}

local LastSex     = -1
local LoadSkin    = nil
local LoadClothes = nil
local Character   = {}

for i=1, #Components, 1 do
	Character[Components[i].name] = Components[i].value
end

function LoadDefaultModel(loadMale, cb)

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

		if cb ~= nil then
			cb()
		end

		TriggerEvent('skinchanger:modelLoaded')

	end)

end

function GetMaxVals()

  local playerPed = GetPlayerPed(-1)

	local data = {
		sex          = 1,
		face         = 45,
		skin         = 45,
		age_1 		 = GetNumHeadOverlayValues(3)-1,
		age_2 		 = 10,
		beard_1      = GetNumHeadOverlayValues(1)-1,
		beard_2      = 10,
		beard_3      = GetNumHairColors()-1,
		beard_4      = GetNumHairColors()-1,
		hair_1       = GetNumberOfPedDrawableVariations(playerPed, 2) - 1,
		hair_2       = GetNumberOfPedTextureVariations(playerPed, 2, Character['hair_1']) - 1,
		hair_color_1 = GetNumHairColors()-1,
		hair_color_2 = GetNumHairColors()-1,
		eyebrows_1   = GetNumHeadOverlayValues(2)-1,
		eyebrows_2   = 10,
		eyebrows_3   = GetNumHairColors()-1,
		eyebrows_4   = GetNumHairColors()-1,
		makeup_1     = GetNumHeadOverlayValues(4)-1,
		makeup_2     = 10,
		makeup_3     = GetNumHairColors()-1,
		makeup_4     = GetNumHairColors()-1,
		lipstick_1   = GetNumHeadOverlayValues(8)-1,
		lipstick_2   = 10,
		lipstick_3   = GetNumHairColors()-1,
		lipstick_4   = GetNumHairColors()-1,
		ears_1    	 = GetNumberOfPedPropDrawableVariations(playerPed, 	1) - 1,
		ears_2    	 = GetNumberOfPedPropTextureVariations(playerPed, 	1, Character['ears_1'] - 1),
		tshirt_1     = GetNumberOfPedDrawableVariations(playerPed, 		8) - 1,
		tshirt_2     = GetNumberOfPedTextureVariations(playerPed, 		8, Character['tshirt_1']) - 1,
		torso_1      = GetNumberOfPedDrawableVariations(playerPed, 		11) - 1,
		torso_2      = GetNumberOfPedTextureVariations(playerPed, 		11, Character['torso_1']) - 1,
		decals_1     = GetNumberOfPedDrawableVariations(playerPed, 		10) - 1,
		decals_2     = GetNumberOfPedTextureVariations(playerPed, 		10, Character['decals_1']) - 1,
		arms         = GetNumberOfPedDrawableVariations(playerPed, 		3) - 1,
		pants_1      = GetNumberOfPedDrawableVariations(playerPed, 		4) - 1,
		pants_2      = GetNumberOfPedTextureVariations(playerPed, 		4, Character['pants_1']) - 1,
		shoes_1      = GetNumberOfPedDrawableVariations(playerPed, 		6) - 1,
		shoes_2      = GetNumberOfPedTextureVariations(playerPed, 		6, Character['shoes_1']) - 1,
		mask_1       = GetNumberOfPedDrawableVariations(playerPed, 		1) - 1,
		mask_2       = GetNumberOfPedTextureVariations(playerPed, 		1, Character['mask_1']) - 1,
	  	bproof_1     = GetNumberOfPedDrawableVariations(playerPed, 		9) - 1,
	 	bproof_2     = GetNumberOfPedTextureVariations(playerPed, 		9, Character['bproof_1']) - 1,
	  	chain_1      = GetNumberOfPedDrawableVariations(playerPed, 		7) - 1,
	  	chain_2      = GetNumberOfPedTextureVariations(playerPed, 		7, Character['chain_1']) - 1,
	  	bags_1       = GetNumberOfPedDrawableVariations(playerPed, 		5) - 1,
		bags_2       = GetNumberOfPedTextureVariations(playerPed, 		5, Character['bags_1']) - 1,
		helmet_1     = GetNumberOfPedPropDrawableVariations(playerPed, 	0) - 1,
		helmet_2     = GetNumberOfPedPropTextureVariations(playerPed, 	0, Character['helmet_1']) - 1,
		glasses_1    = GetNumberOfPedPropDrawableVariations(playerPed, 	1) - 1,
		glasses_2    = GetNumberOfPedPropTextureVariations(playerPed, 	1, Character['glasses_1'] - 1),
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
				k ~= 'age_1'        and
				k ~= 'age_2'        and
				k ~= 'beard_1'      and
				k ~= 'beard_2'      and
				k ~= 'beard_3'      and
				k ~= 'beard_4'      and
				k ~= 'hair_1'       and
				k ~= 'hair_2'       and
				k ~= 'hair_color_1' and
				k ~= 'hair_color_2' and
				k ~= 'eyebrows_1' 	and
				k ~= 'eyebrows_2' 	and
				k ~= 'eyebrows_3' 	and
				k ~= 'eyebrows_4' 	and
				k ~= 'makeup_1' 	and
				k ~= 'makeup_2' 	and
				k ~= 'makeup_3' 	and
				k ~= 'makeup_4' 	and
				k ~= 'lipstick_1' 	and
				k ~= 'lipstick_2' 	and
				k ~= 'lipstick_3' 	and
				k ~= 'lipstick_4'
			then
				Character[k] = v
			end
		end

	end

	SetPedHeadBlendData(playerPed, Character['face'], Character['face'], Character['face'], Character['skin'], Character['skin'], Character['skin'], 1.0, 1.0, 1.0, true)

	SetPedHeadOverlay(playerPed, 		3, 		Character['age_1'],  (Character['age_2'] / 10) + 0.0) 				-- Age + opacity
	SetPedHeadOverlay(playerPed, 		1, 		Character['beard_1'],  (Character['beard_2'] / 10) + 0.0) 			-- Beard + opacity
	SetPedHeadOverlayColor(playerPed, 	1, 		1, Character['beard_3'],  Character['beard_4'])     				-- Beard Color
	SetPedHeadOverlay(playerPed, 		2,  	Character['eyebrows_1'], (Character['eyebrows_2'] / 10) + 0.0) 		-- Eyebrows + opacity
	SetPedHeadOverlayColor(playerPed,  	2,  	1,  Character['eyebrows_3'],  Character['eyebrows_4'])				-- Eyebrows Color
	SetPedHeadOverlay(playerPed, 		4,  	Character['makeup_1'], (Character['makeup_2'] / 10) + 0.0) 			-- Makeup + opacity
	SetPedHeadOverlayColor(playerPed,  	4,  	1,  Character['makeup_3'],  Character['makeup_4'])					-- Makeup Color
	SetPedHeadOverlay(playerPed,  		8,  	Character['lipstick_1'], (Character['lipstick_2'] / 10) + 0.0)		-- Lipstick + opacity
	SetPedHeadOverlayColor(playerPed,  	8,  	1,  Character['lipstick_3'],  Character['lipstick_4'])				-- Lipstick Color
	SetPedComponentVariation(playerPed, 2, 		Character['hair_1'], Character['hair_2'], 2)	      				-- Hair
	SetPedHairColor(playerPed, 					Character['hair_color_1'], Character['hair_color_2']) 		    	-- Hair Color

	if Character['ears_1'] == -1 then
		ClearPedProp(playerPed,  2)
	else
		SetPedPropIndex(playerPed, 2, 			Character['ears_1'], Character['ears_2'], 2)               			-- Ears Accessories
	end

	SetPedComponentVariation(playerPed, 8,  	Character['tshirt_1'],Character['tshirt_2'], 2)     				-- Tshirt
	SetPedComponentVariation(playerPed, 11, 	Character['torso_1'], Character['torso_2'], 2)      				-- torso parts
	SetPedComponentVariation(playerPed, 3, 		Character['arms'], 0, 2)                             				-- torso
	SetPedComponentVariation(playerPed, 10, 	Character['decals_1'], Character['decals_2'], 2)    				-- decals
	SetPedComponentVariation(playerPed, 4, 		Character['pants_1'], Character['pants_2'], 2)       				-- pants
	SetPedComponentVariation(playerPed, 6, 		Character['shoes_1'], Character['shoes_2'], 2)       				-- shoes
	SetPedComponentVariation(playerPed, 1, 		Character['mask_1'], Character['mask_2'], 2) 						-- mask
	SetPedComponentVariation(playerPed, 9, 		Character['bproof_1'], Character['bproof_2'], 2) 					-- bulletproof
	SetPedComponentVariation(playerPed, 7, 		Character['chain_1'], Character['chain_2'], 2) 	    				-- chain
	SetPedComponentVariation(playerPed, 5, 		Character['bags_1'], Character['bags_2'], 2) 						-- Bag

	if Character['helmet_1'] == -1 then
		ClearPedProp(playerPed,  0)
	else
		SetPedPropIndex(playerPed, 0, Character['helmet_1'], Character['helmet_2'], 2)              				-- Helmet
	end

	SetPedPropIndex(playerPed, 1, Character['glasses_1'], Character['glasses_2'], 2)            					-- Glasses

end

AddEventHandler('skinchanger:loadDefaultModel', function(loadMale, cb)
	LoadDefaultModel(loadMale, cb)
end)

AddEventHandler('skinchanger:getData', function(cb)

	local components = json.decode(json.encode(Components))

	for k,v in pairs(Character) do
		for i=1, #components, 1 do
			if k == components[i].name then
				components[i].value = v
				--components[i].zoomOffset = Components[i].zoomOffset
				--components[i].camOffset = Components[i].camOffset
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

	ClearPedProp(GetPlayerPed(-1), 0)

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
AddEventHandler('skinchanger:loadSkin', function(skin, cb)

	if skin['sex'] ~= LastSex then

		LoadSkin = skin

		if skin['sex'] == 0 then
			TriggerEvent('skinchanger:loadDefaultModel', true, cb)
		else
			TriggerEvent('skinchanger:loadDefaultModel', false, cb)
		end

	else
		
		ApplySkin(skin)
		
		if cb ~= nil then
			cb()
		end

	end

	LastSex = skin['sex']

end)

RegisterNetEvent('skinchanger:loadClothes')
AddEventHandler('skinchanger:loadClothes', function(playerSkin, clothesSkin)

	if playerSkin['sex'] ~= LastSex then

		LoadClothes = {
			playerSkin  = playerSkin,
			clothesSkin = clothesSkin
		}

		if playerSkin['sex'] == 0 then
			TriggerEvent('skinchanger:loadDefaultModel', true)
		else
			TriggerEvent('skinchanger:loadDefaultModel', false)
		end

	else
		ApplySkin(playerSkin, clothesSkin)
	end

	LastSex = playerSkin['sex']

end)
