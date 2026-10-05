import { reactive } from "vue"
import { fetchNui } from "../services/nui"
import type { ConfigAck, PanelState } from "../types"

export interface Toast {
  id: number
  kind: "success" | "error" | "info"
  text: string
}

interface PanelStore {
  visible: boolean
  state: PanelState | null
  pending: Record<string, boolean>
  toasts: Toast[]
}

export const panel = reactive<PanelStore>({
  visible: false,
  state: null,
  pending: {},
  toasts: [],
})

let nextToastId = 1

export function pushToast(kind: Toast["kind"], text: string): void {
  const id = nextToastId++
  panel.toasts.push({ id, kind, text })
  window.setTimeout(() => {
    const index = panel.toasts.findIndex((toast) => toast.id === id)
    if (index !== -1) {
      panel.toasts.splice(index, 1)
    }
  }, 4000)
}

export async function updateConfig(key: string, value: unknown): Promise<void> {
  panel.pending[key] = true
  try {
    await fetchNui("updateConfig", { key, value })
  } finally {
    delete panel.pending[key]
  }
}

export function handleAck(ack: ConfigAck): void {
  if (ack.ok) {
    pushToast("success", "Setting saved")
  } else {
    pushToast("error", ack.error ? `Rejected: ${ack.error}` : "Change rejected by server")
  }
}

export function requestClose(): void {
  void fetchNui("close")
}
