import type { Theme } from "../types"
import defaultLogo from "../assets/esx-logo.png"

export function applyTheme(theme: Theme): void {
  const root = document.documentElement

  root.style.setProperty("--brand-color", theme.primaryColor)
  root.style.setProperty("--brand-color-rgb", hexToRgb(theme.primaryColor))
  root.style.setProperty("--dark-color", theme.secondaryColor)
  root.style.setProperty("--darkest-color", theme.backgroundColor)
  root.style.setProperty("--mid-color", theme.accentColor)

  root.style.setProperty("--esx-primary", theme.primaryColor)
  root.style.setProperty("--esx-secondary", theme.secondaryColor)
  root.style.setProperty("--esx-background", theme.backgroundColor)
  root.style.setProperty("--esx-accent", theme.accentColor)
  const logoUrl = theme.logoUrl ? `url("${theme.logoUrl}")` : `url("${defaultLogo}")`
  root.style.setProperty("--esx-logo-url", logoUrl)
}

function hexToRgb(hex: string): string {
  const match = /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i.exec(hex)
  if (!match) {
    return "251, 155, 4"
  }
  return `${parseInt(match[1], 16)}, ${parseInt(match[2], 16)}, ${parseInt(match[3], 16)}`
}

export const FALLBACK_THEME: Theme = {
  primaryColor: "#FB9B04",
  secondaryColor: "#252525",
  backgroundColor: "#161616",
  accentColor: "#383838",
  logoUrl: "",
}
