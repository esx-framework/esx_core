<script lang="ts">
  export let source: string
  export let flip = false
  export let chevron = false

  function iconStyle() {
    return `--icon-url: url("${source}")`
  }
</script>

<span
  class="asset-icon"
  class:flip-x={flip}
  class:chevron={chevron}
  style={iconStyle()}
  aria-hidden="true"
></span>
