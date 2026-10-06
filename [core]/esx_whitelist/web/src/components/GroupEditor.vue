<script setup lang="ts">
import { ref } from 'vue'
import { Button, Input, Toggle } from 'esx-ui-kit-vue'
import { panel, updateConfig } from '../composables/usePanel'

const props = defineProps<{
    configKey: string
    groups: Record<string, boolean>
    label: string
    hint?: string
}>()

const draft = ref('')
const error = ref('')

function commit(next: Record<string, boolean>): void {
    void updateConfig(props.configKey, next)
}

function add(): void {
    const name = draft.value.trim()
    if (!/^[\w]+$/.test(name) || name.length > 32) {
        error.value = 'Letters, digits and underscore only (max 32)'
        return
    }
    if (name in props.groups) {
        error.value = 'Group already exists'
        return
    }
    error.value = ''
    commit({ ...props.groups, [name]: true })
    draft.value = ''
}

function setEnabled(name: string, enabled: boolean): void {
    commit({ ...props.groups, [name]: enabled })
}

function remove(name: string): void {
    const next = { ...props.groups }
    delete next[name]
    commit(next)
}
</script>

<template>
    <div>
        <div class="list-editor-form">
            <Input
                v-model="draft"
                :label="label"
                placeholder="e.g. moderator"
                :error="error || undefined"
                :disabled="panel.pending[configKey] === true"
                @keyup.enter="add"
            />
            <Button
                variant="primary"
                size="md"
                :disabled="panel.pending[configKey] === true"
                @click="add"
            >
                Add
            </Button>
        </div>
        <p v-if="hint" class="section-hint" style="margin-top: 6px">{{ hint }}</p>
        <div style="margin-top: 8px">
            <div v-if="Object.keys(groups).length === 0" class="empty-note">
                No groups configured.
            </div>
            <div v-for="(enabled, name) in groups" :key="name" class="field-row">
                <span class="field-label">{{ name }}</span>
                <div style="display: flex; align-items: center; gap: 12px">
                    <Toggle
                        :model-value="enabled"
                        :disabled="panel.pending[configKey] === true"
                        @update:model-value="(value: boolean) => setEnabled(name as string, value)"
                    />
                    <button
                        type="button"
                        class="removable-chip"
                        style="cursor: pointer"
                        @click="remove(name as string)"
                    >
                        &times;
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>
