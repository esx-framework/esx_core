export type SkinElement = {
  label?: string
  name: string
  value: number
  min?: number
  max?: number
  textureof?: string
  zoomOffset?: number
  camOffset?: number
}

export type SkinPayload = {
  action: string
  title?: string
  submitLabel?: string
  active?: string
  elements?: SkinElement[]
  saveable?: boolean
  creating?: boolean
  restricted?: boolean
}

export type ControlSelector = {
  names?: string[]
  prefix?: string[]
}

export type SkinSubcategory = ControlSelector & {
  id: string
  title: string
  icon: string
}

export type SkinCategory = ControlSelector & {
  id: string
  title: string
  icon: string
  children?: SkinSubcategory[]
}

export type VisibleSubcategory = SkinSubcategory & {
  controls: SkinElement[]
}

export type VisibleCategory = SkinCategory & {
  controls: SkinElement[]
  children: VisibleSubcategory[]
}

export type CameraPreset = 'full' | 'face' | 'torso' | 'legs' | 'shoes'

export type CameraAction = {
  id: string
  title: string
  icon: string
  preset?: CameraPreset
  direction?: 'left' | 'right'
  reset?: boolean
  flip?: boolean
}
