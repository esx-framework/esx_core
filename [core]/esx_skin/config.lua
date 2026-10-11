-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Config = {}

Config.Locale = GetConvar('esx:locale', 'en')

Config.BackpackWeight = {
    [40] = 16,
    [41] = 20,
    [44] = 25,
    [45] = 23,
}

Config.SkinMaxBytes = 8192
Config.SkinSaveCooldown = 2000
Config.SkinCacheTTL = 60000
Config.AllowClothingBackpackCapacity = false
Config.SkinFields = {
    sex = { 0, 1 },
    mom = { 0, 45 },
    dad = { 0, 44 },
    grandparents = { 0, 45 },
    face_md_weight = { 0, 100 },
    face_g_weight = { 0, 100 },
    skin_md_weight = { 0, 100 },
    nose_1 = { -10, 10 },
    nose_2 = { -10, 10 },
    nose_3 = { -10, 10 },
    nose_4 = { -10, 10 },
    nose_5 = { -10, 10 },
    nose_6 = { -10, 10 },
    cheeks_1 = { -10, 10 },
    cheeks_2 = { -10, 10 },
    cheeks_3 = { -10, 10 },
    lip_thickness = { -10, 10 },
    jaw_1 = { -10, 10 },
    jaw_2 = { -10, 10 },
    chin_1 = { -10, 10 },
    chin_2 = { -10, 10 },
    chin_3 = { -10, 10 },
    chin_4 = { -10, 10 },
    neck_thickness = { -10, 10 },
    hair_1 = { 0, 4095 },
    hair_2 = { 0, 4095 },
    hair_color_1 = { 0, 4095 },
    hair_color_2 = { 0, 4095 },
    tshirt_1 = { 0, 4095 },
    tshirt_2 = { 0, 4095 },
    torso_1 = { 0, 4095 },
    torso_2 = { 0, 4095 },
    decals_1 = { 0, 4095 },
    decals_2 = { 0, 4095 },
    arms = { 0, 4095 },
    arms_2 = { 0, 4095 },
    pants_1 = { 0, 4095 },
    pants_2 = { 0, 4095 },
    shoes_1 = { 0, 4095 },
    shoes_2 = { 0, 4095 },
    mask_1 = { 0, 4095 },
    mask_2 = { 0, 4095 },
    bproof_1 = { 0, 4095 },
    bproof_2 = { 0, 4095 },
    chain_1 = { 0, 4095 },
    chain_2 = { 0, 4095 },
    helmet_1 = { -1, 4095 },
    helmet_2 = { 0, 4095 },
    glasses_1 = { -1, 4095 },
    glasses_2 = { 0, 4095 },
    watches_1 = { -1, 4095 },
    watches_2 = { 0, 4095 },
    bracelets_1 = { -1, 4095 },
    bracelets_2 = { 0, 4095 },
    bags_1 = { 0, 4095 },
    bags_2 = { 0, 4095 },
    eye_color = { 0, 31 },
    eye_squint = { -10, 10 },
    eyebrows_2 = { 0, 10 },
    eyebrows_1 = { 0, 4095 },
    eyebrows_3 = { 0, 4095 },
    eyebrows_4 = { 0, 4095 },
    eyebrows_5 = { -10, 10 },
    eyebrows_6 = { -10, 10 },
    makeup_1 = { 0, 4095 },
    makeup_2 = { 0, 10 },
    makeup_3 = { 0, 4095 },
    makeup_4 = { 0, 4095 },
    lipstick_1 = { 0, 4095 },
    lipstick_2 = { 0, 10 },
    lipstick_3 = { 0, 4095 },
    lipstick_4 = { 0, 4095 },
    ears_1 = { -1, 4095 },
    ears_2 = { 0, 4095 },
    chest_1 = { 0, 4095 },
    chest_2 = { 0, 10 },
    chest_3 = { 0, 4095 },
    bodyb_1 = { -1, 4095 },
    bodyb_2 = { 0, 10 },
    bodyb_3 = { -1, 4095 },
    bodyb_4 = { 0, 10 },
    age_1 = { 0, 4095 },
    age_2 = { 0, 10 },
    blemishes_1 = { 0, 4095 },
    blemishes_2 = { 0, 10 },
    blush_1 = { 0, 4095 },
    blush_2 = { 0, 10 },
    blush_3 = { 0, 4095 },
    complexion_1 = { 0, 4095 },
    complexion_2 = { 0, 10 },
    sun_1 = { 0, 4095 },
    sun_2 = { 0, 10 },
    moles_1 = { 0, 4095 },
    moles_2 = { 0, 10 },
    beard_1 = { 0, 4095 },
    beard_2 = { 0, 10 },
    beard_3 = { 0, 4095 },
    beard_4 = { 0, 4095 },
}

Config.SkinEditSessionTTL = 900000
Config.SkinEditFields = { clothes = {}, barber = {}, outfit = {} }

for _, name in ipairs({ 'tshirt', 'torso', 'decals', 'pants', 'shoes', 'bags', 'chain', 'helmet', 'glasses', 'watches' }) do
    Config.SkinEditFields.clothes[name .. '_1'] = true
    Config.SkinEditFields.clothes[name .. '_2'] = true
end

Config.SkinEditFields.clothes.arms = true
Config.SkinEditFields.clothes.arms_2 = true

for _, name in ipairs({ 'beard', 'eyebrows', 'makeup', 'lipstick' }) do
    for i = 1, 4 do Config.SkinEditFields.barber[name .. '_' .. i] = true end
end

for _, name in ipairs({ 'hair_1', 'hair_2', 'hair_color_1', 'hair_color_2', 'ears_1', 'ears_2' }) do
    Config.SkinEditFields.barber[name] = true
end

for name in pairs(Config.SkinEditFields.clothes) do Config.SkinEditFields.outfit[name] = true end

for _, name in ipairs({ 'mask', 'bproof', 'bracelets', 'ears' }) do
    Config.SkinEditFields.outfit[name .. '_1'] = true
    Config.SkinEditFields.outfit[name .. '_2'] = true
end
