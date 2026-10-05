<script setup lang="ts">
import { ref } from "vue"
import { Button, Input } from "esx-ui-kit-vue"
import { panel, updateConfig } from "../composables/usePanel"

const props = defineProps<{
  configKey: string
  items: string[]
  label: string
  placeholder: string
  hint?: string
  /** Client-side hint validation only; the server re-validates anyway. */
  validate?: (value: string) => string | null
}>()

const draft = ref("")
const error = ref("")

function commit(nextItems: string[]): void {
  void updateConfig(props.configKey, nextItems)
}

function add(): void {
  const value = draft.value.trim()
  if (!value) {
    return
  }
  if (props.validate) {
    const problem = props.validate(value)
    if (problem) {
      error.value = problem
      return
    }
  }
  if (props.items.includes(value.toLowerCase()) || props.items.includes(value)) {
    error.value = "Entry already exists"
    return
  }
  error.value = ""
  commit([...props.items, value])
  draft.value = ""
}

function remove(item: string): void {
  commit(props.items.filter((entry) => entry !== item))
}
</script>

<template>
  <div>
    <div class="list-editor-form">
      <Input
        v-model="draft"
        :label="label"
        :placeholder="placeholder"
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
    <div class="list-editor-items">
      <span v-if="items.length === 0" class="empty-note">No entries configured.</span>
      <span v-for="item in items" :key="item" class="removable-chip">
        {{ item }}
        <button type="button" title="Remove" @click="remove(item)">&times;</button>
      </span>
    </div>
  </div>
</template>
