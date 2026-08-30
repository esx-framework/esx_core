import type { CameraAction, SkinCategory, SkinElement } from './types'

import logoEsx from './assets/icons/logo-esx.png'
import actionCamera from './assets/icons/action-camera.png'
import actionReset from './assets/icons/action-reset.svg'
import actionFullBody from './assets/icons/action-full-body.svg'
import actionRotate from './assets/icons/action-rotate.png'
import actionRotateLeft from './assets/icons/action-rotate-left.png'
import categoryAccessories from './assets/icons/category-accessories.png'
import categoryBody from './assets/icons/category-body.png'
import categoryClothing from './assets/icons/category-clothing.png'
import categoryColors from './assets/icons/category-colors.png'
import categoryEyes from './assets/icons/category-eyes.png'
import categoryFace from './assets/icons/category-face.png'
import categoryFamily from './assets/icons/category-family.png'
import categoryHair from './assets/icons/category-hair.png'
import categoryIdentity from './assets/icons/category-identity.png'
import categoryLipstick from './assets/icons/category-lipstick.png'
import categoryPants from './assets/icons/category-pants.png'
import categoryShoes from './assets/icons/category-shoes.png'
import chevronLeft from './assets/icons/chevron-left.png'
import chevronRight from './assets/icons/chevron-right.png'
import detailBeard from './assets/icons/detail-beard.png'
import detailBrush from './assets/icons/detail-brush.png'
import detailFace from './assets/icons/detail-face.png'
import detailFaceAlt from './assets/icons/detail-face-alt.png'
import detailInspection from './assets/icons/detail-inspection.png'
import detailMouth from './assets/icons/detail-mouth.png'
import detailNeck from './assets/icons/detail-neck.png'
import detailNose from './assets/icons/detail-nose.png'
import detailPortrait from './assets/icons/detail-portrait.png'
import detailShirt from './assets/icons/detail-shirt-dark-source.png'
import detailTorso from './assets/icons/detail-torso.png'
import detailWrinkles from './assets/icons/detail-wrinkles.png'

export const logoEsxSrc = logoEsx
export const chevronLeftSrc = chevronLeft
export const chevronRightSrc = chevronRight

export const icon = {
  identity: categoryIdentity,
  family: categoryFamily,
  face: categoryFace,
  faceDetail: detailFace,
  faceAlt: detailFaceAlt,
  eyes: categoryEyes,
  hair: categoryHair,
  makeup: categoryColors,
  brush: detailBrush,
  lipstick: categoryLipstick,
  clothing: categoryClothing,
  body: categoryBody,
  pants: categoryPants,
  shoes: categoryShoes,
  accessories: categoryAccessories,
  nose: detailNose,
  mouth: detailMouth,
  neck: detailNeck,
  beard: detailBeard,
  inspection: detailInspection,
  portrait: detailPortrait,
  shirt: detailShirt,
  torso: detailTorso,
  wrinkles: detailWrinkles,
  reset: actionReset,
  rotateLeft: actionRotateLeft,
  rotateRight: actionRotate,
  fullBody: actionFullBody,
  camera: actionCamera
}

