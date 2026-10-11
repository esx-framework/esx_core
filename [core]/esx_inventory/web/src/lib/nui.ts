/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

export function getResourceName(): string {
  const win = window as unknown as { GetParentResourceName?: () => string }
  return win.GetParentResourceName ? win.GetParentResourceName() : "esx_inventory"
}

export async function fetchNui<T = unknown>(event: string, data?: unknown): Promise<T | null> {
  try {
    const response = await fetch(`https://${getResourceName()}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data ?? {}),
    })
    return (await response.json()) as T
  } catch {
    return null
  }
}
