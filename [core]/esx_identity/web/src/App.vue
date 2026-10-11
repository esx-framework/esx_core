<!-- SPDX-License-Identifier: GPL-3.0-only -->
<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import Identity from "./components/Identity.vue";
import { inGame, isPreview, postNui } from "./nui.js";
import { applyTheme } from "./theme.js";

const previewLocale = new URLSearchParams(window.location.search).get("lang") || "es";
const visible = ref(isPreview);
const settings = ref(isPreview ? { locale: previewLocale } : {});
const theme = ref({});
function onMessage(event) {
    if (event.data?.type !== "enableui" || typeof event.data.enable !== "boolean") return;
    if (event.data.settings) settings.value = event.data.settings;
    if (event.data.theme && typeof event.data.theme === "object") {
        theme.value = event.data.theme;
        applyTheme(event.data.theme);
    }
    visible.value = event.data.enable;
}
onMounted(() => {
    window.addEventListener("message", onMessage);
    if (inGame) postNui("ready").catch((error) => console.error("[esx_identity] NUI ready:", error));
});
onUnmounted(() => window.removeEventListener("message", onMessage));
</script>
<template><Identity v-if="visible" :settings="settings" :theme="theme" /></template>
