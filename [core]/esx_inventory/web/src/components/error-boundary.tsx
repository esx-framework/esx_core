/*
 * SPDX-License-Identifier: GPL-3.0-only
 * Copyright (C) 2022-2026 ESX Framework
 */

import { Component, type ErrorInfo, type ReactNode } from "react"
import { fetchNui } from "@/lib/nui"

interface ErrorBoundaryProps {
  children: ReactNode
}

interface ErrorBoundaryState {
  failed: boolean
}

export default class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { failed: false }

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { failed: true }
  }

  componentDidMount() {
    window.addEventListener("message", this.handleMessage)
  }

  componentWillUnmount() {
    window.removeEventListener("message", this.handleMessage)
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    fetchNui("uiError", { message: error.message, stack: info.componentStack ?? "" })
    fetchNui("close")
  }

  handleMessage = (event: MessageEvent) => {
    if (!this.state.failed || event.data?.action !== "open") return

    fetchNui("close")
    this.setState({ failed: false })
  }

  render() {
    return this.state.failed ? null : this.props.children
  }
}
