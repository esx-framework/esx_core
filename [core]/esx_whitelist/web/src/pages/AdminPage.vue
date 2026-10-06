<script setup lang="ts">
import { computed } from "vue"
import { Card, CardContent, CardHeader, CardTitle, Toggle } from "esx-ui-kit-vue"
import { panel, updateConfig } from "../composables/usePanel"
import GroupEditor from "../components/GroupEditor.vue"
import ListEditor from "../components/ListEditor.vue"
import NumberField from "../components/NumberField.vue"

const state = computed(() => panel.state)

const IDENTIFIER_PATTERN = /^[a-z0-9]+:[\w._-]+$/i

function validateIdentifier(value: string): string | null {
  if (value.length > 128 || !IDENTIFIER_PATTERN.test(value)) {
    return 'Expected format "prefix:value", e.g. license2:abc...'
  }
  return null
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
          Players whose cached ESX group is enabled here pass the whitelist via
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
        <CardTitle>Admin group cache</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="field-row">
          <div>
            <div class="field-label">Persistent cache</div>
            <div class="field-description">Entries remain until updated or removed.</div>
          </div>
          <Toggle
            :model-value="state.admin.cacheEnabled"
            :disabled="panel.pending['Admin.Cache.Enabled'] === true"
            @update:model-value="(value: boolean) => updateConfig('Admin.Cache.Enabled', value)"
          />
        </div>
        <div class="field-grid" style="margin-top: 14px">
          <NumberField
            config-key="Admin.Cache.SaveDelay"
            :value="state.admin.cacheSaveDelay"
            label="Save debounce (ms)"
            hint="Writes are batched; never per-event."
            :min="1000"
            :max="60000"
          />
        </div>
        <p class="section-hint" style="margin-top: 10px">
          Cached entries: {{ state.stats?.adminCacheEntries ?? 0 }}
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
            @update:model-value="(value: boolean) => updateConfig('AdminOnly.Enabled', value)"
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