export const labelMap: Record<string, string> = {
  sex: 'GENDER',
  mom: 'FACE 1',
  dad: 'FACE 2',
  grandparents: 'FACE 3',
  face_md_weight: 'FACE 1/2 MIX',
  face_g_weight: 'FACE 3 MIX',
  skin_md_weight: 'SKIN TONE',
  nose_1: 'NOSE WIDTH',
  nose_2: 'NOSE PEAK HEIGHT',
  nose_3: 'NOSE PEAK LENGTH',
  nose_4: 'NOSE BONE HEIGHT',
  nose_5: 'NOSE PEAK LOWERING',
  nose_6: 'NOSE BONE TWIST',
  cheeks_1: 'CHEEK HEIGHT',
  cheeks_2: 'CHEEK WIDTH',
  cheeks_3: 'CHEEK SIZE',
  lip_thickness: 'LIP FULLNESS',
  jaw_1: 'JAW WIDTH',
  jaw_2: 'JAW LENGTH',
  chin_1: 'CHIN HEIGHT',
  chin_2: 'CHIN LENGTH',
  chin_3: 'CHIN WIDTH',
  chin_4: 'CHIN HOLE SIZE',
  neck_thickness: 'NECK THICKNESS',
  hair_1: 'HAIR STYLE',
  hair_2: 'HAIR VARIATION',
  hair_color_1: 'HAIR COLOR',
  hair_color_2: 'HAIR HIGHLIGHT',
  beard_1: 'BEARD TYPE',
  beard_2: 'BEARD THICKNESS',
  beard_3: 'BEARD COLOR 1',
  beard_4: 'BEARD COLOR 2',
  eye_color: 'EYE COLOR',
  eye_squint: 'EYE SQUINT',
  eyebrows_1: 'EYEBROW TYPE',
  eyebrows_2: 'EYEBROW SIZE',
  eyebrows_3: 'EYEBROW COLOR 1',
  eyebrows_4: 'EYEBROW COLOR 2',
  eyebrows_5: 'EYEBROW HEIGHT',
  eyebrows_6: 'EYEBROW DEPTH',
  makeup_1: 'MAKEUP',
  makeup_2: 'THICKNESS',
  makeup_3: 'COLOR 1',
  makeup_4: 'COLOR 2',
  lipstick_1: 'LIPSTICK',
  lipstick_2: 'THICKNESS',
  lipstick_3: 'COLOR 1',
  lipstick_4: 'COLOR 2',
  blemishes_1: 'BLEMISHES',
  blemishes_2: 'THICKNESS',
  age_1: 'AGEING',
  age_2: 'THICKNESS',
  blush_1: 'BLUSH',
  blush_2: 'THICKNESS',
  blush_3: 'COLOR',
  complexion_1: 'COMPLEXION',
  complexion_2: 'THICKNESS',
  sun_1: 'SUN DAMAGE',
  sun_2: 'THICKNESS',
  moles_1: 'FRECKLES',
  moles_2: 'THICKNESS',
  bodyb_1: 'BODY BLEMISHES',
  bodyb_2: 'THICKNESS',
  bodyb_3: 'BODY MARKS',
  bodyb_4: 'THICKNESS',
  chest_1: 'CHEST HAIR',
  chest_2: 'THICKNESS',
  chest_3: 'CHEST HAIR COLOR',
  tshirt_1: 'UNDERSHIRT',
  tshirt_2: 'UNDERSHIRT COLOR',
  torso_1: 'TOP',
  torso_2: 'TOP COLOR',
  decals_1: 'DECALS',
  decals_2: 'DECALS COLOR',
  arms: 'ARMS',
  arms_2: 'ARMS VARIATION',
  mask_1: 'MASK',
  mask_2: 'MASK COLOR',
  bproof_1: 'BODY ARMOR',
  bproof_2: 'BODY ARMOR COLOR',
  chain_1: 'CHAIN',
  chain_2: 'CHAIN COLOR',
  bags_1: 'BAG',
  bags_2: 'BAG COLOR',
  pants_1: 'PANTS',
  pants_2: 'PANTS COLOR',
  shoes_1: 'SHOES',
  shoes_2: 'SHOES COLOR',
  helmet_1: 'HELMET',
  helmet_2: 'HELMET COLOR',
  glasses_1: 'GLASSES 1',
  glasses_2: 'GLASSES 2',
  watches_1: 'WATCHES 1',
  watches_2: 'WATCHES 2',
  bracelets_1: 'BRACELETS 1',
  bracelets_2: 'BRACELETS 2',
  ears_1: 'EAR ACCESSORIES',
  ears_2: 'COLOR',
  blemishes_3: 'BLEMISHES COLOR'
}

