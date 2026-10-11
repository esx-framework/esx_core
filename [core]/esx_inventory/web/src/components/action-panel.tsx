/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

"use client"

import { Button } from "./ui/button"
import { Input } from "./ui/input"
import { ArrowRightLeft, Crosshair, Gift, Hand } from "lucide-react"
import type { InventoryItem, NearbyPlayer } from "@/lib/types"

interface ActionPanelProps {
  t: (key: string) => string
  selectedItem: InventoryItem | null
  dragFromLeft: boolean
  amount: number
  setAmount: (value: number) => void
  onUse: () => void
  showPlayerList: boolean
  setShowPlayerList: (value: boolean) => void
  giveMode: "item" | "ammo"
  canGiveAmmo: boolean
  nearbyPlayers: NearbyPlayer[]
  onOpenPlayerList: () => void
  onOpenAmmoList: () => void
  onGiveToPlayer: (playerId: number) => void
}

export default function ActionPanel({
  t,
  selectedItem,
  dragFromLeft,
  amount,
  setAmount,
  onUse,
  showPlayerList,
  setShowPlayerList,
  giveMode,
  canGiveAmmo,
  nearbyPlayers,
  onOpenPlayerList,
  onOpenAmmoList,
  onGiveToPlayer,
}: ActionPanelProps) {
  return (
    <div className="flex flex-col gap-4 justify-center min-h-[500px]">
      <Button
        data-drop="use"
        onClick={onUse}
        disabled={(!selectedItem || selectedItem.type !== "item_standard") && !dragFromLeft}
        className={`${dragFromLeft ? "bg-brand/80 ring-2 ring-brand/50 shadow-xl shadow-brand/50" : "bg-brand hover:bg-brand/90"} text-darkest font-semibold px-8 py-6 rounded-xl disabled:opacity-50 disabled:cursor-not-allowed transition-all shadow-lg shadow-brand/20 w-full flex items-center justify-center gap-2`}
      >
        <Hand className="w-5 h-5 pointer-events-none" />
        <span className="pointer-events-none">{t("use")}</span>
      </Button>

      <div className="relative">
        <ArrowRightLeft className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-light" />
        <Input
          type="number"
          min="1"
          value={amount}
          onChange={(e) => setAmount(Math.max(1, Number.parseInt(e.target.value) || 1))}
          className="bg-mid/50 backdrop-blur-xl border-light/20 text-lightest text-center rounded-xl pl-10 py-6"
          placeholder={t("amount")}
        />
      </div>

      <div className="relative">
        <Button
          data-drop="give"
          onClick={() => (showPlayerList && giveMode === "item" ? setShowPlayerList(false) : onOpenPlayerList())}
          disabled={!selectedItem && !dragFromLeft}
          className={`${dragFromLeft ? "bg-mid/60 ring-2 ring-brand/30 border-brand/40 shadow-xl shadow-brand/30" : "bg-mid hover:bg-mid/80 border-light/20"} text-lightest font-semibold px-8 py-6 rounded-xl disabled:opacity-50 disabled:cursor-not-allowed transition-all border w-full flex items-center justify-center gap-2`}
        >
          <Gift className="w-5 h-5 pointer-events-none" />
          <span className="pointer-events-none">{t("give")}</span>
        </Button>

        {canGiveAmmo && (
          <Button
            onClick={() => (showPlayerList && giveMode === "ammo" ? setShowPlayerList(false) : onOpenAmmoList())}
            className="bg-mid hover:bg-mid/80 border-light/20 text-lightest font-semibold px-8 py-6 rounded-xl transition-all border w-full flex items-center justify-center gap-2 mt-4"
          >
            <Crosshair className="w-5 h-5 pointer-events-none" />
            <span className="pointer-events-none">{t("giveAmmo")}</span>
          </Button>
        )}

        {showPlayerList && selectedItem && (
          <div className="absolute top-full mt-2 w-full bg-dark/95 backdrop-blur-xl border border-light/20 rounded-xl overflow-hidden shadow-2xl z-50">
            <div className="p-2 border-b border-light/10">
              <p className="text-xs text-light text-center">{t("nearbyPlayers")}</p>
            </div>
            {nearbyPlayers.length === 0 && (
              <div className="px-4 py-3 text-center text-xs text-light">{t("noNearbyPlayers")}</div>
            )}
            {nearbyPlayers.map((player) => (
              <button
                key={player.id}
                onClick={() => onGiveToPlayer(player.id)}
                className="w-full px-4 py-3 text-left hover:bg-brand/20 transition-colors border-b border-light/5 last:border-b-0"
              >
                <div className="flex justify-between items-center">
                  <span className="text-lightest font-medium">{player.name}</span>
                  <span className="text-xs text-light">{player.distance.toFixed(1)}m</span>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
