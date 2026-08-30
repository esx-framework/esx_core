<script lang="ts">
  import './styles.css'
  import CategoryRail from './components/CategoryRail.svelte'
  import CameraDock from './components/CameraDock.svelte'
  import Stepper from './components/Stepper.svelte'
  import type {
    CameraAction,
    CameraPreset,
    ControlSelector,
    SkinCategory,
    SkinElement,
    SkinPayload,
    VisibleCategory
  } from './types'
  import { categories, cameraPresets, demoElements, icon, labelMap } from './data'

  declare global {
    interface Window {
      GetParentResourceName?: () => string
      invokeNative?: unknown
    }
  }

  let visible = typeof window.invokeNative !== 'function'
  let title = 'Appearance'
  let submitLabel = 'CREATE CHARACTER'
  let activeName = 'sex'
  let elements: SkinElement[] = visible ? demoElements : []
  let cameraPreset = 0
  let cameraMenuOpen = false

  const resource = window.GetParentResourceName?.() ?? 'esx_skin'

  const FACE_DETAIL = ['mom', 'dad', 'grandparents', 'face_md_weight', 'face_g_weight', 'skin_md_weight']

  function send(action: string, payload: Record<string, unknown> = {}) {
    return fetch(`https://${resource}/${action}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(payload)
    }).catch(() => null)
  }

  function accepts(selector: ControlSelector, name: string) {
    if (selector.names?.includes(name)) return true
    return selector.prefix?.some((prefix) => name === prefix || name.startsWith(prefix)) ?? false
  }

  function uniqueControls(groups: SkinElement[][]) {
    const used = new Set<string>()

    return groups.flat().filter((element) => {
      if (used.has(element.name)) return false
      used.add(element.name)
      return true
    })
  }

  function controlsFor(selector: ControlSelector) {
    const controls = elements.filter((element) => accepts(selector, element.name))

    if (!selector.names) {
      return controls
    }

    const order = new Map(selector.names.map((name, index) => [name, index]))
    return [...controls].sort((left, right) => (order.get(left.name) ?? 999) - (order.get(right.name) ?? 999))
  }

  function firstControl(category: VisibleCategory) {
    return category.children[0]?.controls[0] ?? category.controls[0]
  }

  $: activeElement = elements.find((element) => element.name === activeName) ?? elements[0]
  $: visibleCategories = categories
    .map((category): VisibleCategory => {
      const children = (category.children ?? [])
        .map((child) => ({ ...child, controls: controlsFor(child) }))
        .filter((child) => child.controls.length > 0)
      const controls = uniqueControls([controlsFor(category), ...children.map((child) => child.controls)])

      return { ...category, controls, children }
    })
    .filter((category) => category.controls.length > 0)
  $: activeCategory = visibleCategories.find((category) => category.controls.some((element) => element.name === activeName)) ?? visibleCategories[0]
  $: activeSubcategory = activeCategory?.children.find((child) => child.controls.some((element) => element.name === activeName)) ?? activeCategory?.children[0]
  $: categoryControls = (activeSubcategory?.controls ?? activeCategory?.controls ?? []).filter((element) => element.name !== 'sex')
  $: gender = elements.find((element) => element.name === 'sex')
  $: selectedCameraPreset = cameraPresets[cameraPreset] ?? 'face'

  function displayLabel(element: SkinElement) {
    return labelMap[element.name] ?? (element.label ?? element.name).replace(/_/g, ' ').toUpperCase()
  }

  function rowIcon(element: SkinElement) {
    if (FACE_DETAIL.includes(element.name)) return icon.faceDetail

    if (element.name.startsWith('nose_')) return icon.nose
    if (element.name === 'lip_thickness') return icon.mouth
    if (element.name.startsWith('neck_')) return icon.neck
    if (element.name === 'eye_color' || element.name === 'eye_squint') return icon.eyes
    if (element.name.startsWith('eyebrows_')) return element.name.includes('_3') || element.name.includes('_4') ? icon.makeup : icon.faceDetail
    if (element.name.startsWith('hair_')) return icon.hair
    if (element.name.startsWith('beard_')) return icon.beard
    if (element.name.startsWith('age_')) return icon.wrinkles
    if (element.name.startsWith('makeup_') || element.name.startsWith('blush_')) return icon.makeup
    if (element.name.startsWith('lipstick_')) return icon.mouth

    if (
      element.name.startsWith('blemishes_') ||
      element.name.startsWith('complexion_') ||
      element.name.startsWith('sun_') ||
      element.name.startsWith('moles_') ||
      element.name.startsWith('bodyb_')
    ) {
      return icon.portrait
    }

    if (element.name.startsWith('chest_')) return icon.body

    if (
      element.name.startsWith('torso_') ||
      element.name.startsWith('decals_') ||
      element.name === 'arms' ||
      element.name === 'arms_2' ||
      element.name.startsWith('bproof_')
    ) {
      return icon.torso
    }

    if (
      element.name.startsWith('tshirt_') ||
      element.name.startsWith('bags_') ||
      element.name.startsWith('chain_') ||
      element.name.startsWith('mask_')
    ) {
      return element.name.startsWith('mask_') ? icon.faceAlt : icon.shirt
    }

    if (element.name.startsWith('pants_')) return icon.pants
    if (element.name.startsWith('shoes_')) return icon.shoes
    if (
      element.name.startsWith('helmet_') ||
      element.name.startsWith('glasses_') ||
      element.name.startsWith('ears_') ||
      element.name.startsWith('watches_') ||
      element.name.startsWith('bracelets_')
    ) {
      return icon.accessories
    }

    const category = categories.find((entry) => accepts(entry, element.name))
    return category?.icon ?? icon.faceDetail
  }

  function wrap(value: number, min = 0, max = 0) {
    if (max < min) max = min
    if (value > max) return min
    if (value < min) return max
    return value
  }

  function setValue(element: SkinElement, value: number) {
    activeName = element.name
    const next = wrap(Math.round(value), Number(element.min ?? 0), Number(element.max ?? 0))
    elements = elements.map((item) => item.name === element.name ? { ...item, value: next } : item)
    send('skinMenu:change', { name: element.name, value: next })
  }

  function focus(element: SkinElement) {
    cameraMenuOpen = false
    activeName = element.name
    send('skinMenu:focus', { name: element.name })
  }

  function setCategory(id: string) {
    const category = visibleCategories.find((item) => item.id === id)
    const first = category ? firstControl(category) : undefined
    if (first) focus(first)
  }

  function setSubcategory(categoryId: string, subcategoryId: string) {
    const category = visibleCategories.find((item) => item.id === categoryId)
    const subcategory = category?.children.find((item) => item.id === subcategoryId)
    const first = subcategory?.controls[0]
    if (first) focus(first)
  }

  function submit() {
    cameraMenuOpen = false
    visible = false
    send('skinMenu:submit', { name: activeElement?.name })
  }

  function cancel() {
    cameraMenuOpen = false
    visible = false
    send('skinMenu:cancel', { name: activeElement?.name })
  }

  function reset() {
    send('skinMenu:reset')
  }

  function rotate(direction: 'left' | 'right') {
    send('skinMenu:rotate', { direction })
  }

  function toggleCameraMenu() {
    cameraMenuOpen = !cameraMenuOpen
  }

  function runCameraAction(action: CameraAction) {
    if (action.preset) {
      const presetIndex = cameraPresets.indexOf(action.preset)
      if (presetIndex >= 0) cameraPreset = presetIndex
      send('skinMenu:camera', { preset: action.preset })
    } else if (action.direction) {
      rotate(action.direction)
    } else if (action.reset) {
      reset()
    }

    cameraMenuOpen = false
  }

  function onMessage(event: MessageEvent<SkinPayload>) {
    const data = event.data
    if (!data || typeof data.action !== 'string') return

    if (data.action === 'skinMenu:close') {
      cameraMenuOpen = false
      visible = false
      return
    }

    if (data.action === 'skinMenu:open') {
      title = data.title ?? 'Appearance'
      submitLabel = data.submitLabel ?? 'CREATE CHARACTER'
      elements = Array.isArray(data.elements) ? data.elements : []
      activeName = data.active ?? elements[0]?.name ?? ''
      cameraMenuOpen = false
      visible = true
    }
  }

  function onKeydown(event: KeyboardEvent) {
    if (!visible || !activeElement) return

    if (event.key === 'Escape' && cameraMenuOpen) {
      event.preventDefault()
      cameraMenuOpen = false
    } else if (event.key === 'Escape') {
      event.preventDefault()
      cancel()
    } else if (event.key === 'Enter') {
      event.preventDefault()
      submit()
    } else if (event.key === 'ArrowLeft') {
      event.preventDefault()
      setValue(activeElement, activeElement.value - 1)
    } else if (event.key === 'ArrowRight') {
      event.preventDefault()
      setValue(activeElement, activeElement.value + 1)
    }
  }

  window.addEventListener('message', onMessage)
  window.addEventListener('keydown', onKeydown)
</script>

{#if visible}
  <main class="skin-shell" aria-label={title}>
    <CategoryRail
      categories={visibleCategories}
      activeCategoryId={activeCategory?.id}
      activeSubcategoryId={activeSubcategory?.id}
      cameraMenuOpen={cameraMenuOpen}
      selectedCameraPreset={selectedCameraPreset}
      cameraIcon={icon.camera}
      onSelectCategory={setCategory}
      onSelectSubcategory={setSubcategory}
      onToggleCamera={toggleCameraMenu}
      onCameraAction={runCameraAction}
    />

    <section class="skin-panel">
      <div class="skin-scroll">
        {#if gender && activeCategory?.id === 'identity'}
          <section class="field-block gender-block">
            <h2>GENDER</h2>
            <div class="gender-toggle">
              <button type="button" class:active={gender.value === 0} on:click={() => setValue(gender, 0)}>MALE</button>
              <button type="button" class:active={gender.value === 1} on:click={() => setValue(gender, 1)}>FEMALE</button>
            </div>
          </section>
        {/if}

        {#each categoryControls as element}
          <section class="field-block">
            <h2>{displayLabel(element)}</h2>
            <Stepper
              element={element}
              focused={activeName === element.name}
              label={displayLabel(element)}
              icon={rowIcon(element)}
              onFocus={() => focus(element)}
              onChange={(value) => setValue(element, value)}
            />
          </section>
        {/each}
      </div>

      <div class="skin-footer">
        <button type="button" class="submit-button" on:click={submit}>{submitLabel}</button>
      </div>
    </section>
  </main>
{/if}
