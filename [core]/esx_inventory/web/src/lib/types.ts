/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

export interface InventoryItem {
  type: "item_standard" | "item_account" | "item_weapon"
  name: string
  label: string
  description?: string
  image: string
  weight: number
  count: number
  slot: number
  usable: boolean
  canRemove: boolean
  ammo?: number
}

export interface StorageData {
  id: string
  label: string
  slots: number
  maxWeight: number
  items: InventoryItem[]
}

export interface NearbyPlayer {
  id: number
  name: string
  distance: number
}

export interface DragState {
  item: InventoryItem
  from: "left" | "right"
  x: number
  y: number
}

export type LocaleMap = Record<string, string>

export const DEFAULT_LOCALE: LocaleMap = {
  inventory: "Inventory",
  storage: "Storage",
  weight: "Weight",
  use: "Use",
  give: "Give",
  giveAmmo: "Give ammo",
  remove: "Throw",
  take: "Take",
  amount: "Amount",
  nearbyPlayers: "Nearby Players",
  noNearbyPlayers: "No nearby Players",
  addedToInventory: "Added to inventory",
  removedFromInventory: "Removed from inventory",
}

export const THEME_VARIABLES: Record<string, string> = {
  primaryColor: "--brand-color",
  secondaryColor: "--dark-color",
  backgroundColor: "--darkest-color",
  accentColor: "--mid-color",
}

export interface NotificationData {
  item: { name: string; label: string; image: string }
  amount: number
  added: boolean
  key: number
}

export const itemKey = (item: InventoryItem) => `${item.type}:${item.name}`

export const hasGivableAmmo = (item: InventoryItem | null): boolean =>
  item !== null && item.type === "item_weapon" && (item.ammo ?? 0) > 0
