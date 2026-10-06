<script setup lang="ts">
import { computed } from 'vue'
import { Card, CardContent, CardHeader, CardTitle, Toggle } from 'esx-ui-kit-vue'
import { panel, updateConfig } from '../composables/usePanel'
import GroupEditor from '../components/GroupEditor.vue'
import ListEditor from '../components/ListEditor.vue'
import { validateAccessIdentifier } from '../services/identifier'

const state = computed(() => panel.state)

function validateIdentifier(value: string): string | null {
    return validateAccessIdentifier(value, state.value?.whitelist.identifierTypes ?? [])
}
</script>

<template>
    <div v-if="state" class="page-stack">
        <Card variant="bordered">
            <CardHeader>
                <CardTitle>Admin groups</CardTitle>
            </CardHeader>
            <CardContent>
                <p class="section-hint">
                    Players whose current ESX group is enabled here pass the whitelist via
                    <code>admin_group</code> and can open this panel.
                </p>
                <GroupEditor
                    config-key="Admin.Groups"
                    :groups="state.admin.groups"
                    label="Add ESX group"
                    hint="Group names as defined in your ESX configuration (e.g. admin, superadmin, owner)."
                />
            </CardContent>
        </Card>

        <Card variant="bordered">
            <CardHeader>
                <CardTitle>Admin group access</CardTitle>
            </CardHeader>
            <CardContent>
                <div class="field-row">
                    <div>
                        <div class="field-label">Allow access by ESX group</div>
                        <div class="field-description">
                            The current ESX group is verified before access is granted.
                        </div>
                    </div>
                    <Toggle
                        :model-value="state.admin.cacheEnabled"
                        :disabled="panel.pending['Admin.Cache.Enabled'] === true"
                        @update:model-value="
                            (value: boolean) => updateConfig('Admin.Cache.Enabled', value)
                        "
                    />
                </div>
                <p class="section-hint" style="margin-top: 10px">
                    Discovered administrators: {{ state.stats?.adminCacheEntries ?? 0 }}
                </p>
            </CardContent>
        </Card>

        <Card variant="bordered">
            <CardHeader>
                <CardTitle>Admin-only mode</CardTitle>
            </CardHeader>
            <CardContent>
                <div class="field-row">
                    <div>
                        <div class="field-label">Admin-only mode</div>
                        <div class="field-description">
                            When enabled, only the identifiers and groups below can connect.
                        </div>
                    </div>
                    <Toggle
                        :model-value="state.adminOnly.enabled"
                        :disabled="panel.pending['AdminOnly.Enabled'] === true"
                        @update:model-value="
                            (value: boolean) => updateConfig('AdminOnly.Enabled', value)
                        "
                    />
                </div>

                <GroupEditor
                    config-key="AdminOnly.Groups"
                    :groups="state.adminOnly.groups"
                    label="Add group allowed in admin-only mode"
                />

                <div style="margin-top: 16px">
                    <ListEditor
                        config-key="AdminOnly.AllowedIdentifiers"
                        :items="state.adminOnly.allowedIdentifiers"
                        label="Add admin identifier"
                        placeholder="license2:1234567890abcdef..."
                        hint="Explicit identifiers that may connect while admin-only mode is on."
                        :validate="validateIdentifier"
                    />
                </div>
            </CardContent>
        </Card>
    </div>
</template>
