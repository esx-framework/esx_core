/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

"use client"

import type { DragState } from "@/lib/types"

export default function DragGhost({ drag }: { drag: DragState }) {
  return (
    <div
      className="fixed z-[10001] pointer-events-none -translate-x-1/2 -translate-y-1/2"
      style={{ left: drag.x, top: drag.y }}
    >
      <div className="w-16 h-16 rounded-xl bg-mid/80 border-2 border-brand shadow-2xl shadow-brand/40 p-2 flex items-center justify-center backdrop-blur-xl">
        <img
          src={drag.item.image}
          alt=""
          className="w-full h-full object-contain"
          onError={(e) => { (e.currentTarget as HTMLImageElement).style.display = "none" }}
        />
      </div>
    </div>
  )
}
