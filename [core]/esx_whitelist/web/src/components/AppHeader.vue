<script setup lang="ts">
import { requestClose } from '../composables/usePanel'
</script>

<template>
    <header class="panel-header">
        <!-- Logo comes from the esx:ui:logoUrl convar via --esx-logo-url. -->
        <div class="panel-logo" />
        <div>
            <h1 class="panel-title">ESX WHITELIST PANEL</h1>
            <p class="panel-subtitle">Dynamic Whitelist Management</p>
        </div>
        <button class="panel-close" type="button" aria-label="Close" title="Close (ESC)" @click="requestClose">
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
                <path d="M18 6 6 18M6 6l12 12" />
            </svg>
        </button>
    </header>
</template>
