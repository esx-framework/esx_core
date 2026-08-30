<script lang="ts">
  import AssetIcon from './AssetIcon.svelte'
  import type { CameraAction, CameraPreset } from '../types'
  import { cameraActions } from '../data'

  export let open = false
  export let selectedPreset: CameraPreset

  export let onToggle: () => void = () => {}
  export let onAction: (action: CameraAction) => void = () => {}

  export let cameraIcon: string
</script>

<div class="camera-dock" class:open={open} aria-label="Camera tools">
  {#if open}
    <div class="camera-popover" aria-label="Camera options">
      {#each cameraActions as action}
        <button
          type="button"
          class="rail-button camera-action"
          class:active={action.preset === selectedPreset}
          title={action.title}
          aria-label={action.title}
          on:click={() => onAction(action)}
        >
          <AssetIcon source={action.icon} flip={action.flip ?? false} />
        </button>
      {/each}
    </div>
  {/if}

  <button
    type="button"
    class="rail-button camera-trigger"
    class:active={open}
    title="Camera"
    aria-label="Camera"
    aria-expanded={open}
    on:click={onToggle}
  >
    <AssetIcon source={cameraIcon} />
  </button>
</div>
