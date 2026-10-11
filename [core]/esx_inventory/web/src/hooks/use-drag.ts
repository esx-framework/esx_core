/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

"use client"

import { useCallback, useEffect, useRef, useState } from "react"
import type { DragState, InventoryItem } from "@/lib/types"

const DRAG_THRESHOLD = 6

export interface DropHandlers {
  onMoveWithin: (item: InventoryItem, targetSlot: number) => void
  onPutToStorage: (item: InventoryItem) => void
  onTakeFromStorage: (item: InventoryItem) => void
  onUse: (item: InventoryItem) => void
  onGive: (item: InventoryItem) => void
}

interface PendingDrag {
  item: InventoryItem
  from: "left" | "right"
  startX: number
  startY: number
  active: boolean
}

export function useDrag(enabled: boolean, handlers: DropHandlers) {
  const [drag, setDrag] = useState<DragState | null>(null)
  const pendingDrag = useRef<PendingDrag | null>(null)
  const handlersRef = useRef(handlers)
  handlersRef.current = handlers

  const startDrag = useCallback((item: InventoryItem, from: "left" | "right", e: React.PointerEvent) => {
    if (e.button !== 0) return
    pendingDrag.current = { item, from, startX: e.clientX, startY: e.clientY, active: false }
  }, [])

  const clearDrag = useCallback(() => {
    pendingDrag.current = null
    setDrag(null)
  }, [])

  useEffect(() => {
    if (!enabled) return

    const resolveDrop = (pending: PendingDrag, x: number, y: number) => {
      const el = document.elementFromPoint(x, y)
      const zone = el?.closest?.("[data-drop]")?.getAttribute("data-drop")
      if (!zone) return

      const h = handlersRef.current

      if (zone === "use") {
        if (pending.from === "left") h.onUse(pending.item)
        return
      }

      if (zone === "give") {
        if (pending.from === "left") h.onGive(pending.item)
        return
      }

      const parts = zone.split(":")
      if (parts[0] !== "slot") return

      const panel = parts[1]
      const index = Number(parts[2])
      if (Number.isNaN(index)) return

      if (pending.from === "left" && panel === "left") {
        h.onMoveWithin(pending.item, index)
      } else if (pending.from === "left" && panel === "right") {
        h.onPutToStorage(pending.item)
      } else if (pending.from === "right" && panel === "left") {
        h.onTakeFromStorage(pending.item)
      }
    }

    const onPointerMove = (e: PointerEvent) => {
      const pending = pendingDrag.current
      if (!pending) return

      if (!pending.active) {
        if (Math.hypot(e.clientX - pending.startX, e.clientY - pending.startY) < DRAG_THRESHOLD) return
        pending.active = true
      }

      setDrag({ item: pending.item, from: pending.from, x: e.clientX, y: e.clientY })
    }

    const onPointerUp = (e: PointerEvent) => {
      const pending = pendingDrag.current
      pendingDrag.current = null
      setDrag(null)
      if (pending?.active) resolveDrop(pending, e.clientX, e.clientY)
    }

    window.addEventListener("pointermove", onPointerMove)
    window.addEventListener("pointerup", onPointerUp)
    return () => {
      window.removeEventListener("pointermove", onPointerMove)
      window.removeEventListener("pointerup", onPointerUp)
    }
  }, [enabled])

  return { drag, startDrag, clearDrag }
}
