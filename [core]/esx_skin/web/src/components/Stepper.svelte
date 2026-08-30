<script lang="ts">
  import AssetIcon from './AssetIcon.svelte'
  import type { SkinElement } from '../types'
  import { chevronLeftSrc, chevronRightSrc } from '../data'

  export let element: SkinElement
  export let focused = false
  export let label: string
  export let icon: string

  export let onFocus: () => void = () => {}
  export let onChange: (value: number) => void = () => {}

  let editing = false
  let draft = ''

  function startEditing(event: FocusEvent) {
    editing = true
    draft = String(element.value)
    ;(event.target as HTMLInputElement).select()
  }

  function commitEdit() {
    editing = false
    const parsed = parseInt(draft, 10)
    draft = ''
    if (Number.isNaN(parsed)) return
    onChange(parsed)
  }

  function handleInput(event: Event) {
    draft = (event.target as HTMLInputElement).value
  }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter' || event.key === 'Escape') {
      ;(event.target as HTMLInputElement).blur()
    }

    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      event.stopPropagation()
    }
  }
</script>

<div
  class="stepper"
  class:focused={focused}
  role="group"
  aria-label={label}
>
  <button class="step-icon" type="button" aria-label={label} onclick={onFocus}>
    <AssetIcon source={icon} />
  </button>

  <button class="step-arrow" type="button" aria-label="Previous" onclick={() => onChange(element.value - 1)}>
    <AssetIcon source={chevronLeftSrc} chevron={true} />
  </button>

  <input
    class="step-value"
    type="number"
    min={element.min}
    max={element.max}
    value={editing ? draft : element.value}
    aria-label={label}
    onfocus={startEditing}
    oninput={handleInput}
    onkeydown={handleKeydown}
    onblur={commitEdit}
  />

  <button class="step-arrow" type="button" aria-label="Next" onclick={() => onChange(element.value + 1)}>
    <AssetIcon source={chevronRightSrc} chevron={true} />
  </button>
</div>
