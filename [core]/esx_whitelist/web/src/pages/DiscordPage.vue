<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import {
    Alert,
    Badge,
    Card,
    CardContent,
    CardHeader,
    CardTitle,
    Input,
    Toggle,
} from 'esx-ui-kit-vue'
import { panel, updateConfig } from '../composables/usePanel'
import ListEditor from '../components/ListEditor.vue'
import NumberField from '../components/NumberField.vue'

const state = computed(() => panel.state)

const guildDraft = ref('')
watch(
    () => state.value?.discord.guildId,
    (value) => {
        guildDraft.value = value ?? ''
    },
    { immediate: true },
)

function commitGuildId(): void {
    const value = guildDraft.value.trim()
    if (value !== '' && !/^\d{17,20}$/.test(value)) {
        return
    }
    if (value !== state.value?.discord.guildId) {
        void updateConfig('Discord.GuildId', value)
    }
}

function validateSnowflake(value: string): string | null {
    if (!/^\d{17,20}$/.test(value)) {
        return 'Discord IDs are 17-20 digits'
    }
    return null
}
</script>

<template>
    <div v-if="state" class="page-stack">
        <Alert :variant="state.meta?.botTokenConfigured ? 'info' : 'warning'">
            Discord Bot Token:
            {{ state.meta?.botTokenConfigured ? 'Configured' : 'Not configured' }}. Set it via
            <code>set discord:botToken "..."</code> in server.cfg.
        </Alert>

        <Card variant="bordered">
            <CardHeader>
                <CardTitle>Discord verification</CardTitle>
            </CardHeader>
            <CardContent>
                <div class="field-row">
                    <div>
                        <div class="field-label">Discord checks enabled</div>
                        <div class="field-description">
                            Verify guild membership and roles via the Discord API.
                        </div>
                    </div>
                    <Toggle
                        :model-value="state.discord.enabled"
                        :disabled="panel.pending['Discord.Enabled'] === true"
                        @update:model-value="
                            (value: boolean) => updateConfig('Discord.Enabled', value)
                        "
                    />
                </div>

                <div class="field-grid" style="margin-top: 14px">
                    <Input
                        v-model="guildDraft"
                        label="Guild ID"
                        placeholder="123456789012345678"
                        :disabled="panel.pending['Discord.GuildId'] === true"
                        @blur="commitGuildId"
                        @keyup.enter="commitGuildId"
                    />
                </div>

                <div style="margin-top: 16px">
                    <ListEditor
                        config-key="Discord.AllowedRoles"
                        :items="state.discord.allowedRoles"
                        label="Add allowed role ID"
                        placeholder="123456789012345678"
                        hint="Members need at least one of these roles. Right-click a role in Discord (developer mode) to copy its ID."
                        :validate="validateSnowflake"
                    />
                </div>
            </CardContent>
        </Card>

        <Card variant="bordered">
            <CardHeader>
                <CardTitle>Request tuning</CardTitle>
            </CardHeader>
            <CardContent>
                <div class="field-grid">
                    <NumberField
                        config-key="Discord.Timeout"
                        :value="state.discord.timeout"
                        label="HTTP timeout (ms)"
                        hint="1000 - 15000"
                        :min="1000"
                        :max="15000"
                    />
                    <NumberField
                        config-key="Discord.MaxRetries"
                        :value="state.discord.maxRetries"
                        label="Max retries"
                        hint="Transient failures are retried with backoff."
                        :min="0"
                        :max="5"
                    />
                </div>
                <div style="margin-top: 14px">
                    <Badge variant="default">
                        API requests: {{ state.stats?.discord.requests ?? 0 }}
                    </Badge>
                    <Badge variant="default" style="margin-left: 8px">
                        Entries: {{ state.stats?.discord.cachedEntries ?? 0 }}
                    </Badge>
                    <Badge
                        variant="warning"
                        style="margin-left: 8px"
                        v-if="state.stats?.discord.rateLimited"
                    >
                        Rate limited
                    </Badge>
                </div>
            </CardContent>
        </Card>
    </div>
</template>
