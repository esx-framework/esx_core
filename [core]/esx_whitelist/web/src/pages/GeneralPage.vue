<script setup lang="ts">
import { computed } from "vue"
import { Card, CardContent, CardHeader, CardTitle, Radio, Toggle } from "esx-ui-kit-vue"
import { panel, updateConfig } from "../composables/usePanel"
import ListEditor from "../components/ListEditor.vue"

const state = computed(() => panel.state)

const IDENTIFIER_PATTERN = /^[a-z0-9]+:[\w._-]+$/i

function validateIdentifier(value: string): string | null {
  if (value.length > 128) {
    return "Too long (max 128 characters)"
  }
  if (!IDENTIFIER_PATTERN.test(value)) {
    return 'Expected format "prefix:value", e.g. license2:abc...'
  }
  return null
}
</script>

<template>
  <div v-if="state" class="page-stack">
    <Card variant="bordered">
      <CardHeader>
        <CardTitle>Whitelist</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="field-row">
          <div>
            <div class="field-label">Whitelist enabled</div>
            <div class="field-description">When disabled, everyone can connect.</div>
          </div>
          <Toggle
            :model-value="state.whitelist.enabled"
            :disabled="panel.pending['Whitelist.Enabled'] === true"
            @update:model-value="(value: boolean) => updateConfig('Whitelist.Enabled', value)"
          />
        </div>

        <div style="margin-top: 12px">
          <div class="field-label" style="margin-bottom: 8px">Verification mode</div>
          <div style="display: flex; gap: 20px; flex-wrap: wrap">
            <Radio
              :model-value="state.whitelist.mode"
              value="discord"
              name="wl-mode"
              label="Discord role"
              @update:model-value="(value: string) => updateConfig('Whitelist.Mode', value)"
            />
            <Radio
              :model-value="state.whitelist.mode"
              value="identifier"
              name="wl-mode"
              label="Identifier list"
              @update:model-value="(value: string) => updateConfig('Whitelist.Mode', value)"
            />
            <Radio
              :model-value="state.whitelist.mode"
              value="both"
              name="wl-mode"
              label="Both"
              @update:model-value="(value: string) => updateConfig('Whitelist.Mode', value)"
            />
          </div>
        </div>

        <div v-if="state.whitelist.mode === 'both'" style="margin-top: 12px">
          <div class="field-label" style="margin-bottom: 8px">Combination logic</div>
          <div style="display: flex; gap: 20px">
            <Radio
              :model-value="state.whitelist.combinationMode"
              value="or"
              name="wl-comb"
              label="Identifier OR Discord"
              @update:model-value="(value: string) => updateConfig('Whitelist.CombinationMode', value)"
            />
            <Radio
              :model-value="state.whitelist.combinationMode"
              value="and"
              name="wl-comb"
              label="Identifier AND Discord"
              @update:model-value="(value: string) => updateConfig('Whitelist.CombinationMode', value)"
            />
          </div>
        </div>
      </CardContent>
    </Card>

    <Card variant="bordered">
      <CardHeader>
        <CardTitle>Allowed identifiers</CardTitle>
      </CardHeader>
      <CardContent>
        <ListEditor
          config-key="Whitelist.AllowedIdentifiers"
          :items="state.whitelist.allowedIdentifiers"
          label="Add identifier"
          placeholder="license2:1234567890abcdef..."
          hint="FiveM identifiers (license, license2, discord, steam, ...). Any single match grants access."
          :validate="validateIdentifier"
        />
      </CardContent>
    </Card>

    <Card variant="bordered">
      <CardHeader>
        <CardTitle>Emergency bypass</CardTitle>
      </CardHeader>
      <CardContent>
        <ListEditor
          config-key="Bypass.AllowedIdentifiers"
          :items="state.bypass.allowedIdentifiers"
          label="Add bypass identifier"
          placeholder="license2:1234567890abcdef..."
          hint="Evaluated before every other check, including admin-only mode. Keep this list tiny."
          :validate="validateIdentifier"
        />
      </CardContent>
    </Card>
  </div>
</template>
