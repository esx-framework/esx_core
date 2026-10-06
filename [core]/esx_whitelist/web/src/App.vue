<script setup lang="ts">
import { onBeforeUnmount, onMounted } from "vue"
import { Tabs } from "esx-ui-kit-vue"
import type { NuiInboundMessage, PanelState } from "./types"
import { handleAck, panel, requestClose } from "./composables/usePanel"
import { applyTheme, FALLBACK_THEME } from "./composables/useTheme"
import { isNui } from "./services/nui"
import AppHeader from "./components/AppHeader.vue"
import ToastStack from "./components/ToastStack.vue"
import DashboardPage from "./pages/DashboardPage.vue"
import GeneralPage from "./pages/GeneralPage.vue"
import DiscordPage from "./pages/DiscordPage.vue"
import AdminPage from "./pages/AdminPage.vue"
import LoggingPage from "./pages/LoggingPage.vue"

const tabs = [
  { id: "dashboard", label: "Dashboard" },
  { id: "general", label: "Whitelist" },
  { id: "discord", label: "Discord" },
  { id: "admin", label: "Admins" },
  { id: "logging", label: "Logging & Performance" },
]

function onMessage(event: MessageEvent): void {
  const data = event.data as NuiInboundMessage
  if (!data || typeof data !== "object") {
    return
  }

  if (data.action === "open") {
    panel.state = data.state
    applyTheme(data.theme)
    panel.visible = true
  } else if (data.action === "close") {
    panel.visible = false
  } else if (data.action === "state") {
    panel.state = data.state
  } else if (data.action === "ack") {
    if (data.ack.ok && data.ack.state) {
      panel.state = data.ack.state
    }
    handleAck(data.ack)
  }
}

function onKeyUp(event: KeyboardEvent): void {
  if (event.key === "Escape" && panel.visible) {
    requestClose()
  }
}

/** Mock state so `npm run dev` renders the panel in a plain browser. */
const DEV_STATE: PanelState = {
  whitelist: {
    enabled: true,
    mode: "discord",
    combinationMode: "or",
    allowedIdentifiers: ["license2:0123456789abcdef0123456789abcdef01234567"],
  },
  discord: {
    enabled: true,
    guildId: "123456789012345678",
    allowedRoles: ["234567890123456789"],
    timeout: 5000,
    maxRetries: 2,
  },
  admin: {
    groups: { admin: true, superadmin: true, owner: true },
    cacheEnabled: true,
    cacheSaveDelay: 5000,
  },
  adminOnly: {
    enabled: false,
    groups: { admin: true, superadmin: true, owner: true },
    allowedIdentifiers: [],
  },
  bypass: { allowedIdentifiers: [] },
  logging: { enabled: true, minInterval: 1200, batchSize: 5 },
  performance: { discordConcurrency: 10, discordQueueLimit: 4096, verificationTimeout: 120000 },
  meta: {
    version: "1.0.0",
    botTokenConfigured: true,
    webhookConfigured: false,
    resourceName: "esx_whitelist",
  },
  stats: {
    service: { total: 128, allowed: 120, denied: 8, byMethod: { discord: 100, identifier: 20 } },
    discord: {
      requests: 40,
      cacheHits: 80,
      shared: 8,
      rateLimits: 1,
      errors: 0,
      allowed: 100,
      denied: 6,
      queueLength: 0,
      activeRequests: 0,
      cachedEntries: 96,
      rateLimited: false,
    },
    logger: { queued: 0, sent: 126, failed: 0, dropped: 0, webhookConfigured: false },
    adminCacheEntries: 4,
    identifierCounts: { whitelist: 1, adminOnly: 0, bypass: 0 },
  },
}

onMounted(() => {
  window.addEventListener("message", onMessage)
  window.addEventListener("keyup", onKeyUp)
  applyTheme(FALLBACK_THEME)

  if (!isNui) {
    panel.state = DEV_STATE
    panel.visible = true
  }
})

onBeforeUnmount(() => {
  window.removeEventListener("message", onMessage)
  window.removeEventListener("keyup", onKeyUp)
})
</script>

<template>
  <Transition name="panel">
    <div v-if="panel.visible" class="panel-backdrop">
      <div class="panel-shell">
        <AppHeader :version="panel.state?.meta?.version ?? '1.0.0'" />
        <div class="panel-body">
          <Tabs :tabs="tabs" default-tab="dashboard">
            <template #dashboard>
              <DashboardPage />
            </template>
            <template #general>
              <GeneralPage />
            </template>
            <template #discord>
              <DiscordPage />
            </template>
            <template #admin>
              <AdminPage />
            </template>
            <template #logging>
              <LoggingPage />
            </template>
          </Tabs>
        </div>
      </div>
      <ToastStack />
    </div>
  </Transition>
</template>
