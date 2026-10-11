/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

import { StrictMode } from "react"
import { createRoot } from "react-dom/client"
import InventorySystem from "@/components/inventory-system"
import ErrorBoundary from "@/components/error-boundary"
import "./globals.css"

createRoot(document.getElementById("root") as HTMLElement).render(
  <StrictMode>
    <main className="min-h-screen flex items-center justify-center p-8">
      <ErrorBoundary>
        <InventorySystem />
      </ErrorBoundary>
    </main>
  </StrictMode>
)
