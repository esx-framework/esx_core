export interface Theme {
  primaryColor: string
  secondaryColor: string
  backgroundColor: string
  accentColor: string
  logoUrl: string
}

export interface WhitelistState {
  enabled: boolean
  mode: "discord" | "identifier" | "both"
  combinationMode: "or" | "and"
  allowedIdentifiers: string[]
}

export interface DiscordState {
  enabled: boolean
  guildId: string
  allowedRoles: string[]
  timeout: number
  cacheDuration: number
  negativeCacheDuration: number
  maxRetries: number
}

export interface AdminState {
  groups: Record<string, boolean>
  cacheEnabled: boolean
  cacheExpiry: number
  cacheSaveDelay: number
}

export interface AdminOnlyState {
  enabled: boolean
  groups: Record<string, boolean>
  allowedIdentifiers: string[]
}

export interface BypassState {
  allowedIdentifiers: string[]
}

export interface LoggingState {
  enabled: boolean
  minInterval: number
  batchSize: number
}

export interface PerformanceState {
  discordConcurrency: number
  discordQueueLimit: number
  verificationTimeout: number
}

export interface MetaState {
  version: string
  botTokenConfigured: boolean
  discordReady: boolean
  webhookConfigured: boolean
  resourceName: string
}

export interface StatsState {
  service: {
    total: number
    allowed: number
    denied: number
    byMethod: Record<string, number>
  }
  discord: {
    requests: number
    cacheHits: number
    shared: number
    rateLimits: number
    errors: number
    allowed: number
    denied: number
    queueLength: number
    activeRequests: number
    cachedEntries: number
    rateLimited: boolean
  }
  logger: {
    queued: number
    sent: number
    failed: number
    dropped: number
    webhookConfigured: boolean
  }
  adminCacheEntries: number
  identifierCounts: {
    whitelist: number
    adminOnly: number
    bypass: number
  }
}

export interface PanelState {
  whitelist: WhitelistState
  discord: DiscordState
  admin: AdminState
  adminOnly: AdminOnlyState
  bypass: BypassState
  logging: LoggingState
  performance: PerformanceState
  meta?: MetaState
  stats?: StatsState
}

export type NuiInboundMessage =
  | { action: "open"; state: PanelState; theme: Theme }
  | { action: "close" }
  | { action: "state"; state: PanelState }
  | { action: "ack"; ack: ConfigAck }

export interface ConfigAck {
  ok: boolean
  key?: string
  error?: string
  state?: PanelState
}
