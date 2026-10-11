/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

"use client"

import { useEffect, useState } from "react"
import { Plus, Minus, Package } from "lucide-react"

interface ItemNotificationProps {
  item: { name: string; label: string; image: string }
  amount: number
  added: boolean
  label: string
  onComplete: () => void
}

export default function ItemNotification({ item, amount, added, label, onComplete }: ItemNotificationProps) {
  const [isVisible, setIsVisible] = useState(false)
  const [imageBroken, setImageBroken] = useState(false)

  useEffect(() => {
    const showTimer = setTimeout(() => setIsVisible(true), 50)

    const hideTimer = setTimeout(() => {
      setIsVisible(false)
      setTimeout(onComplete, 300)
    }, 3000)

    return () => {
      clearTimeout(showTimer)
      clearTimeout(hideTimer)
    }
  }, [onComplete])

  return (
    <div
      className={`
        fixed bottom-8 left-1/2 -translate-x-1/2 z-50
        transition-all duration-300 ease-out
        ${isVisible ? "translate-y-0 opacity-100 scale-100" : "translate-y-4 opacity-0 scale-95"}
      `}
    >
      <div className="flex items-center gap-3 px-6 py-4 bg-dark/95 backdrop-blur-xl border-2 border-brand/40 rounded-2xl shadow-2xl shadow-brand/20">
        <div className="relative w-12 h-12 rounded-lg bg-mid/50 border border-light/20 p-1.5 flex items-center justify-center">
          {!imageBroken ? (
            <img
              src={item.image}
              alt={item.label}
              onError={() => setImageBroken(true)}
              className="w-full h-full object-contain"
            />
          ) : (
            <Package className="w-6 h-6 text-light/60" />
          )}
          <div className="absolute -top-1 -right-1 bg-brand rounded-full p-0.5">
            {added ? <Plus className="w-3 h-3 text-darkest" /> : <Minus className="w-3 h-3 text-darkest" />}
          </div>
        </div>

        <div className="flex flex-col">
          <div className="flex items-center gap-2">
            <span className="text-sm font-bold text-lightest">{item.label}</span>
            <span className="text-xs font-semibold text-brand">{added ? "+" : "-"}{amount}</span>
          </div>
          <span className="text-xs text-light">{label}</span>
        </div>
      </div>
    </div>
  )
}