export const categories: SkinCategory[] = [
  {
    id: 'identity',
    title: 'Identity',
    icon: icon.identity,
    children: [
      { id: 'heritage', title: 'Heritage', icon: icon.family, names: ['sex', 'mom', 'dad', 'grandparents', 'face_md_weight', 'face_g_weight', 'skin_md_weight'] }
    ]
  },
  {
    id: 'face',
    title: 'Face',
    icon: icon.face,
    children: [
      { id: 'shape', title: 'Face Shape', icon: icon.faceDetail, names: ['cheeks_1', 'cheeks_2', 'cheeks_3', 'jaw_1', 'jaw_2', 'lip_thickness'] },
      { id: 'nose', title: 'Nose', icon: icon.nose, names: ['nose_1', 'nose_2', 'nose_3', 'nose_4', 'nose_5', 'nose_6'] },
      { id: 'chin', title: 'Chin & Neck', icon: icon.neck, names: ['chin_1', 'chin_2', 'chin_3', 'chin_4', 'neck_thickness'] },
      { id: 'beard', title: 'Beard', icon: icon.beard, names: ['beard_1', 'beard_2', 'beard_3', 'beard_4'] },
      { id: 'hair', title: 'Hair', icon: icon.hair, names: ['hair_1', 'hair_2', 'hair_color_1', 'hair_color_2'] }
    ]
  },
  {
    id: 'eyes',
    title: 'Eyes',
    icon: icon.eyes,
    children: [
      { id: 'eyes', title: 'Eyes', icon: icon.eyes, names: ['eye_color', 'eye_squint'] },
      { id: 'eyebrows', title: 'Eyebrows', icon: icon.makeup, names: ['eyebrows_1', 'eyebrows_2', 'eyebrows_3', 'eyebrows_4', 'eyebrows_5', 'eyebrows_6'] }
    ]
  },
  {
    id: 'makeup',
    title: 'Skin Details',
    icon: icon.lipstick,
    children: [
      { id: 'skin-marks', title: 'Skin Marks', icon: icon.inspection, names: ['blemishes_1', 'blemishes_2', 'age_1', 'age_2', 'complexion_1', 'complexion_2', 'sun_1', 'sun_2', 'moles_1', 'moles_2'] },
      { id: 'makeup', title: 'Makeup', icon: icon.brush, names: ['makeup_1', 'makeup_2', 'makeup_3', 'makeup_4', 'blush_1', 'blush_2', 'blush_3'] },
      { id: 'lipstick', title: 'Lipstick', icon: icon.mouth, names: ['lipstick_1', 'lipstick_2', 'lipstick_3', 'lipstick_4'] },
      { id: 'body-details', title: 'Body Details', icon: icon.body, names: ['chest_1', 'chest_2', 'chest_3', 'bodyb_1', 'bodyb_2', 'bodyb_3', 'bodyb_4'] }
    ]
  },
  {
    id: 'clothing',
    title: 'Clothing',
    icon: icon.clothing,
    children: [
      { id: 'masks', title: 'Masks', icon: icon.faceAlt, names: ['mask_1', 'mask_2'] },
      { id: 'tops', title: 'Tops', icon: icon.shirt, names: ['tshirt_1', 'tshirt_2', 'torso_1', 'torso_2', 'arms', 'arms_2', 'decals_1', 'decals_2', 'bproof_1', 'bproof_2'] },
      { id: 'accessories', title: 'Accessories', icon: icon.accessories, names: ['chain_1', 'chain_2', 'bags_1', 'bags_2', 'helmet_1', 'helmet_2', 'glasses_1', 'glasses_2', 'ears_1', 'ears_2', 'watches_1', 'watches_2', 'bracelets_1', 'bracelets_2'] },
      { id: 'pants', title: 'Pants', icon: icon.pants, names: ['pants_1', 'pants_2'] },
      { id: 'shoes', title: 'Shoes', icon: icon.shoes, names: ['shoes_1', 'shoes_2'] }
    ]
  }
]

export const cameraPresets = ['full', 'face', 'torso', 'legs', 'shoes'] as const

