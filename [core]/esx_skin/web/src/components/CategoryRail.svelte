<script lang="ts">
  import AssetIcon from './AssetIcon.svelte'
  import CameraDock from './CameraDock.svelte'
  import type { CameraAction, CameraPreset, VisibleCategory } from '../types'
  import { logoEsxSrc } from '../data'

  export let categories: VisibleCategory[]
  export let activeCategoryId: string | undefined
  export let activeSubcategoryId: string | undefined
  export let cameraMenuOpen = false
  export let selectedCameraPreset: CameraPreset

  export let onSelectCategory: (id: string) => void = () => {}
  export let onSelectSubcategory: (categoryId: string, subcategoryId: string) => void = () => {}
  export let onToggleCamera: () => void = () => {}
  export let onCameraAction: (action: CameraAction) => void = () => {}

  export let cameraIcon: string
</script>

<aside class="skin-rail">
  <img class="esx-logo" src={logoEsxSrc} alt="ESX" />

  <nav class="rail-stack" aria-label="Skin categories">
    {#each categories as category}
      <div class="rail-section" class:open={activeCategoryId === category.id}>
        <button
          type="button"
          class="rail-button"
          class:active={activeCategoryId === category.id}
          title={category.title}
          aria-label={category.title}
          aria-expanded={category.children.length > 0 ? activeCategoryId === category.id : undefined}
          on:click={() => onSelectCategory(category.id)}
        >
          <AssetIcon source={category.icon} />
        </button>

        {#if activeCategoryId === category.id && category.children.length > 0}
          <div class="rail-subgroup" aria-label={`${category.title} subcategories`}>
            {#each category.children as subcategory}
              <button
                type="button"
                class="rail-button subcategory-button"
                class:active={activeSubcategoryId === subcategory.id}
                title={subcategory.title}
                aria-label={subcategory.title}
                on:click={() => onSelectSubcategory(category.id, subcategory.id)}
              >
                <AssetIcon source={subcategory.icon} />
              </button>
            {/each}
          </div>
        {/if}
      </div>
    {/each}
  </nav>

  <CameraDock
    open={cameraMenuOpen}
    selectedPreset={selectedCameraPreset}
    cameraIcon={cameraIcon}
    onToggle={onToggleCamera}
    onAction={onCameraAction}
  />
</aside>
