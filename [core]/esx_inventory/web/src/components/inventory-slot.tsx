/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

"use client"

import type React from "react"
import { useState, useRef } from "react"
import { createPortal } from "react-dom"
import { Package, Gift, Trash2, ArrowDownToLine } from "lucide-react"

import type { InventoryItem } from "@/lib/types"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem } from "./ui/dropdown-menu"

interface InventorySlotProps {
  item: InventoryItem | null
  panel: "left" | "right"
  isSelected: boolean
  onSelect: () => void
  onPointerDown: (e: React.PointerEvent) => void
  onUse?: () => void
  onGive?: () => void
  onDropItem?: () => void
  useLabel?: string
  giveLabel?: string
  dropLabel?: string
  slotIndex?: number
  isHotbarSlot?: boolean
}

export default function InventorySlot({
  item,
  panel,
  isSelected,
  onSelect,
  onPointerDown,
  onUse,
  onGive,
  onDropItem,
  useLabel = "Use",
  giveLabel = "Give",
  dropLabel = "Drop",
  slotIndex,
  isHotbarSlot = false,
}: InventorySlotProps) {
  const slotRef = useRef<HTMLDivElement>(null)

  const [isHovered, setIsHovered] = useState(false)
  const [imageBroken, setImageBroken] = useState(false)
  const [contextMenuOpen, setContextMenuOpen] = useState(false)
  const [contextMenuPosition, setContextMenuPosition] = useState({ x: 0, y: 0 })

  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button === 2) e.preventDefault()
  }

  const handleContextMenu = (e: React.MouseEvent) => {
    if (!item) return
    e.preventDefault()
    setContextMenuPosition({ x: e.clientX, y: e.clientY })
    setContextMenuOpen(true)
  }

  const getSlotClassName = () => {
    const baseClasses = "aspect-square rounded-xl cursor-pointer transition-all duration-200 bg-mid/40 backdrop-blur-xl border-2 relative"

    let borderClasses = "border-light/20 hover:border-light/40"
    if (isSelected) {
      borderClasses = "border-brand/80 scale-105"
    } else if (isHotbarSlot) {
      borderClasses = "border-brand/45"
    }

    const hoverClasses = item ? "hover:scale-105" : ""

    return `${baseClasses} ${borderClasses} ${hoverClasses}`
  }

  const renderItemContent = () => {
    if (!item) return null

    return (
      <>
        <div className="absolute inset-0 p-2 flex items-center justify-center">
          {!imageBroken ? (
            <img
              src={item.image}
              alt={item.label}
              draggable={false}
              onError={() => setImageBroken(true)}
              className="w-full h-full object-contain drop-shadow-lg"
            />
          ) : (
            <Package className="w-8 h-8 text-light/60" />
          )}
        </div>

        <div className="absolute top-1 left-1 right-1">
          <div className="bg-darkest/90 backdrop-blur-sm px-1.5 py-0.5 rounded">
            <span className="text-[10px] font-semibold text-lightest truncate block">
              {item.label}
            </span>
          </div>
        </div>

        {item.count > 1 && (
          <div className="absolute bottom-1 right-1 bg-darkest/90 backdrop-blur-sm px-2 py-0.5 rounded-md border border-brand/30">
            <span className="text-xs font-bold text-brand">{item.count}</span>
          </div>
        )}

        <div className="absolute inset-0 bg-gradient-to-t from-brand/10 to-transparent opacity-0 hover:opacity-100 transition-opacity rounded-xl" />
      </>
    )
  }

  const renderHotbarNumber = () => {
    if (!isHotbarSlot || typeof slotIndex !== "number") return null

    return (
      <div className="absolute top-1 right-1 bg-brand/80 backdrop-blur-sm w-5 h-5 rounded-full flex items-center justify-center border border-brand">
        <span className="text-[10px] font-bold text-darkest">{slotIndex + 1}</span>
      </div>
    )
  }

  const renderTooltip = () => {
    if (!isHovered || !item || typeof document === "undefined") return null

    return createPortal(
      <div
        className="fixed w-48 p-3 bg-darkest/95 backdrop-blur-xl border border-brand/30 rounded-lg shadow-2xl pointer-events-none z-[10000]"
        style={{
          left: slotRef.current ? `${slotRef.current.getBoundingClientRect().left}px` : "0px",
          top: slotRef.current ? `${slotRef.current.getBoundingClientRect().bottom + 4}px` : "0px"
        }}
      >
        <p className="text-xs text-lightest leading-relaxed">{item.description ?? item.label}</p>
        <div className="mt-2 pt-2 border-t border-light/10">
          <p className="text-[11px] text-light">{item.weight} kg</p>
        </div>
      </div>,
      document.body
    )
  }

  const renderContextMenu = () => {
    if (!item || !contextMenuOpen) return null

    return (
      <DropdownMenu open={contextMenuOpen} onOpenChange={setContextMenuOpen}>
        <DropdownMenuContent
          className="bg-dark/95 backdrop-blur-xl border-light/20 rounded-xl z-[9999]"
          style={{
            position: "fixed",
            left: `${contextMenuPosition.x}px`,
            top: `${contextMenuPosition.y}px`,
          }}
        >
          {onUse && (
            <DropdownMenuItem
              onClick={() => {
                onUse()
                setContextMenuOpen(false)
              }}
              className="text-lightest hover:bg-brand/20 focus:bg-brand/20 cursor-pointer"
            >
              <Package className="w-4 h-4 mr-2" />
              {useLabel}
            </DropdownMenuItem>
          )}
          {onGive && (
            <DropdownMenuItem
              onClick={() => {
                onGive()
                setContextMenuOpen(false)
              }}
              className="text-lightest hover:bg-brand/20 focus:bg-brand/20 cursor-pointer"
            >
              <Gift className="w-4 h-4 mr-2" />
              {giveLabel}
            </DropdownMenuItem>
          )}
          {onDropItem && (
            <DropdownMenuItem
              onClick={() => {
                onDropItem()
                setContextMenuOpen(false)
              }}
              className="text-lightest hover:bg-brand/20 focus:bg-brand/20 cursor-pointer"
            >
              {dropLabel === "Take" ? (
                <ArrowDownToLine className="w-4 h-4 mr-2" />
              ) : (
                <Trash2 className="w-4 h-4 mr-2" />
              )}
              {dropLabel}
            </DropdownMenuItem>
          )}
        </DropdownMenuContent>
      </DropdownMenu>
    )
  }

  return (
    <>
      <div
        ref={slotRef}
        data-drop={`slot:${panel}:${slotIndex}`}
        onClick={() => item && onSelect()}
        onMouseDown={handleMouseDown}
        onPointerDown={onPointerDown}
        onContextMenu={handleContextMenu}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
        className={getSlotClassName()}
      >
        {renderItemContent()}
        {renderHotbarNumber()}
      </div>

      {renderTooltip()}
      {renderContextMenu()}
    </>
  )
}
