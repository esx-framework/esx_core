/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

"use client"

import type React from "react"

import InventorySlot from "./inventory-slot"
import { itemKey, type InventoryItem } from "@/lib/types"
import { Weight } from "lucide-react"

interface InventoryProps {
  title: string
  icon: React.ReactNode
  items: InventoryItem[]
  weightLabel: string
  maxWeight: number
  selectedItem: string | null
  setSelectedItem: (id: string | null) => void
  panel: "left" | "right"
  onSlotPointerDown: (item: InventoryItem, from: "left" | "right", e: React.PointerEvent) => void
  onUseItem?: (item: InventoryItem) => void
  onGiveItem?: (item: InventoryItem) => void
  onDropItem?: (item: InventoryItem) => void
  canDropItem?: (item: InventoryItem) => boolean
  dropLabel?: string
  useLabel?: string
  giveLabel?: string
  slotCount?: number
  maxVisibleRows?: number
  hotbarSlots?: number
}

export default function Inventory({
  title,
  icon,
  items,
  weightLabel,
  maxWeight,
  selectedItem,
  setSelectedItem,
  panel,
  onSlotPointerDown,
  onUseItem,
  onGiveItem,
  onDropItem,
  canDropItem,
  dropLabel = "Drop",
  useLabel = "Use",
  giveLabel = "Give",
  slotCount = 25,
  maxVisibleRows = 4,
  hotbarSlots = 0,
}: InventoryProps) {
  const totalWeight = items.reduce((sum, item) => sum + item.weight * item.count, 0)
  const weightPercentage = maxWeight > 0 ? Math.min((totalWeight / maxWeight) * 100, 100) : 0

  const totalSlots = items.reduce(
    (count, item) => (Number.isInteger(item.slot) && item.slot >= count ? item.slot + 1 : count),
    slotCount
  )

  const slots = Array.from({ length: totalSlots }, (_, i) => {
    return items.find((item) => item.slot === i) || null
  })

  const maxVisibleSlots = maxVisibleRows * 5
  const needsScrolling = totalSlots > maxVisibleSlots

  return (
    <div className="w-full">
      <div className="mb-4 p-4 rounded-2xl bg-dark/40 backdrop-blur-xl">
        <div className="flex justify-between items-center mb-2">
          <div className="flex items-center gap-2">
            <Weight className="w-4 h-4 text-brand" />
            <span className="text-sm font-medium text-light">{weightLabel}</span>
          </div>
          <span className="text-sm font-semibold text-lightest">
            {totalWeight.toFixed(1)} / {maxWeight}
          </span>
        </div>
        <div className="h-3 bg-darkest rounded-full overflow-hidden">
          <div
            className="h-full rounded-full bg-brand transition-all duration-300"
            style={{ width: `${weightPercentage}%` }}
          />
        </div>
      </div>

      <div className="p-6 rounded-2xl bg-dark/30 backdrop-blur-2xl shadow-2xl relative">
        <div className="flex items-center justify-center gap-2 mb-4">
          <div className="text-brand">{icon}</div>
          <h2 className="text-xl font-bold text-lightest">{title}</h2>
        </div>

        <div
          className={`grid grid-cols-5 gap-2 pt-2 pl-2 ${needsScrolling ? "max-h-80 overflow-y-auto pr-2 pb-2 inventory-scroll" : ""}`}
          style={needsScrolling ? {
            maxHeight: `${maxVisibleRows * 80 + (maxVisibleRows - 1) * 8 + 16}px`,
            scrollbarWidth: "none"
          } : {}}
        >
          {slots.map((item, index) => (
            <InventorySlot
              key={index}
              item={item}
              panel={panel}
              isSelected={item !== null && itemKey(item) === selectedItem}
              onSelect={() => item && setSelectedItem(itemKey(item) === selectedItem ? null : itemKey(item))}
              onPointerDown={(e) => item && onSlotPointerDown(item, panel, e)}
              onUse={
                item && onUseItem && item.usable
                  ? () => onUseItem(item)
                  : undefined
              }
              onGive={item && onGiveItem ? () => onGiveItem(item) : undefined}
              onDropItem={item && onDropItem && (!canDropItem || canDropItem(item)) ? () => onDropItem(item) : undefined}
              useLabel={useLabel}
              giveLabel={giveLabel}
              dropLabel={dropLabel}
              slotIndex={index}
              isHotbarSlot={panel === "left" && index < hotbarSlots}
            />
          ))}
        </div>
      </div>
    </div>
  )
}
