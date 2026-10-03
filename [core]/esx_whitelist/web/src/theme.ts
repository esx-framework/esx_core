import type { ThemeConvars } from './types'

function sanitizeCssUrl(url: string): string {
  return url.replace(/["'\\\n\r]/g, '')
}

export function applyThemeConvars(theme?: ThemeConvars): void {
  const root = document.documentElement

  if (!theme) return

  if (theme.primaryColor) {
    root.style.setProperty('--color-brand', theme.primaryColor)
    root.style.setProperty('--color-primary', theme.primaryColor)
  }

  if (theme.secondaryColor) {
    root.style.setProperty('--color-dark', theme.secondaryColor)
    root.style.setProperty('--color-secondary', theme.secondaryColor)
  }

  if (theme.backgroundColor) {
    root.style.setProperty('--color-darkest', theme.backgroundColor)
    root.style.setProperty('--color-bg', theme.backgroundColor)
  }

  if (theme.accentColor) {
    root.style.setProperty('--color-accent', theme.accentColor)
  }

  if (theme.logoUrl) {
    root.style.setProperty('--logo-url', `url("${sanitizeCssUrl(theme.logoUrl)}")`)
  }
}