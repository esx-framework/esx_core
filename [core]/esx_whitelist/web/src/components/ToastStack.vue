<script setup lang="ts">
import { panel } from "../composables/usePanel"
</script>

<template>
  <div class="toast-stack">
    <div
      v-for="toast in panel.toasts"
      :key="toast.id"
      class="toast"
      :class="toast.kind"
    >
      {{ toast.text }}
    </div>
  </div>
</template>
