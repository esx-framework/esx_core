Config = {}

Config.Locale = GetConvar("esx:locale", "en")

Config.Components = {
    {
        label = TranslateCap("sex"),
        name = "sex",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 1,
    },
    {
        label = TranslateCap("mom"),
        name = "mom",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 45,
    },
    {
        label = TranslateCap("dad"),
        name = "dad",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 44,
    },
    {
        label = TranslateCap("grandparents"),
        name = "grandparents",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 45,
    },
    {
        label = TranslateCap("resemblance"),
        name = "face_md_weight",
        value = 50,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 100,
    },
    {
        label = TranslateCap("resemblance_g"),
        name = "face_g_weight",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 100,
    },
    {
        label = TranslateCap("skin_tone"),
        name = "skin_md_weight",
        value = 50,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 100,
    },
    {
        label = TranslateCap("nose_1"),
        name = "nose_1",
        value = 0,
        min = -10,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("nose_2"),
        name = "nose_2",
        value = 0,
        min = -10,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("nose_3"),
        name = "nose_3",
        value = 0,
        min = -10,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("nose_4"),
        name = "nose_4",
        value = 0,
        min = -10,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("nose_5"),
        name = "nose_5",
        value = 0,
        min = -10,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("nose_6"),
        name = "nose_6",
        value = 0,
        min = -10,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("cheeks_1"),
        name = "cheeks_1",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("cheeks_2"),
        name = "cheeks_2",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("cheeks_3"),
        name = "cheeks_3",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("lip_fullness"),
        name = "lip_thickness",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("jaw_bone_width"),
        name = "jaw_1",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("jaw_bone_length"),
        name = "jaw_2",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("chin_height"),
        name = "chin_1",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("chin_length"),
        name = "chin_2",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("chin_width"),
        name = "chin_3",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("chin_hole"),
        name = "chin_4",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("neck_thickness"),
        name = "neck_thickness",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("hair_1"),
        name = "hair_1",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 2) - 1
        end
    },
    {
        label = TranslateCap("hair_2"),
        name = "hair_2",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        textureof = "hair_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 2, Character["hair_1"]) - 1
        end
    },
    {
        label = TranslateCap("hair_color_1"),
        name = "hair_color_1",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("hair_color_2"),
        name = "hair_color_2",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("tshirt_1"),
        name = "tshirt_1",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        componentId = 8,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 8) - 1
        end
    },
    {
        label = TranslateCap("tshirt_2"),
        name = "tshirt_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        textureof = "tshirt_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 8, Character["tshirt_1"]) - 1
        end
    },
    {
        label = TranslateCap("torso_1"),
        name = "torso_1",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        componentId = 11,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 11) - 1
        end
    },
    {
        label = TranslateCap("torso_2"),
        name = "torso_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        textureof = "torso_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 11, Character["torso_1"]) - 1
        end
    },
    {
        label = TranslateCap("decals_1"),
        name = "decals_1",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        componentId = 10,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 10) - 1
        end
    },
    {
        label = TranslateCap("decals_2"),
        name = "decals_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        textureof = "decals_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 10, Character["decals_1"]) - 1
        end
    },
    {
        label = TranslateCap("arms"),
        name = "arms",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 3) - 1
        end
    },
    {
        label = TranslateCap("arms_2"),
        name = "arms_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        max = 10,
    },
    {
        label = TranslateCap("pants_1"),
        name = "pants_1",
        value = 0,
        min = 0,
        zoomOffset = 0.8,
        camOffset = -0.5,
        componentId = 4,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 4) - 1
        end
    },
    {
        label = TranslateCap("pants_2"),
        name = "pants_2",
        value = 0,
        min = 0,
        zoomOffset = 0.8,
        camOffset = -0.5,
        textureof = "pants_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 4, Character["pants_1"]) - 1
        end
    },
    {
        label = TranslateCap("shoes_1"),
        name = "shoes_1",
        value = 0,
        min = 0,
        zoomOffset = 0.8,
        camOffset = -0.8,
        componentId = 6,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 6) - 1
        end
    },
    {
        label = TranslateCap("shoes_2"),
        name = "shoes_2",
        value = 0,
        min = 0,
        zoomOffset = 0.8,
        camOffset = -0.8,
        textureof = "shoes_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 6, Character["shoes_1"]) - 1
        end
    },
    {
        label = TranslateCap("mask_1"),
        name = "mask_1",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        componentId = 1,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 1) - 1
        end
    },
    {
        label = TranslateCap("mask_2"),
        name = "mask_2",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        textureof = "mask_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 1, Character["mask_1"]) - 1
        end
    },
    {
        label = TranslateCap("bproof_1"),
        name = "bproof_1",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        componentId = 9,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 9) - 1
        end
    },
    {
        label = TranslateCap("bproof_2"),
        name = "bproof_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        textureof = "bproof_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 9, Character["bproof_1"]) - 1
        end
    },
    {
        label = TranslateCap("chain_1"),
        name = "chain_1",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        componentId = 7,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 7) - 1
        end
    },
    {
        label = TranslateCap("chain_2"),
        name = "chain_2",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        textureof = "chain_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 7, Character["chain_1"]) - 1
        end
    },
    {
        label = TranslateCap("helmet_1"),
        name = "helmet_1",
        value = -1,
        min = -1,
        zoomOffset = 0.6,
        camOffset = 0.65,
        componentId = 0,
        max = function(playerPed)
            return GetNumberOfPedPropDrawableVariations(playerPed, 0) - 1
        end
    },
    {
        label = TranslateCap("helmet_2"),
        name = "helmet_2",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        textureof = "helmet_1",
        max = function(playerPed, Character)
            return GetNumberOfPedPropTextureVariations(playerPed, 0, Character["helmet_1"]) - 1
        end
    },
    {
        label = TranslateCap("glasses_1"),
        name = "glasses_1",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        componentId = 1,
        max = function(playerPed)
            return GetNumberOfPedPropDrawableVariations(playerPed, 1) - 1
        end
    },
    {
        label = TranslateCap("glasses_2"),
        name = "glasses_2",
        value = 0,
        min = 0,
        zoomOffset = 0.6,
        camOffset = 0.65,
        textureof = "glasses_1",
        max = function(playerPed, Character)
            return GetNumberOfPedPropTextureVariations(playerPed, 1, Character["glasses_1"]) - 1
        end
    },
    {
        label = TranslateCap("watches_1"),
        name = "watches_1",
        value = -1,
        min = -1,
        zoomOffset = 0.75,
        camOffset = 0.15,
        componentId = 6,
        max = function(playerPed)
            return GetNumberOfPedPropDrawableVariations(playerPed, 6) - 1
        end
    },
    {
        label = TranslateCap("watches_2"),
        name = "watches_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        textureof = "watches_1",
        max = function(playerPed, Character)
            return GetNumberOfPedPropTextureVariations(playerPed, 6, Character["watches_1"]) - 1
        end
    },
    {
        label = TranslateCap("bracelets_1"),
        name = "bracelets_1",
        value = -1,
        min = -1,
        zoomOffset = 0.75,
        camOffset = 0.15,
        componentId = 7,
        max = function(playerPed)
            return GetNumberOfPedPropDrawableVariations(playerPed, 7) - 1
        end
    },
    {
        label = TranslateCap("bracelets_2"),
        name = "bracelets_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        textureof = "bracelets_1",
        max = function(playerPed, Character)
            return GetNumberOfPedPropTextureVariations(playerPed, 7, Character["bracelets_1"]) - 1
        end
    },
    {
        label = TranslateCap("bag"),
        name = "bags_1",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        componentId = 5,
        max = function(playerPed)
            return GetNumberOfPedDrawableVariations(playerPed, 5) - 1
        end
    },
    {
        label = TranslateCap("bag_color"),
        name = "bags_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        textureof = "bags_1",
        max = function(playerPed, Character)
            return GetNumberOfPedTextureVariations(playerPed, 5, Character["bags_1"]) - 1
        end
    },
    {
        label = TranslateCap("eye_color"),
        name = "eye_color",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 31,
    },
    {
        label = TranslateCap("eye_squint"),
        name = "eye_squint",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("eyebrow_size"),
        name = "eyebrows_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("eyebrow_type"),
        name = "eyebrows_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(2) - 1
        end
    },
    {
        label = TranslateCap("eyebrow_color_1"),
        name = "eyebrows_3",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("eyebrow_color_2"),
        name = "eyebrows_4",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("eyebrow_height"),
        name = "eyebrows_5",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("eyebrow_depth"),
        name = "eyebrows_6",
        value = 0,
        min = -10,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("makeup_type"),
        name = "makeup_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(4) - 1
        end
    },
    {
        label = TranslateCap("makeup_thickness"),
        name = "makeup_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("makeup_color_1"),
        name = "makeup_3",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("makeup_color_2"),
        name = "makeup_4",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("lipstick_type"),
        name = "lipstick_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(8) - 1
        end
    },
    {
        label = TranslateCap("lipstick_thickness"),
        name = "lipstick_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("lipstick_color_1"),
        name = "lipstick_3",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("lipstick_color_2"),
        name = "lipstick_4",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("ear_accessories"),
        name = "ears_1",
        value = -1,
        min = -1,
        zoomOffset = 0.4,
        camOffset = 0.65,
        componentId = 2,
        max = function(playerPed)
            return GetNumberOfPedPropDrawableVariations(playerPed, 2) - 1
        end
    },
    {
        label = TranslateCap("ear_accessories_color"),
        name = "ears_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        textureof = "ears_1",
        max = function(playerPed, Character)
            return GetNumberOfPedPropTextureVariations(playerPed, 2, Character["ears_1"]) - 1
        end
    },
    {
        label = TranslateCap("chest_hair"),
        name = "chest_1",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        max = function()
            return GetPedHeadOverlayNum(10) - 1
        end
    },
    {
        label = TranslateCap("chest_hair_1"),
        name = "chest_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        max = 10,
    },
    {
        label = TranslateCap("chest_color"),
        name = "chest_3",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("bodyb"),
        name = "bodyb_1",
        value = -1,
        min = -1,
        zoomOffset = 0.75,
        camOffset = 0.15,
        max = function()
            return GetPedHeadOverlayNum(11) - 1
        end
    },
    {
        label = TranslateCap("bodyb_size"),
        name = "bodyb_2",
        value = 0,
        min = 0,
        zoomOffset = 0.75,
        camOffset = 0.15,
        max = 10,
    },
    {
        label = TranslateCap("bodyb_extra"),
        name = "bodyb_3",
        value = -1,
        min = -1,
        zoomOffset = 0.4,
        camOffset = 0.15,
        max = function()
            return GetPedHeadOverlayNum(12) - 1
        end
    },
    {
        label = TranslateCap("bodyb_extra_thickness"),
        name = "bodyb_4",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.15,
        max = 10,
    },
    {
        label = TranslateCap("wrinkles"),
        name = "age_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(3) - 1
        end
    },
    {
        label = TranslateCap("wrinkle_thickness"),
        name = "age_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("blemishes"),
        name = "blemishes_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(0) - 1
        end
    },
    {
        label = TranslateCap("blemishes_size"),
        name = "blemishes_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("blush"),
        name = "blush_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(5) - 1
        end
    },
    {
        label = TranslateCap("blush_1"),
        name = "blush_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("blush_color"),
        name = "blush_3",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("complexion"),
        name = "complexion_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(6) - 1
        end
    },
    {
        label = TranslateCap("complexion_1"),
        name = "complexion_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("sun"),
        name = "sun_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(7) - 1
        end
    },
    {
        label = TranslateCap("sun_1"),
        name = "sun_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("freckles"),
        name = "moles_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(9) - 1
        end
    },
    {
        label = TranslateCap("freckles_1"),
        name = "moles_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("beard_type"),
        name = "beard_1",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetPedHeadOverlayNum(1) - 1
        end
    },
    {
        label = TranslateCap("beard_size"),
        name = "beard_2",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = 10,
    },
    {
        label = TranslateCap("beard_color_1"),
        name = "beard_3",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
    {
        label = TranslateCap("beard_color_2"),
        name = "beard_4",
        value = 0,
        min = 0,
        zoomOffset = 0.4,
        camOffset = 0.65,
        max = function()
            return GetNumHairColors() - 1
        end
    },
}
