Config = {}

Config.Locale = GetConvar('esx:locale', 'en')

Config.Components = {{
    label = TranslateCap('sex'),
    name = 'sex',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('mom'),
    name = 'mom',
    value = 21,
    min = 21,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('dad'),
    name = 'dad',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('resemblance'),
    name = 'face_md_weight',
    value = 50,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('skin_tone'),
    name = 'skin_md_weight',
    value = 50,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('nose_1'),
    name = 'nose_1',
    value = 0,
    min = -10,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('nose_2'),
    name = 'nose_2',
    value = 0,
    min = -10,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('nose_3'),
    name = 'nose_3',
    value = 0,
    min = -10,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('nose_4'),
    name = 'nose_4',
    value = 0,
    min = -10,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('nose_5'),
    name = 'nose_5',
    value = 0,
    min = -10,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('nose_6'),
    name = 'nose_6',
    value = 0,
    min = -10,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('cheeks_1'),
    name = 'cheeks_1',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('cheeks_2'),
    name = 'cheeks_2',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('cheeks_3'),
    name = 'cheeks_3',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('lip_fullness'),
    name = 'lip_thickness',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('jaw_bone_width'),
    name = 'jaw_1',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('jaw_bone_length'),
    name = 'jaw_2',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('chin_height'),
    name = 'chin_1',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('chin_length'),
    name = 'chin_2',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('chin_width'),
    name = 'chin_3',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('chin_hole'),
    name = 'chin_4',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('neck_thickness'),
    name = 'neck_thickness',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('hair_1'),
    name = 'hair_1',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('hair_2'),
    name = 'hair_2',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('hair_color_1'),
    name = 'hair_color_1',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('hair_color_2'),
    name = 'hair_color_2',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65
}, {
    label = TranslateCap('tshirt_1'),
    name = 'tshirt_1',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    componentId = 8
}, {
    label = TranslateCap('tshirt_2'),
    name = 'tshirt_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    textureof = 'tshirt_1'
}, {
    label = TranslateCap('torso_1'),
    name = 'torso_1',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    componentId = 11
}, {
    label = TranslateCap('torso_2'),
    name = 'torso_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    textureof = 'torso_1'
}, {
    label = TranslateCap('decals_1'),
    name = 'decals_1',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    componentId = 10
}, {
    label = TranslateCap('decals_2'),
    name = 'decals_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    textureof = 'decals_1'
}, {
    label = TranslateCap('arms'),
    name = 'arms',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15
}, {
    label = TranslateCap('arms_2'),
    name = 'arms_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15
}, {
    label = TranslateCap('pants_1'),
    name = 'pants_1',
    value = 0,
    min = 0,
    zoomOffset = 0.8,
    camOffset = -0.5,
    componentId = 4
}, {
    label = TranslateCap('pants_2'),
    name = 'pants_2',
    value = 0,
    min = 0,
    zoomOffset = 0.8,
    camOffset = -0.5,
    textureof = 'pants_1'
}, {
    label = TranslateCap('shoes_1'),
    name = 'shoes_1',
    value = 0,
    min = 0,
    zoomOffset = 0.8,
    camOffset = -0.8,
    componentId = 6
}, {
    label = TranslateCap('shoes_2'),
    name = 'shoes_2',
    value = 0,
    min = 0,
    zoomOffset = 0.8,
    camOffset = -0.8,
    textureof = 'shoes_1'
}, {
    label = TranslateCap('mask_1'),
    name = 'mask_1',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65,
    componentId = 1
}, {
    label = TranslateCap('mask_2'),
    name = 'mask_2',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65,
    textureof = 'mask_1'
}, {
    label = TranslateCap('bproof_1'),
    name = 'bproof_1',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    componentId = 9
}, {
    label = TranslateCap('bproof_2'),
    name = 'bproof_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    textureof = 'bproof_1'
}, {
    label = TranslateCap('chain_1'),
    name = 'chain_1',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65,
    componentId = 7
}, {
    label = TranslateCap('chain_2'),
    name = 'chain_2',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65,
    textureof = 'chain_1'
}, {
    label = TranslateCap('helmet_1'),
    name = 'helmet_1',
    value = -1,
    min = -1,
    zoomOffset = 0.6,
    camOffset = 0.65,
    componentId = 0
}, {
    label = TranslateCap('helmet_2'),
    name = 'helmet_2',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65,
    textureof = 'helmet_1'
}, {
    label = TranslateCap('glasses_1'),
    name = 'glasses_1',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65,
    componentId = 1
}, {
    label = TranslateCap('glasses_2'),
    name = 'glasses_2',
    value = 0,
    min = 0,
    zoomOffset = 0.6,
    camOffset = 0.65,
    textureof = 'glasses_1'
}, {
    label = TranslateCap('watches_1'),
    name = 'watches_1',
    value = -1,
    min = -1,
    zoomOffset = 0.75,
    camOffset = 0.15,
    componentId = 6
}, {
    label = TranslateCap('watches_2'),
    name = 'watches_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    textureof = 'watches_1'
}, {
    label = TranslateCap('bracelets_1'),
    name = 'bracelets_1',
    value = -1,
    min = -1,
    zoomOffset = 0.75,
    camOffset = 0.15,
    componentId = 7
}, {
    label = TranslateCap('bracelets_2'),
    name = 'bracelets_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    textureof = 'bracelets_1'
}, {
    label = TranslateCap('bag'),
    name = 'bags_1',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    componentId = 5
}, {
    label = TranslateCap('bag_color'),
    name = 'bags_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15,
    textureof = 'bags_1'
}, {
    label = TranslateCap('eye_color'),
    name = 'eye_color',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('eye_squint'),
    name = 'eye_squint',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('eyebrow_size'),
    name = 'eyebrows_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('eyebrow_type'),
    name = 'eyebrows_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('eyebrow_color_1'),
    name = 'eyebrows_3',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('eyebrow_color_2'),
    name = 'eyebrows_4',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('eyebrow_height'),
    name = 'eyebrows_5',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('eyebrow_depth'),
    name = 'eyebrows_6',
    value = 0,
    min = -10,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('makeup_type'),
    name = 'makeup_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('makeup_thickness'),
    name = 'makeup_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('makeup_color_1'),
    name = 'makeup_3',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('makeup_color_2'),
    name = 'makeup_4',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('lipstick_type'),
    name = 'lipstick_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('lipstick_thickness'),
    name = 'lipstick_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('lipstick_color_1'),
    name = 'lipstick_3',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('lipstick_color_2'),
    name = 'lipstick_4',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('ear_accessories'),
    name = 'ears_1',
    value = -1,
    min = -1,
    zoomOffset = 0.4,
    camOffset = 0.65,
    componentId = 2
}, {
    label = TranslateCap('ear_accessories_color'),
    name = 'ears_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65,
    textureof = 'ears_1'
}, {
    label = TranslateCap('chest_hair'),
    name = 'chest_1',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15
}, {
    label = TranslateCap('chest_hair_1'),
    name = 'chest_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15
}, {
    label = TranslateCap('chest_color'),
    name = 'chest_3',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15
}, {
    label = TranslateCap('bodyb'),
    name = 'bodyb_1',
    value = -1,
    min = -1,
    zoomOffset = 0.75,
    camOffset = 0.15
}, {
    label = TranslateCap('bodyb_size'),
    name = 'bodyb_2',
    value = 0,
    min = 0,
    zoomOffset = 0.75,
    camOffset = 0.15
}, {
    label = TranslateCap('bodyb_extra'),
    name = 'bodyb_3',
    value = -1,
    min = -1,
    zoomOffset = 0.4,
    camOffset = 0.15
}, {
    label = TranslateCap('bodyb_extra_thickness'),
    name = 'bodyb_4',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.15
}, {
    label = TranslateCap('wrinkles'),
    name = 'age_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('wrinkle_thickness'),
    name = 'age_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('blemishes'),
    name = 'blemishes_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('blemishes_size'),
    name = 'blemishes_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('blush'),
    name = 'blush_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('blush_1'),
    name = 'blush_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('blush_color'),
    name = 'blush_3',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('complexion'),
    name = 'complexion_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('complexion_1'),
    name = 'complexion_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('sun'),
    name = 'sun_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('sun_1'),
    name = 'sun_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('freckles'),
    name = 'moles_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('freckles_1'),
    name = 'moles_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('beard_type'),
    name = 'beard_1',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('beard_size'),
    name = 'beard_2',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('beard_color_1'),
    name = 'beard_3',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}, {
    label = TranslateCap('beard_color_2'),
    name = 'beard_4',
    value = 0,
    min = 0,
    zoomOffset = 0.4,
    camOffset = 0.65
}}
