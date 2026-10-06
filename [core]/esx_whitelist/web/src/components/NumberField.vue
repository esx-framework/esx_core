<script setup lang="ts">
import { ref, watch } from 'vue'
import { Input } from 'esx-ui-kit-vue'
import { panel, updateConfig } from '../composables/usePanel'

const props = defineProps<{
    configKey: string
    value: number
    label: string
    hint?: string
    min?: number
    max?: number
}>()

const draft = ref(String(props.value))
const error = ref('')

watch(
    () => props.value,
    (next) => {
        draft.value = String(next)
    },
)

function commit(): void {
    const parsed = Number(draft.value)
    if (!Number.isInteger(parsed)) {
        error.value = 'Must be an integer'
        return
    }
    if (props.min !== undefined && parsed < props.min) {
        error.value = `Minimum is ${props.min}`
        return
    }
    if (props.max !== undefined && parsed > props.max) {
        error.value = `Maximum is ${props.max}`
        return
    }
    error.value = ''
    if (parsed !== props.value) {
        void updateConfig(props.configKey, parsed)
    }
}
</script>

<template>
    <div>
        <Input
            v-model="draft"
            type="number"
            :label="label"
            :error="error || undefined"
            :disabled="panel.pending[configKey] === true"
            @blur="commit"
            @keyup.enter="commit"
        />
        <p v-if="hint" class="section-hint" style="margin-top: 4px">{{ hint }}</p>
    </div>
</template>
