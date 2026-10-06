<script setup lang="ts">
import { computed } from "vue"
import { Alert, Card, CardContent, CardHeader, CardTitle, Toggle } from "esx-ui-kit-vue"
import { panel, updateConfig } from "../composables/usePanel"
import NumberField from "../components/NumberField.vue"

const state = computed(() => panel.state)
</script>

<template>
  <div v-if="state" class="page-stack">
    <Alert variant="info">
      The webhook URL is a secret and stays in server.cfg
      (<code>set whitelist:webhook "..."</code>).
    </Alert>

    <Card variant="bordered">
      <CardHeader>
        <CardTitle>Webhook logging</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="field-row">
          <div>
            <div class="field-label">Webhook logging enabled</div>
            <div class="field-description">
              Status: {{ state.meta?.webhookConfigured ? "webhook configured" : "no webhook configured" }}
            </div>
          </div>
          <Toggle
            :model-value="state.logging.enabled"
            :disabled="panel.pending['Logging.Enabled'] === true"
            @update:model-value="(value: boolean) => updateConfig('Logging.Enabled', value)"
          />
        </div>
        <div class="field-grid" style="margin-top: 14px">
          <NumberField
            config-key="Logging.MinInterval"
            :value="state.logging.minInterval"
            label="Min interval (ms)"
            hint="Webhook requests are throttled to one per interval."
            :min="500"
            :max="10000"
          />
          <NumberField
            config-key="Logging.BatchSize"
            :value="state.logging.batchSize"
            label="Batch size"
            hint="Events bundled per webhook request (max 10)."
            :min="1"
            :max="10"
          />
        </div>
      </CardContent>
    </Card>

    <Card variant="bordered">
      <CardHeader>
        <CardTitle>Performance</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="field-grid">
          <NumberField
            config-key="Performance.DiscordConcurrency"
            :value="state.performance.discordConcurrency"
            label="Discord concurrency"
            hint="Max simultaneous Discord API requests."
            :min="1"
            :max="25"
          />
          <NumberField
            config-key="Performance.DiscordQueueLimit"
            :value="state.performance.discordQueueLimit"
            label="Queue limit"
            hint="Bounded pending Discord checks."
            :min="64"
            :max="8192"
          />
          <NumberField
            config-key="Performance.VerificationTimeout"
            :value="state.performance.verificationTimeout"
            label="Verification deadline (ms)"
            hint="Maximum wait for a rate-limited Discord check."
            :min="2000"
            :max="180000"
          />
        </div>
      </CardContent>
    </Card>
  </div>
</template>
