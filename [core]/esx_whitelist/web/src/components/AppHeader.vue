<script setup lang="ts">
import { Button } from 'esx-ui-kit-vue'
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
        <div class="panel-close">
            <Button variant="text" size="sm" @click="requestClose">Close (ESC)</Button>
        </div>
    </header>
</template>
