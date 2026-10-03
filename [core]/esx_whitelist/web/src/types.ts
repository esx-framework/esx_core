export interface ThemeConvars {
  primaryColor?: string
  secondaryColor?: string
  backgroundColor?: string
  accentColor?: string
  logoUrl?: string
}

export interface WhitelistRule {
  id: string
  type: 'admin-presence' | 'player-count' | 'scheduled'
  enabled: boolean
  priority: number
  operator?: '<' | '>' | '<=' | '>=' | '=='
  value?: number
  action?: 'enable' | 'disable'
  startTime?: string
  endTime?: string
}

export interface WhitelistConfig {
  whitelistEnabled: boolean
  gracePeriod: number
  kickConnected: boolean
  discordWebhook: string
  discordEnabled: boolean
  discordGuildId: string
  discordRoleId: string
  authorizationMethod: 'identifier' | 'discord'
  rules: WhitelistRule[]
  locale?: string
  translations?: Record<string, string>
  hasBotToken?: boolean
  theme?: ThemeConvars
}

export interface WhitelistEntry {
  id: number
  playerName: string
  whitelisted: number
  identifiers: string[]
}

export interface ManagePlayerResponse {
  success: boolean
  message: string
}
