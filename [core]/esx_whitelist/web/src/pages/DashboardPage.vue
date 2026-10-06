<script setup lang="ts">
import { computed } from 'vue'
import { Badge, Card, CardContent, CardHeader, CardTitle } from 'esx-ui-kit-vue'
import { panel } from '../composables/usePanel'

const state = computed(() => panel.state)

const cards = computed(() => {
    const stats = state.value?.stats
    if (!stats) {
        return []
    }
    return [
        { label: 'Total checks', value: stats.service.total },
        { label: 'Allowed', value: stats.service.allowed },
        { label: 'Denied', value: stats.service.denied },
        { label: 'Discord API requests', value: stats.discord.requests },
        { label: 'Cache hits', value: stats.discord.cacheHits },
        { label: 'Shared', value: stats.discord.shared },
        { label: 'Rate-limit events', value: stats.discord.rateLimits },
        { label: 'Admin entries', value: stats.adminCacheEntries },
        { label: 'Discord entries', value: stats.discord.cachedEntries },
        { label: 'Webhook events sent', value: stats.logger.sent },
    ]
})
</script>

<template>
    <div v-if="state" class="page-stack">
        <Card variant="bordered">
            <CardHeader>
                <CardTitle>System status</CardTitle>
            </CardHeader>
            <CardContent>
                <div style="display: flex; flex-wrap: wrap; gap: 8px">
                    <Badge :variant="state.whitelist.enabled ? 'default' : 'warning'">
                        Whitelist {{ state.whitelist.enabled ? 'enabled' : 'disabled' }}
                    </Badge>
                    <Badge variant="default">Mode: {{ state.whitelist.mode }}</Badge>
                    <Badge :variant="state.adminOnly.enabled ? 'warning' : 'default'">
                        Admin-only {{ state.adminOnly.enabled ? 'ON' : 'off' }}
                    </Badge>
                    <Badge :variant="state.meta?.botTokenConfigured ? 'default' : 'warning'">
                        Discord bot token:
                        {{ state.meta?.botTokenConfigured ? 'Configured' : 'Missing' }}
                    </Badge>
                    <Badge :variant="state.meta?.webhookConfigured ? 'default' : 'warning'">
                        Webhook: {{ state.meta?.webhookConfigured ? 'Configured' : 'Missing' }}
                    </Badge>
                </div>
                <p class="section-hint" style="margin-top: 12px">
                    Secrets such as the bot token and webhook URL are managed in server.cfg and are
                    never shown here.
                </p>
            </CardContent>
        </Card>

        <Card variant="bordered">
            <CardHeader>
                <CardTitle>Runtime statistics</CardTitle>
            </CardHeader>
            <CardContent>
                <div class="stat-grid">
                    <div v-for="card in cards" :key="card.label">
                        <div class="stat-value">{{ card.value }}</div>
                        <div class="stat-label">{{ card.label }}</div>
                    </div>
                </div>
            </CardContent>
        </Card>
    </div>
</template>