export const cameraActions: CameraAction[] = [
  { id: 'cam-full', title: 'Full body camera', icon: icon.fullBody, preset: 'full' },
  { id: 'cam-face', title: 'Face camera', icon: icon.faceDetail, preset: 'face' },
  { id: 'cam-torso', title: 'Torso camera', icon: icon.shirt, preset: 'torso' },
  { id: 'cam-legs', title: 'Legs camera', icon: icon.pants, preset: 'legs' },
  { id: 'cam-shoes', title: 'Shoes camera', icon: icon.shoes, preset: 'shoes' },
  { id: 'rotate-left', title: 'Rotate left', icon: icon.rotateLeft, direction: 'left' },
  { id: 'rotate-right', title: 'Rotate right', icon: icon.rotateRight, direction: 'right' },
  { id: 'reset-camera', title: 'Reset', icon: icon.reset, reset: true }
]

export const demoElements: SkinElement[] = [
  { name: 'sex', value: 0, min: 0, max: 1 },
  { name: 'mom', value: 10, min: 0, max: 45 },
  { name: 'dad', value: 10, min: 0, max: 44 },
  { name: 'grandparents', value: 10, min: 0, max: 45 },
  { name: 'face_md_weight', value: 10, min: 0, max: 100 },
  { name: 'face_g_weight', value: 10, min: 0, max: 100 },
  { name: 'skin_md_weight', value: 10, min: 0, max: 100 },
  { name: 'nose_1', value: 0, min: -10, max: 10 },
  { name: 'nose_2', value: 0, min: -10, max: 10 },
  { name: 'nose_3', value: 0, min: -10, max: 10 },
  { name: 'nose_4', value: 0, min: -10, max: 10 },
  { name: 'nose_5', value: 0, min: -10, max: 10 },
  { name: 'nose_6', value: 0, min: -10, max: 10 },
  { name: 'cheeks_1', value: 0, min: -10, max: 10 },
  { name: 'cheeks_2', value: 0, min: -10, max: 10 },
  { name: 'cheeks_3', value: 0, min: -10, max: 10 },
  { name: 'jaw_1', value: 0, min: -10, max: 10 },
  { name: 'jaw_2', value: 0, min: -10, max: 10 },
  { name: 'chin_1', value: 0, min: -10, max: 10 },
  { name: 'chin_2', value: 0, min: -10, max: 10 },
  { name: 'chin_3', value: 0, min: -10, max: 10 },
  { name: 'chin_4', value: 0, min: -10, max: 10 },
  { name: 'neck_thickness', value: 0, min: -10, max: 10 },
  { name: 'lip_thickness', value: 0, min: -10, max: 10 },
  { name: 'eye_color', value: 0, min: 0, max: 31 },
  { name: 'eye_squint', value: 0, min: -10, max: 10 },
  { name: 'hair_1', value: 0, min: 0, max: 75 },
  { name: 'hair_2', value: 0, min: 0, max: 10 },
  { name: 'hair_color_1', value: 0, min: 0, max: 63 },
  { name: 'hair_color_2', value: 0, min: 0, max: 63 },
  { name: 'beard_1', value: 0, min: 0, max: 28 },
  { name: 'beard_2', value: 0, min: 0, max: 10 },
  { name: 'beard_3', value: 0, min: 0, max: 63 },
  { name: 'beard_4', value: 0, min: 0, max: 63 },
  { name: 'eyebrows_1', value: 0, min: 0, max: 33 },
  { name: 'eyebrows_2', value: 0, min: 0, max: 10 },
  { name: 'eyebrows_3', value: 0, min: 0, max: 63 },
  { name: 'eyebrows_4', value: 0, min: 0, max: 63 },
  { name: 'eyebrows_5', value: 0, min: -10, max: 10 },
  { name: 'eyebrows_6', value: 0, min: -10, max: 10 },
  { name: 'makeup_1', value: 0, min: 0, max: 74 },
  { name: 'makeup_2', value: 0, min: 0, max: 10 },
  { name: 'makeup_3', value: 0, min: 0, max: 63 },
  { name: 'makeup_4', value: 0, min: 0, max: 63 },
  { name: 'lipstick_1', value: 0, min: 0, max: 9 },
  { name: 'lipstick_2', value: 0, min: 0, max: 10 },
  { name: 'lipstick_3', value: 0, min: 0, max: 63 },
  { name: 'lipstick_4', value: 0, min: 0, max: 63 },
  { name: 'blush_1', value: 0, min: 0, max: 6 },
  { name: 'blush_2', value: 0, min: 0, max: 10 },
  { name: 'blush_3', value: 0, min: 0, max: 63 },
  { name: 'blemishes_1', value: 0, min: 0, max: 23 },
  { name: 'blemishes_2', value: 0, min: 0, max: 10 },
  { name: 'age_1', value: 0, min: 0, max: 14 },
  { name: 'age_2', value: 0, min: 0, max: 10 },
  { name: 'complexion_1', value: 0, min: 0, max: 11 },
  { name: 'complexion_2', value: 0, min: 0, max: 10 },
  { name: 'sun_1', value: 0, min: 0, max: 10 },
  { name: 'sun_2', value: 0, min: 0, max: 10 },
  { name: 'moles_1', value: 0, min: 0, max: 17 },
  { name: 'moles_2', value: 0, min: 0, max: 10 },
  { name: 'chest_1', value: 0, min: 0, max: 16 },
  { name: 'chest_2', value: 0, min: 0, max: 10 },
  { name: 'chest_3', value: 0, min: 0, max: 63 },
  { name: 'bodyb_1', value: -1, min: -1, max: 11 },
  { name: 'bodyb_2', value: 0, min: 0, max: 10 },
  { name: 'bodyb_3', value: -1, min: -1, max: 1 },
  { name: 'bodyb_4', value: 0, min: 0, max: 10 },
  { name: 'tshirt_1', value: 0, min: 0, max: 200 },
  { name: 'tshirt_2', value: 0, min: 0, max: 20 },
  { name: 'torso_1', value: 0, min: 0, max: 400 },
  { name: 'torso_2', value: 0, min: 0, max: 20 },
  { name: 'decals_1', value: 0, min: 0, max: 120 },
  { name: 'decals_2', value: 0, min: 0, max: 20 },
  { name: 'arms', value: 0, min: 0, max: 200 },
  { name: 'arms_2', value: 0, min: 0, max: 10 },
  { name: 'bproof_1', value: 0, min: 0, max: 80 },
  { name: 'bproof_2', value: 0, min: 0, max: 20 },
  { name: 'bags_1', value: 0, min: 0, max: 120 },
  { name: 'bags_2', value: 0, min: 0, max: 20 },
  { name: 'mask_1', value: 0, min: 0, max: 180 },
  { name: 'mask_2', value: 0, min: 0, max: 20 },
  { name: 'pants_1', value: 0, min: 0, max: 180 },
  { name: 'pants_2', value: 0, min: 0, max: 20 },
  { name: 'shoes_1', value: 0, min: 0, max: 130 },
  { name: 'shoes_2', value: 0, min: 0, max: 20 },
  { name: 'chain_1', value: 0, min: 0, max: 150 },
  { name: 'chain_2', value: 0, min: 0, max: 20 },
  { name: 'helmet_1', value: -1, min: -1, max: 140 },
  { name: 'helmet_2', value: 0, min: 0, max: 20 },
  { name: 'glasses_1', value: 0, min: 0, max: 40 },
  { name: 'glasses_2', value: 0, min: 0, max: 20 },
  { name: 'ears_1', value: -1, min: -1, max: 40 },
  { name: 'ears_2', value: 0, min: 0, max: 20 },
  { name: 'watches_1', value: -1, min: -1, max: 40 },
  { name: 'watches_2', value: 0, min: 0, max: 20 },
  { name: 'bracelets_1', value: -1, min: -1, max: 40 },
  { name: 'bracelets_2', value: 0, min: 0, max: 20 }
]
