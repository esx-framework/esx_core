"use client"

import { useState, useEffect, useRef } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Clock, Users, Bell, Settings, AlertTriangle, UserCheck, Hash, List, X, User, UserPlus, UserMinus, Search, CheckCircle2, Copy, Check, Eye, EyeOff } from "lucide-react"

type RuleType = "admin-presence" | "player-count" | "scheduled"
type Operator = "<" | ">" | ">=" | "=="
type Action = "enable" | "disable"
type IdentifierType = "license" | "license2" | "steam" | "discord" | "xbl" | "fivem"
type WhitelistAction = "add" | "remove"

interface Rule {
  id: string
  type: RuleType
  enabled: boolean
  priority: number
  operator?: Operator
  value?: number
  action?: Action
  startTime?: string
  endTime?: string
}

interface WhitelistEntry {
  id: number
  identifiers: string[]
  playerName: string
  whitelisted: number
}

interface WhitelistConfig {
  whitelistEnabled: boolean
  gracePeriod: number
  kickConnected: boolean
  discordWebhook: string
  discordEnabled: boolean
  discordGuildId: string
  discordRoleId: string
  rules: Rule[]
  locale: string
  translations: Record<string, string>
  hasBotToken: boolean
}

interface CustomSwitchProps {
  checked: boolean
  onCheckedChange: (checked: boolean) => void
  disabled?: boolean
  id?: string
}

const CustomSwitch = ({ checked, onCheckedChange, disabled = false, id }: CustomSwitchProps) => {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      disabled={disabled}
      id={id}
      onClick={() => !disabled && onCheckedChange(!checked)}
      className="relative inline-flex h-6 w-11 items-center rounded-full transition-all duration-300 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
      style={{
        background: checked 
          ? "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)"
          : "rgba(60, 60, 60, 0.8)",
        boxShadow: checked 
          ? "0 0 12px rgba(251, 155, 4, 0.4), inset 0 1px 2px rgba(0, 0, 0, 0.2)"
          : "inset 0 2px 4px rgba(0, 0, 0, 0.3)",
      }}
    >
      <span
        className="inline-block h-4 w-4 transform rounded-full transition-all duration-300"
        style={{
          background: checked ? "#ffffff" : "rgba(150, 150, 150, 0.9)",
          transform: checked ? "translateX(24px)" : "translateX(4px)",
          boxShadow: checked 
            ? "0 2px 8px rgba(0, 0, 0, 0.3)"
            : "0 1px 4px rgba(0, 0, 0, 0.2)",
        }}
      />
    </button>
  )
}

const useAudioSystem = () => {
  const audioRefs = useRef<{ [key: string]: HTMLAudioElement }>({})

  useEffect(() => {
    audioRefs.current = {
      click: new Audio("https://hebbkx1anhila5yf.public.blob.vercel-storage.com/buttonpress-ZhD2rrsS446feqLbA4Gk4ypddIry6X.wav"),
      toggleOn: new Audio("https://hebbkx1anhila5yf.public.blob.vercel-storage.com/turnon-fSgd3bC1WSTe73HcQxjrKTc9muEW19.wav"),
      toggleOff: new Audio("https://hebbkx1anhila5yf.public.blob.vercel-storage.com/turnoff-iDZ9CFS8GzYfuOVWECqbJbwoAQYNfD.wav"),
      close: new Audio("https://r2.fivemanage.com/ezG2KbZP8dV8OUQgkQ0i6/close.mp3"),
    }

    Object.values(audioRefs.current).forEach((audio) => {
      audio.load()
    })
  }, [])

  const playSound = (type: "click" | "toggleOn" | "toggleOff" | "close") => {
    const audio = audioRefs.current[type]
    if (audio) {
      audio.currentTime = 0
      audio.play().catch(() => {})
    }
  }

  return { playSound }
}

const rateLimitMap = new Map<string, number>()

async function fetchNui(eventName: string, data?: any) {
  const now = Date.now()
  const lastCall = rateLimitMap.get(eventName) || 0
  
  if (now - lastCall < 1000) {
    return {}
  }
  
  rateLimitMap.set(eventName, now)

  const options = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  }

  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'esx_whitelist'

  try {
    const resp = await fetch(`https://${resourceName}/${eventName}`, options)
    const text = await resp.text()
    return text ? JSON.parse(text) : {}
  } catch (error) {
    return {}
  }
}

export default function WhitelistControlPanel() {
  const [visible, setVisible] = useState(false)
  const [whitelistEnabled, setWhitelistEnabled] = useState(false)
  const [gracePeriod, setGracePeriod] = useState(60)
  const [kickConnected, setKickConnected] = useState(false)
  const [discordWebhook, setDiscordWebhook] = useState("")
  const [discordEnabled, setDiscordEnabled] = useState(false)
  const [discordGuildId, setDiscordGuildId] = useState("")
  const [discordRoleId, setDiscordRoleId] = useState("")
  const [hasBotToken, setHasBotToken] = useState(false)
  const [translations, setTranslations] = useState<Record<string, string>>({})
  const [playerIdentifier, setPlayerIdentifier] = useState("")
  const [detectedType, setDetectedType] = useState<IdentifierType | null>(null)
  const [identifierType, setIdentifierType] = useState<IdentifierType>("license")
  const [whitelistAction, setWhitelistAction] = useState<WhitelistAction>("add")
  const [showWhitelistView, setShowWhitelistView] = useState(false)
  const [whitelistEntries, setWhitelistEntries] = useState<WhitelistEntry[]>([])
  const [filteredEntries, setFilteredEntries] = useState<WhitelistEntry[]>([])
  const [searchQuery, setSearchQuery] = useState("")
  const [rules, setRules] = useState<Rule[]>([])
  const [expandedEntries, setExpandedEntries] = useState<Set<number>>(new Set())
  const [isSaving, setIsSaving] = useState(false)
  const [copiedId, setCopiedId] = useState<string | null>(null)
  const [validationError, setValidationError] = useState<string>("")

  const { playSound } = useAudioSystem()

  const t = (key: string): string => {
    return translations[key] || key
  }

  const detectIdentifierType = (value: string): IdentifierType | null => {
    const cleanValue = value.trim().replace(/\s+/g, '').replace(/^\w+:/, '')
    const len = cleanValue.length
    
    if (/^[0-9a-fA-F]+-[0-9a-fA-F]+-[0-9a-fA-F]+-[0-9a-fA-F]+-[0-9a-fA-F]+$/.test(cleanValue) && len === 36) {
      return "license2"
    }
    
    if (/^[0-9a-fA-F]+$/.test(cleanValue) && len === 40) {
      return "license"
    }
    
    if (/^\d+$/.test(cleanValue)) {
      if (len >= 17 && len <= 19) return "discord"
      if (len === 16) return "xbl"
      if (len >= 6 && len <= 8) return "fivem"
    }
    
    if (/^[0-9a-fA-F]+$/.test(cleanValue) && len >= 15 && len <= 17) {
      return "steam"
    }
    
    return null
  }

  const copyToClipboard = (text: string, id: string) => {
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'fixed'
    textArea.style.left = '-999999px'
    textArea.style.top = '-999999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()
    
    try {
      document.execCommand('copy')
      setCopiedId(id)
      setTimeout(() => setCopiedId(null), 2000)
    } catch (err) {
      console.error('Failed to copy:', err)
    } finally {
      textArea.remove()
    }
  }

  const getIdentifierColor = (type: string) => {
    const colorMap: Record<string, string> = {
      steam: "#66c0f4",
      license: "#3b82f6",
      license2: "#8b5cf6",
      discord: "#5865f2",
      xbl: "#107c10",
      fivem: "#f97316"
    }
    return colorMap[type] || "#6b7280"
  }

  const validateIdentifier = (value: string): boolean => {
    const cleaned = value.trim()
    
    if (cleaned.length < 6 || cleaned.length > 50) {
      setValidationError(t("identifier_length_error") || "Identifier must be between 6-50 characters")
      return false
    }
    
    if (!/^[a-zA-Z0-9:-]+$/.test(cleaned)) {
      setValidationError(t("identifier_chars_error") || "Invalid characters in identifier")
      return false
    }
    
    setValidationError("")
    return true
  }

  const validateWebhook = (webhook: string): boolean => {
    if (!webhook || webhook === '***CONFIGURED***') return true
    
    if (!webhook.startsWith('https://discord.com/api/webhooks/') && 
        !webhook.startsWith('https://discordapp.com/api/webhooks/')) {
      setValidationError(t("webhook_invalid") || "Invalid Discord webhook URL")
      return false
    }
    
    setValidationError("")
    return true
  }

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const { action, data } = event.data
      
      if (action === 'openUI') {
        setVisible(true)
        setWhitelistEnabled(data.whitelistEnabled)
        setGracePeriod(data.gracePeriod)
        setKickConnected(data.kickConnected)
        setDiscordWebhook(data.discordWebhook)
        setDiscordEnabled(data.discordEnabled)
        setDiscordGuildId(data.discordGuildId)
        setDiscordRoleId(data.discordRoleId)
        setHasBotToken(data.hasBotToken)
        setRules(data.rules)
        setTranslations(data.translations || {})
      } else if (action === 'closeUI') {
        setVisible(false)
      }
    }

    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [])

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && visible) {
        e.preventDefault()
        playSound("close")
        if (showWhitelistView) {
          setShowWhitelistView(false)
          setSearchQuery("")
          setExpandedEntries(new Set())
        } else {
          handleClose()
        }
      }
    }

    window.addEventListener('keydown', handleEscape)
    return () => window.removeEventListener('keydown', handleEscape)
  }, [visible, showWhitelistView])

  useEffect(() => {
    if (searchQuery.trim() === "") {
      setFilteredEntries(whitelistEntries)
    } else {
      const query = searchQuery.toLowerCase()
      setFilteredEntries(
        whitelistEntries.filter(entry => 
          entry.playerName?.toLowerCase().includes(query) ||
          entry.identifiers?.some(id => id.toLowerCase().includes(query))
        )
      )
    }
  }, [searchQuery, whitelistEntries])

  useEffect(() => {
    if (playerIdentifier.trim()) {
      const detected = detectIdentifierType(playerIdentifier)
      setDetectedType(detected)
      if (detected && detected !== identifierType) {
        setIdentifierType(detected)
      }
    } else {
      setDetectedType(null)
    }
  }, [playerIdentifier])

  const toggleExpanded = (id: number) => {
    playSound("click")
    const newExpanded = new Set(expandedEntries)
    if (newExpanded.has(id)) {
      newExpanded.delete(id)
    } else {
      newExpanded.add(id)
    }
    setExpandedEntries(newExpanded)
  }

  const handleClose = () => {
    playSound("close")
    setVisible(false)
    setValidationError("")
    fetchNui('closeUI')
  }

  const handleWhitelistToggle = (checked: boolean) => {
    playSound(checked ? "toggleOn" : "toggleOff")
    setWhitelistEnabled(checked)
  }

  const handleKickConnectedToggle = (checked: boolean) => {
    playSound(checked ? "toggleOn" : "toggleOff")
    setKickConnected(checked)
  }

  const handleDiscordToggle = (checked: boolean) => {
    playSound(checked ? "toggleOn" : "toggleOff")
    setDiscordEnabled(checked)
  }

  const handleAddRule = (type: RuleType) => {
    playSound("click")
    const newRule: Rule = {
      id: Date.now().toString(),
      type,
      enabled: true,
      priority: rules.length + 1,
      ...(type === "admin-presence" && { operator: "<" as Operator, value: 1, action: "enable" as Action }),
      ...(type === "player-count" && { operator: ">" as Operator, value: 50, action: "enable" as Action }),
      ...(type === "scheduled" && { startTime: "00:00", endTime: "00:00" }),
    }
    setRules([...rules, newRule])
  }

  const handleRemoveRule = (id: string) => {
    playSound("click")
    setRules(rules.filter((rule) => rule.id !== id))
  }

  const handleRuleToggle = (id: string, checked: boolean) => {
    playSound(checked ? "toggleOn" : "toggleOff")
    setRules(rules.map((rule) => (rule.id === id ? { ...rule, enabled: checked } : rule)))
  }

  const updateRule = (id: string, updates: Partial<Rule>) => {
    setRules(rules.map((rule) => (rule.id === id ? { ...rule, ...updates } : rule)))
  }

  const handleTestWebhook = () => {
    playSound("click")
    
    if (!validateWebhook(discordWebhook)) {
      return
    }
    
    fetchNui("testWebhook")
  }

  const handleManagePlayer = () => {
    playSound("click")
    
    if (!playerIdentifier.trim()) {
      setValidationError(t("identifier_required") || "Identifier is required")
      return
    }
    
    if (!validateIdentifier(playerIdentifier)) {
      return
    }
    
    fetchNui("managePlayer", {
      identifier: playerIdentifier.trim(),
      type: identifierType,
      action: whitelistAction
    })
    
    setPlayerIdentifier("")
    setDetectedType(null)
    setValidationError("")
  }

  const handleViewWhitelist = () => {
    playSound("click")
    fetchNui("getWhitelistEntries").then((entries: WhitelistEntry[]) => {
      setWhitelistEntries(entries || [])
      setFilteredEntries(entries || [])
      setShowWhitelistView(true)
      setExpandedEntries(new Set())
    })
  }

  const handleToggleWhitelistStatus = (entry: WhitelistEntry) => {
    playSound("click")
    const newStatus = entry.whitelisted === 1 ? 0 : 1
    
    fetchNui("toggleWhitelistStatus", { 
      id: entry.id,
      status: newStatus
    }).then(() => {
      setWhitelistEntries(whitelistEntries.map(e => 
        e.id === entry.id ? { ...e, whitelisted: newStatus } : e
      ))
    })
  }

  const handleSave = async () => {
    if (isSaving) return
    
    if (!validateWebhook(discordWebhook)) {
      return
    }
    
    playSound("click")
    setIsSaving(true)
    
    try {
      const configData = {
        whitelistEnabled,
        gracePeriod,
        kickConnected,
        discordWebhook: discordWebhook !== '***CONFIGURED***' ? discordWebhook : '',
        discordEnabled,
        discordGuildId,
        discordRoleId,
        rules,
      }
      
      await fetchNui("updateConfig", configData)
      setValidationError("")
    } finally {
      setTimeout(() => setIsSaving(false), 1000)
    }
  }

  const handleReset = () => {
    playSound("click")
    setValidationError("")
    fetchNui("getConfig").then((config: WhitelistConfig) => {
      setWhitelistEnabled(config.whitelistEnabled)
      setGracePeriod(config.gracePeriod)
      setKickConnected(config.kickConnected)
      setDiscordWebhook(config.discordWebhook)
      setDiscordEnabled(config.discordEnabled)
      setDiscordGuildId(config.discordGuildId)
      setDiscordRoleId(config.discordRoleId)
      setHasBotToken(config.hasBotToken)
      setRules(config.rules)
    })
  }

  const getRuleIcon = (type: RuleType) => {
    switch (type) {
      case "admin-presence":
        return <UserCheck className="w-4 h-4" />
      case "player-count":
        return <Users className="w-4 h-4" />
      case "scheduled":
        return <Clock className="w-4 h-4" />
    }
  }

  const getRuleTitle = (type: RuleType) => {
    switch (type) {
      case "admin-presence":
        return t("admin_presence")
      case "player-count":
        return t("player_count")
      case "scheduled":
        return t("scheduled_time")
    }
  }

  if (!visible) return null

  if (showWhitelistView) {
    return (
      <div
        className="h-screen w-screen flex items-center justify-center overflow-hidden"
        style={{
          background: "transparent",
          pointerEvents: "auto",
        }}
      >
        <div
          className="tablet-container overflow-y-auto font-sans"
          style={{
            width: "1200px",
            height: "700px",
            background: "linear-gradient(135deg, rgba(20, 20, 20, 0.95) 0%, rgba(30, 30, 30, 0.95) 100%)",
            border: "1px solid rgba(251, 155, 4, 0.15)",
            borderRadius: "32px",
            boxShadow: "0 8px 32px rgba(0, 0, 0, 0.6), inset 0 1px 0 rgba(255, 255, 255, 0.05), inset 0 -1px 0 rgba(0, 0, 0, 0.5)",
            padding: "32px",
            scrollbarWidth: "none",
            msOverflowStyle: "none",
          }}
        >
          <div className="mb-6 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <img src="./esx-logo.png" alt="ESX Logo" width={40} height={40} className="object-contain" />
              <h1 className="font-bold" style={{ fontSize: "32px", color: "#F2F2F2" }}>
                {t("whitelist_list")}
              </h1>
            </div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                playSound("close")
                setShowWhitelistView(false)
                setSearchQuery("")
                setExpandedEntries(new Set())
              }}
              className="transition-all duration-200 hover:scale-110 active:scale-90 cursor-pointer"
              style={{ color: "#FB9B04" }}
            >
              <X className="w-6 h-6" />
            </Button>
          </div>

          <Card
            className="border animate-in fade-in slide-in-from-bottom-4 duration-500 cursor-default mb-4"
            style={{
              background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
              borderColor: "rgba(251, 155, 4, 0.2)",
              boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
            }}
          >
            <CardHeader className="pb-3">
              <div className="flex items-center gap-3">
                <Search className="w-5 h-5" style={{ color: "#FB9B04" }} />
                <Input
                  type="text"
                  placeholder={t("search_players") || "Search players..."}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="flex-1 cursor-text transition-all duration-200"
                  style={{
                    background: "rgba(25, 25, 25, 0.95)",
                    borderColor: "rgba(251, 155, 4, 0.25)",
                    color: "#F2F2F2",
                    fontSize: "14px",
                  }}
                />
              </div>
            </CardHeader>
          </Card>

          <Card
            className="border animate-in fade-in slide-in-from-bottom-4 duration-500 cursor-default"
            style={{
              background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
              borderColor: "rgba(251, 155, 4, 0.2)",
              boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
            }}
          >
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center gap-2" style={{ fontSize: "18px", color: "#F2F2F2" }}>
                  <List className="w-5 h-5" style={{ color: "#FB9B04" }} />
                  {t("total_entries")}: {filteredEntries.length}
                </CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-3" style={{ maxHeight: "500px", overflowY: "auto" }}>
              {filteredEntries.length === 0 ? (
                <p style={{ fontSize: "14px", color: "#969696", textAlign: "center", padding: "20px" }}>
                  {searchQuery ? t("no_results") || "No results found" : t("no_entries")}
                </p>
              ) : (
                filteredEntries.map((entry, index) => {
                  const isExpanded = expandedEntries.has(entry.id)
                  
                  const groupedIdentifiers = entry.identifiers.reduce((acc, id) => {
                    const [type, value] = id.split(':')
                    if (!acc[type]) acc[type] = []
                    acc[type].push({ full: id, value })
                    return acc
                  }, {} as Record<string, Array<{ full: string, value: string }>>)
                  
                  return (
                    <div
                      key={entry.id}
                      className="border rounded-lg p-4 animate-in fade-in slide-in-from-left-4 duration-300 cursor-default hover:bg-[rgba(251,155,4,0.05)] transition-all"
                      style={{
                        background: "linear-gradient(145deg, rgba(30, 30, 30, 0.95) 0%, rgba(25, 25, 25, 0.95) 100%)",
                        borderColor: entry.whitelisted === 1 ? "rgba(16, 185, 129, 0.4)" : "rgba(239, 68, 68, 0.4)",
                        animationDelay: `${index * 30}ms`,
                      }}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-4 flex-1 min-w-0">
                          <div
                            className="w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0"
                            style={{
                              background: entry.whitelisted === 1 
                                ? "linear-gradient(135deg, #10b981 0%, #059669 100%)"
                                : "linear-gradient(135deg, #ef4444 0%, #dc2626 100%)",
                              boxShadow: entry.whitelisted === 1
                                ? "0 4px 12px rgba(16, 185, 129, 0.3)"
                                : "0 4px 12px rgba(239, 68, 68, 0.3)",
                            }}
                          >
                            <User className="w-6 h-6" style={{ color: "#ffffff" }} />
                          </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1 flex-wrap">
                            <p className="font-bold" style={{ fontSize: "16px", color: "#F2F2F2" }}>
                              {entry.playerName}
                            </p>
                            <Badge
                              variant="outline"
                              style={{
                                borderColor: "rgba(251, 155, 4, 0.4)",
                                background: "rgba(251, 155, 4, 0.15)",
                                color: "#FB9B04",
                                fontSize: "11px",
                                padding: "2px 8px",
                              }}
                            >
                              ID: {entry.id}
                            </Badge>
                          </div>
                          
                          <button
                            onClick={() => toggleExpanded(entry.id)}
                            className="flex items-center gap-1.5 transition-all duration-200 hover:opacity-80 group"
                            style={{ 
                              background: "none",
                              border: "none",
                              padding: 0,
                              cursor: "pointer"
                            }}
                          >
                            {isExpanded ? (
                              <EyeOff className="w-4 h-4 transition-transform duration-200 group-hover:scale-110" style={{ color: "#FB9B04" }} />
                            ) : (
                              <Eye className="w-4 h-4 transition-transform duration-200 group-hover:scale-110" style={{ color: "#FB9B04" }} />
                            )}
                            <span style={{ fontSize: "12px", color: "#FB9B04" }}>
                              ({Object.keys(groupedIdentifiers).length})
                            </span>
                          </button>
                          
                          {isExpanded && (
                            <div className="mt-2 space-y-1">
                              {Object.entries(groupedIdentifiers).map(([type, identifiers]) => (
                                <div key={type} className="flex items-start gap-2">
                                  <div className="flex flex-col gap-0.5 flex-1">
                                    {identifiers.map((id, idx) => (
                                      <div 
                                        key={idx}
                                        className="flex items-center gap-2 p-1 rounded hover:bg-[rgba(251,155,4,0.05)] transition-all"
                                        style={{
                                          borderLeft: `2px solid ${getIdentifierColor(type)}`,
                                          paddingLeft: "8px"
                                        }}
                                      >
                                        <span 
                                          className="font-medium uppercase"
                                          style={{ 
                                            fontSize: "9px", 
                                            color: getIdentifierColor(type),
                                            letterSpacing: "0.5px",
                                            minWidth: "50px"
                                          }}
                                        >
                                          {type}
                                        </span>
                                        <span 
                                          style={{ 
                                            fontSize: "10px", 
                                            color: "#969696",
                                            fontFamily: "monospace",
                                            wordBreak: "break-all",
                                            flex: 1
                                          }}
                                        >
                                          {id.value}
                                        </span>
                                        <button
                                          onClick={() => copyToClipboard(id.full, id.full)}
                                          className="flex-shrink-0 p-0.5 rounded transition-all duration-200 hover:bg-[rgba(251,155,4,0.2)] cursor-pointer"
                                          style={{
                                            border: "1px solid rgba(251, 155, 4, 0.3)",
                                            background: copiedId === id.full ? "rgba(16, 185, 129, 0.2)" : "rgba(251, 155, 4, 0.1)"
                                          }}
                                        >
                                          {copiedId === id.full ? (
                                            <Check className="w-3 h-3" style={{ color: "#10b981" }} />
                                          ) : (
                                            <Copy className="w-3 h-3" style={{ color: "#FB9B04" }} />
                                          )}
                                        </button>
                                      </div>
                                    ))}
                                  </div>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                          <Badge
                            variant="outline"
                            className="flex-shrink-0"
                            style={{
                              borderColor: entry.whitelisted === 1 ? "rgba(16, 185, 129, 0.4)" : "rgba(239, 68, 68, 0.4)",
                              background: entry.whitelisted === 1 ? "rgba(16, 185, 129, 0.15)" : "rgba(239, 68, 68, 0.15)",
                              color: entry.whitelisted === 1 ? "#10b981" : "#ef4444",
                              fontSize: "12px",
                            }}
                          >
                            {entry.whitelisted === 1 ? t("whitelisted") || "Whitelisted" : t("not_whitelisted") || "Not Whitelisted"}
                          </Badge>
                        </div>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => handleToggleWhitelistStatus(entry)}
                          className="transition-all duration-200 hover:scale-110 active:scale-90 cursor-pointer flex-shrink-0 ml-2"
                          style={{ color: entry.whitelisted === 1 ? "#ef4444" : "#10b981" }}
                        >
                          {entry.whitelisted === 1 ? <UserMinus className="w-5 h-5" /> : <UserPlus className="w-5 h-5" />}
                        </Button>
                      </div>
                    </div>
                  )
                })
              )}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    )
  }

  return (
    <div
      className="h-screen w-screen flex items-center justify-center overflow-hidden"
      style={{
        background: "transparent",
        pointerEvents: "auto",
      }}
    >
      <div
        className="tablet-container overflow-y-auto font-sans"
        style={{
          width: "1200px",
          height: "700px",
          background: "linear-gradient(135deg, rgba(20, 20, 20, 0.95) 0%, rgba(30, 30, 30, 0.95) 100%)",
          border: "1px solid rgba(251, 155, 4, 0.15)",
          borderRadius: "32px",
          boxShadow: "0 8px 32px rgba(0, 0, 0, 0.6), inset 0 1px 0 rgba(255, 255, 255, 0.05), inset 0 -1px 0 rgba(0, 0, 0, 0.5)",
          padding: "32px",
          scrollbarWidth: "none",
          msOverflowStyle: "none",
        }}
      >
        <div className="mb-6">
          <div className="flex items-center gap-3 mb-2">
            <img src="./esx-logo.png" alt="ESX Logo" width={40} height={40} className="object-contain" />
            <h1 className="font-bold" style={{ fontSize: "32px", color: "#F2F2F2" }}>
              {t("ui_title")}
            </h1>
          </div>
          <p style={{ fontSize: "14px", color: "#969696" }}>{t("ui_subtitle")}</p>
        </div>

        {validationError && (
          <Card
            className="mb-4 border animate-in fade-in slide-in-from-top-4 duration-300"
            style={{
              background: "rgba(239, 68, 68, 0.15)",
              borderColor: "rgba(239, 68, 68, 0.4)",
            }}
          >
            <CardContent className="py-3">
              <div className="flex items-center gap-3">
                <AlertTriangle className="w-5 h-5 flex-shrink-0" style={{ color: "#ef4444" }} />
                <p style={{ fontSize: "14px", color: "#ef4444" }}>{validationError}</p>
              </div>
            </CardContent>
          </Card>
        )}

        <Card
          className="mb-4 border animate-in fade-in slide-in-from-bottom-4 duration-500 cursor-default"
          style={{
            background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
            borderColor: "rgba(251, 155, 4, 0.2)",
            boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
          }}
        >
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center gap-2" style={{ fontSize: "18px", color: "#F2F2F2" }}>
              <Settings className="w-5 h-5" style={{ color: "#FB9B04" }} />
              {t("current_status")}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-2">
                  <div
                    className="w-3 h-3 rounded-full transition-all duration-300"
                    style={{
                      backgroundColor: whitelistEnabled ? "#10b981" : "#969696",
                      boxShadow: whitelistEnabled ? "0 0 16px rgba(16, 185, 129, 0.8)" : "none",
                      animation: whitelistEnabled ? "pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite" : "none",
                    }}
                  />
                  <span className="font-medium" style={{ fontSize: "16px", color: "#F2F2F2" }}>
                    {whitelistEnabled ? t("whitelist_enabled") : t("whitelist_disabled")}
                  </span>
                </div>
              </div>
              <CustomSwitch checked={whitelistEnabled} onCheckedChange={handleWhitelistToggle} />
            </div>
          </CardContent>
        </Card>

        <div className="grid grid-cols-2 gap-4 mb-4">
          <Card
            className="border animate-in fade-in slide-in-from-left-4 duration-500 delay-100 cursor-default"
            style={{
              background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
              borderColor: "rgba(251, 155, 4, 0.2)",
              boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
            }}
          >
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2" style={{ fontSize: "18px", color: "#F2F2F2" }}>
                <AlertTriangle className="w-5 h-5" style={{ color: "#FB9B04" }} />
                {t("grace_period")}
              </CardTitle>
              <CardDescription style={{ fontSize: "14px", color: "#969696" }}>
                {t("grace_period_desc")}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="space-y-2">
                <Label htmlFor="grace-period" style={{ fontSize: "14px", color: "#F2F2F2" }}>
                  {t("grace_period_seconds")}
                </Label>
                <Input
                  id="grace-period"
                  type="number"
                  value={gracePeriod}
                  onChange={(e) => {
                    const value = Number.parseInt(e.target.value)
                    setGracePeriod(isNaN(value) ? 0 : value)
                  }}
                  className="border cursor-text transition-all duration-200"
                  style={{
                    background: "rgba(25, 25, 25, 0.95)",
                    borderColor: "rgba(251, 155, 4, 0.25)",
                    color: "#F2F2F2",
                    fontSize: "14px",
                  }}
                  min="0"
                />
              </div>
              <Separator style={{ backgroundColor: "rgba(251, 155, 4, 0.15)" }} />
              <div className="flex items-center justify-between">
                <Label htmlFor="kick-connected" style={{ fontSize: "14px", color: "#F2F2F2" }}>
                  {t("kick_connected_label")}
                </Label>
                <CustomSwitch id="kick-connected" checked={kickConnected} onCheckedChange={handleKickConnectedToggle} />
              </div>
            </CardContent>
          </Card>

          <Card
            className="border animate-in fade-in slide-in-from-right-4 duration-500 delay-100 cursor-default"
            style={{
              background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
              borderColor: "rgba(251, 155, 4, 0.2)",
              boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
            }}
          >
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2" style={{ fontSize: "18px", color: "#F2F2F2" }}>
                <Bell className="w-5 h-5" style={{ color: "#FB9B04" }} />
                {t("discord_notifications")}
              </CardTitle>
              <CardDescription style={{ fontSize: "14px", color: "#969696" }}>
                {t("discord_notifications_desc")}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="space-y-2">
                <Label htmlFor="webhook" style={{ fontSize: "14px", color: "#F2F2F2" }}>
                  {t("webhook_url")}
                </Label>
                <Input
                  id="webhook"
                  type="url"
                  placeholder="https://discord.com/api/webhooks/..."
                  value={discordWebhook}
                  onChange={(e) => setDiscordWebhook(e.target.value)}
                  className="cursor-text transition-all duration-200"
                  style={{
                    background: "rgba(25, 25, 25, 0.95)",
                    borderColor: "rgba(251, 155, 4, 0.25)",
                    color: "#F2F2F2",
                    fontSize: "14px",
                  }}
                />
                {discordWebhook === '***CONFIGURED***' && (
                  <p style={{ fontSize: "12px", color: "#969696", marginTop: "4px" }}>
                    {t("webhook_configured")}
                  </p>
                )}
              </div>
              <Button
                onClick={handleTestWebhook}
                className="w-full font-medium transition-all duration-200 hover:scale-[1.02] active:scale-[0.98] cursor-pointer"
                style={{
                  background: "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)",
                  color: "#161616",
                  fontSize: "14px",
                  boxShadow: "0 4px 16px rgba(251, 155, 4, 0.4)",
                }}
              >
                {t("test_webhook")}
              </Button>
            </CardContent>
          </Card>
        </div>

        <Card
          className="mb-4 border animate-in fade-in slide-in-from-bottom-4 duration-500 delay-150 cursor-default"
          style={{
            background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
            borderColor: "rgba(251, 155, 4, 0.2)",
            boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
          }}
        >
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2" style={{ fontSize: "18px", color: "#F2F2F2" }}>
                  <Hash className="w-5 h-5" style={{ color: "#FB9B04" }} />
                  {t("discord_verification")}
                </CardTitle>
                <CardDescription style={{ fontSize: "14px", color: "#969696" }}>
                  {t("discord_verification_desc")}
                </CardDescription>
              </div>
              <CustomSwitch checked={discordEnabled} onCheckedChange={handleDiscordToggle} />
            </div>
          </CardHeader>
          <CardContent className="space-y-3">
            {discordEnabled && (
              <>
                <div
                  className="border rounded-lg p-3 flex items-center gap-3"
                  style={{
                    background: "rgba(25, 25, 25, 0.95)",
                    borderColor: hasBotToken ? "rgba(16, 185, 129, 0.4)" : "rgba(239, 68, 68, 0.4)",
                  }}
                >
                  <div
                    className="w-2 h-2 rounded-full"
                    style={{
                      backgroundColor: hasBotToken ? "#10b981" : "#ef4444",
                      boxShadow: hasBotToken ? "0 0 8px rgba(16, 185, 129, 0.6)" : "0 0 8px rgba(239, 68, 68, 0.6)",
                    }}
                  />
                  <div className="flex-1">
                    <p className="font-medium" style={{ fontSize: "13px", color: hasBotToken ? "#10b981" : "#ef4444" }}>
                      {t("discord_token_status")}
                    </p>
                    <p style={{ fontSize: "12px", color: "#969696" }}>
                      {hasBotToken ? t("discord_token_configured") : t("discord_token_missing")}
                    </p>
                  </div>
                </div>

                {!hasBotToken && (
                  <div
                    className="border rounded-lg p-3 flex items-start gap-3"
                    style={{
                      background: "rgba(239, 68, 68, 0.1)",
                      borderColor: "rgba(239, 68, 68, 0.3)",
                    }}
                  >
                    <AlertTriangle className="w-5 h-5 flex-shrink-0" style={{ color: "#ef4444", marginTop: "2px" }} />
                    <p style={{ fontSize: "12px", color: "#ef4444", lineHeight: "1.5" }}>
                      {t("discord_token_warning")}
                    </p>
                  </div>
                )}
              </>
            )}

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label htmlFor="guild-id" style={{ fontSize: "14px", color: "#F2F2F2" }}>
                  {t("guild_id")}
                </Label>
                <Input
                  id="guild-id"
                  type="text"
                  placeholder="123456789012345678"
                  value={discordGuildId}
                  onChange={(e) => setDiscordGuildId(e.target.value)}
                  disabled={!discordEnabled}
                  className="cursor-text transition-all duration-200"
                  style={{
                    background: "rgba(25, 25, 25, 0.95)",
                    borderColor: "rgba(251, 155, 4, 0.25)",
                    color: "#F2F2F2",
                    fontSize: "14px",
                    opacity: discordEnabled ? 1 : 0.5,
                  }}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="role-id" style={{ fontSize: "14px", color: "#F2F2F2" }}>
                  {t("role_id")}
                </Label>
                <Input
                  id="role-id"
                  type="text"
                  placeholder="123456789012345678"
                  value={discordRoleId}
                  onChange={(e) => setDiscordRoleId(e.target.value)}
                  disabled={!discordEnabled}
                  className="cursor-text transition-all duration-200"
                  style={{
                    background: "rgba(25, 25, 25, 0.95)",
                    borderColor: "rgba(251, 155, 4, 0.25)",
                    color: "#F2F2F2",
                    fontSize: "14px",
                    opacity: discordEnabled ? 1 : 0.5,
                  }}
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {!discordEnabled && (
          <Card
            className="mb-4 border animate-in fade-in slide-in-from-bottom-4 duration-500 delay-200 cursor-default"
            style={{
              background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
              borderColor: "rgba(251, 155, 4, 0.2)",
              boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
            }}
          >
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle className="flex items-center gap-2" style={{ fontSize: "18px", color: "#F2F2F2" }}>
                    <User className="w-5 h-5" style={{ color: "#FB9B04" }} />
                    {t("manage_whitelist")}
                  </CardTitle>
                  <CardDescription style={{ fontSize: "14px", color: "#969696" }}>
                    {t("manage_whitelist_desc")}
                  </CardDescription>
                </div>
                <Button
                  onClick={handleViewWhitelist}
                  size="sm"
                  className="font-medium transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer"
                  style={{
                    background: "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)",
                    color: "#161616",
                    fontSize: "13px",
                    boxShadow: "0 2px 8px rgba(251, 155, 4, 0.3)",
                  }}
                >
                  <List className="w-4 h-4 mr-1" />
                  {t("view_list")}
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-3">
                <div className="flex-1">
                  <Label style={{ fontSize: "13px", color: "#969696", marginBottom: "6px", display: "block" }}>{t("action")}</Label>
                  <Select value={whitelistAction} onValueChange={(value) => setWhitelistAction(value as WhitelistAction)}>
                    <SelectTrigger
                      className="cursor-pointer transition-all duration-200"
                      style={{
                        background: "rgba(25, 25, 25, 0.95)",
                        borderColor: "rgba(251, 155, 4, 0.25)",
                        color: "#F2F2F2",
                        fontSize: "14px",
                      }}
                    >
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent
                      style={{
                        background: "rgba(20, 20, 20, 0.98)",
                        borderColor: "rgba(251, 155, 4, 0.25)",
                      }}
                    >
                      <SelectItem value="add" className="cursor-pointer">{t("add_to_whitelist")}</SelectItem>
                      <SelectItem value="remove" className="cursor-pointer">{t("remove_from_whitelist")}</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <Label style={{ fontSize: "13px", color: "#969696" }}>{t("identifier_type")}</Label>
                    {detectedType && (
                      <Badge
                        variant="outline"
                        style={{
                          borderColor: "rgba(16, 185, 129, 0.4)",
                          background: "rgba(16, 185, 129, 0.15)",
                          color: "#10b981",
                          fontSize: "9px",
                          padding: "1px 5px",
                        }}
                      >
                        <CheckCircle2 className="w-2.5 h-2.5 mr-0.5" />
                        {detectedType.toUpperCase()}
                      </Badge>
                    )}
                  </div>
                  <Select value={identifierType} onValueChange={(value) => setIdentifierType(value as IdentifierType)} disabled={!!detectedType}>
                    <SelectTrigger
                      className="cursor-pointer transition-all duration-200"
                      style={{
                        background: "rgba(25, 25, 25, 0.95)",
                        borderColor: detectedType ? "rgba(16, 185, 129, 0.4)" : "rgba(251, 155, 4, 0.25)",
                        color: "#F2F2F2",
                        fontSize: "14px",
                        opacity: detectedType ? 0.7 : 1,
                      }}
                    >
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent
                      style={{
                        background: "rgba(20, 20, 20, 0.98)",
                        borderColor: "rgba(251, 155, 4, 0.25)",
                      }}
                    >
                      <SelectItem value="license" className="cursor-pointer">License</SelectItem>
                      <SelectItem value="license2" className="cursor-pointer">License2</SelectItem>
                      <SelectItem value="steam" className="cursor-pointer">Steam</SelectItem>
                      <SelectItem value="discord" className="cursor-pointer">Discord</SelectItem>
                      <SelectItem value="xbl" className="cursor-pointer">Xbox Live</SelectItem>
                      <SelectItem value="fivem" className="cursor-pointer">FiveM</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="flex-[1.5]">
                  <Label style={{ fontSize: "13px", color: "#969696", marginBottom: "6px", display: "block" }}>{t("identifier_value")}</Label>
                  <Input
                    type="text"
                    placeholder="abc123def456..."
                    value={playerIdentifier}
                    onChange={(e) => setPlayerIdentifier(e.target.value)}
                    className="cursor-text transition-all duration-200"
                    style={{
                      background: "rgba(25, 25, 25, 0.95)",
                      borderColor: detectedType ? "rgba(16, 185, 129, 0.4)" : "rgba(251, 155, 4, 0.25)",
                      color: "#F2F2F2",
                      fontSize: "14px",
                    }}
                  />
                </div>

                <div style={{ marginTop: "21px" }}>
                  <Button
                    onClick={handleManagePlayer}
                    className="font-medium transition-all duration-200 hover:scale-[1.02] active:scale-[0.98] cursor-pointer"
                    style={{
                      background: "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)",
                      color: "#161616",
                      fontSize: "14px",
                      boxShadow: "0 4px 12px rgba(251, 155, 4, 0.4)",
                    }}
                  >
                    {t("apply")}
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        <Card
          className="mb-4 border animate-in fade-in slide-in-from-bottom-4 duration-500 delay-300 cursor-default"
          style={{
            background: "linear-gradient(145deg, rgba(40, 40, 40, 0.9) 0%, rgba(35, 35, 35, 0.9) 100%)",
            borderColor: "rgba(251, 155, 4, 0.2)",
            boxShadow: "0 4px 16px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.03)",
          }}
        >
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2" style={{ fontSize: "18px", color: "#F2F2F2" }}>
                  <Settings className="w-5 h-5" style={{ color: "#FB9B04" }} />
                  {t("whitelist_rules")}
                </CardTitle>
                <CardDescription style={{ fontSize: "14px", color: "#969696" }}>
                  {t("whitelist_rules_desc")}
                </CardDescription>
              </div>
              <div className="flex gap-2">
                <Button
                  onClick={() => handleAddRule("admin-presence")}
                  size="sm"
                  className="font-medium transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer"
                  style={{
                    background: "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)",
                    color: "#161616",
                    fontSize: "13px",
                    boxShadow: "0 2px 8px rgba(251, 155, 4, 0.3)",
                  }}
                >
                  <UserCheck className="w-4 h-4 mr-1" />
                  {t("add_admin")}
                </Button>
                <Button
                  onClick={() => handleAddRule("player-count")}
                  size="sm"
                  className="font-medium transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer"
                  style={{
                    background: "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)",
                    color: "#161616",
                    fontSize: "13px",
                    boxShadow: "0 2px 8px rgba(251, 155, 4, 0.3)",
                  }}
                >
                  <Users className="w-4 h-4 mr-1" />
                  {t("add_players")}
                </Button>
                <Button
                  onClick={() => handleAddRule("scheduled")}
                  size="sm"
                  className="font-medium transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer"
                  style={{
                    background: "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)",
                    color: "#161616",
                    fontSize: "13px",
                    boxShadow: "0 2px 8px rgba(251, 155, 4, 0.3)",
                  }}
                >
                  <Clock className="w-4 h-4 mr-1" />
                  {t("add_schedule")}
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent className="space-y-3">
            {rules.map((rule, index) => (
              <div
                key={rule.id}
                className="border rounded-lg p-4 animate-in fade-in slide-in-from-left-4 duration-300 cursor-default"
                style={{
                  background: "linear-gradient(145deg, rgba(30, 30, 30, 0.95) 0%, rgba(25, 25, 25, 0.95) 100%)",
                  borderColor: "rgba(251, 155, 4, 0.25)",
                  boxShadow: "inset 0 1px 0 rgba(0, 0, 0, 0.5)",
                  animationDelay: `${index * 50}ms`,
                }}
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <CustomSwitch checked={rule.enabled} onCheckedChange={(checked) => handleRuleToggle(rule.id, checked)} />
                    <div className="flex items-center gap-2">
                      {getRuleIcon(rule.type)}
                      <span className="font-medium" style={{ fontSize: "15px", color: "#F2F2F2" }}>
                        {getRuleTitle(rule.type)}
                      </span>
                    </div>
                    <Badge
                      variant="outline"
                      style={{
                        borderColor: "rgba(251, 155, 4, 0.4)",
                        background: "rgba(251, 155, 4, 0.15)",
                        color: "#FB9B04",
                        fontSize: "13px",
                      }}
                    >
                      {t("priority")} {rule.priority}
                    </Badge>
                  </div>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleRemoveRule(rule.id)}
                    className="transition-all duration-200 hover:scale-110 active:scale-90 cursor-pointer"
                    style={{ color: "#ef4444" }}
                  >
                    <UserMinus className="w-4 h-4" />
                  </Button>
                </div>

                {(rule.type === "admin-presence" || rule.type === "player-count") && (
                  <div className="grid grid-cols-4 gap-3">
                    <div className="space-y-1">
                      <Label style={{ fontSize: "13px", color: "#969696" }}>{t("condition")}</Label>
                      <Select
                        value={rule.operator}
                        onValueChange={(value) => updateRule(rule.id, { operator: value as Operator })}
                      >
                        <SelectTrigger
                          className="cursor-pointer transition-all duration-200"
                          style={{
                            background: "rgba(25, 25, 25, 0.95)",
                            borderColor: "rgba(251, 155, 4, 0.25)",
                            color: "#F2F2F2",
                            fontSize: "14px",
                          }}
                        >
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent
                          style={{
                            background: "rgba(20, 20, 20, 0.98)",
                            borderColor: "rgba(251, 155, 4, 0.25)",
                          }}
                        >
                          <SelectItem value="<" className="cursor-pointer">
                            {t("less_than")}
                          </SelectItem>
                          <SelectItem value=">" className="cursor-pointer">
                            {t("greater_than")}
                          </SelectItem>
                          <SelectItem value=">=" className="cursor-pointer">
                            {t("greater_equal")}
                          </SelectItem>
                          <SelectItem value="==" className="cursor-pointer">
                            {t("equal_to")}
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-1">
                      <Label style={{ fontSize: "13px", color: "#969696" }}>
                        {rule.type === "admin-presence" ? t("admin_count") : t("player_count_label")}
                      </Label>
                      <Input
                        type="number"
                        value={rule.value}
                        onChange={(e) => updateRule(rule.id, { value: Number.parseInt(e.target.value) })}
                        className="cursor-text transition-all duration-200"
                        style={{
                          background: "rgba(25, 25, 25, 0.95)",
                          borderColor: "rgba(251, 155, 4, 0.25)",
                          color: "#F2F2F2",
                          fontSize: "14px",
                        }}
                        min="0"
                      />
                    </div>
                    <div className="space-y-1">
                      <Label style={{ fontSize: "13px", color: "#969696" }}>{t("action")}</Label>
                      <Select
                        value={rule.action}
                        onValueChange={(value) => updateRule(rule.id, { action: value as Action })}
                      >
                        <SelectTrigger
                          className="cursor-pointer transition-all duration-200"
                          style={{
                            background: "rgba(25, 25, 25, 0.95)",
                            borderColor: "rgba(251, 155, 4, 0.25)",
                            color: "#F2F2F2",
                            fontSize: "14px",
                          }}
                        >
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent
                          style={{
                            background: "rgba(20, 20, 20, 0.98)",
                            borderColor: "rgba(251, 155, 4, 0.25)",
                          }}
                        >
                          <SelectItem value="enable" className="cursor-pointer">
                            {t("enable_whitelist")}
                          </SelectItem>
                          <SelectItem value="disable" className="cursor-pointer">
                            {t("disable_whitelist")}
                          </SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-1">
                      <Label style={{ fontSize: "13px", color: "#969696" }}>{t("priority")}</Label>
                      <Input
                        type="number"
                        value={rule.priority}
                        onChange={(e) => updateRule(rule.id, { priority: Number.parseInt(e.target.value) })}
                        className="cursor-text transition-all duration-200"
                        style={{
                          background: "rgba(25, 25, 25, 0.95)",
                          borderColor: "rgba(251, 155, 4, 0.25)",
                          color: "#F2F2F2",
                          fontSize: "14px",
                        }}
                        min="1"
                      />
                    </div>
                  </div>
                )}

                {rule.type === "scheduled" && (
                  <div className="grid grid-cols-3 gap-3">
                    <div className="space-y-1">
                      <Label style={{ fontSize: "13px", color: "#969696" }}>{t("start_time")}</Label>
                      <Input
                        type="time"
                        value={rule.startTime}
                        onChange={(e) => updateRule(rule.id, { startTime: e.target.value })}
                        className="cursor-text transition-all duration-200"
                        style={{
                          background: "rgba(25, 25, 25, 0.95)",
                          borderColor: "rgba(251, 155, 4, 0.25)",
                          color: "#F2F2F2",
                          fontSize: "14px",
                        }}
                      />
                    </div>
                    <div className="space-y-1">
                      <Label style={{ fontSize: "13px", color: "#969696" }}>{t("end_time")}</Label>
                      <Input
                        type="time"
                        value={rule.endTime}
                        onChange={(e) => updateRule(rule.id, { endTime: e.target.value })}
                        className="cursor-text transition-all duration-200"
                        style={{
                          background: "rgba(25, 25, 25, 0.95)",
                          borderColor: "rgba(251, 155, 4, 0.25)",
                          color: "#F2F2F2",
                          fontSize: "14px",
                        }}
                      />
                    </div>
                    <div className="space-y-1">
                      <Label style={{ fontSize: "13px", color: "#969696" }}>{t("priority")}</Label>
                      <Input
                        type="number"
                        value={rule.priority}
                        onChange={(e) => updateRule(rule.id, { priority: Number.parseInt(e.target.value) })}
                        className="cursor-text transition-all duration-200"
                        style={{
                          background: "rgba(25, 25, 25, 0.95)",
                          borderColor: "rgba(251, 155, 4, 0.25)",
                          color: "#F2F2F2",
                          fontSize: "14px",
                        }}
                        min="1"
                      />
                    </div>
                  </div>
                )}
              </div>
            ))}
          </CardContent>
        </Card>

        <div className="flex justify-end gap-3 animate-in fade-in slide-in-from-bottom-4 duration-500 delay-400">
          <Button
            variant="outline"
            onClick={handleReset}
            className="font-medium border transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer"
            style={{
              borderColor: "rgba(251, 155, 4, 0.4)",
              background: "rgba(251, 155, 4, 0.1)",
              color: "#FB9B04",
              fontSize: "14px",
            }}
          >
            {t("reset")}
          </Button>
          <Button
            onClick={handleSave}
            disabled={isSaving}
            className="font-medium transition-all duration-200 hover:scale-105 active:scale-95 cursor-pointer"
            style={{
              background: "linear-gradient(135deg, #FB9B04 0%, #ff8800 100%)",
              color: "#161616",
              fontSize: "14px",
              boxShadow: "0 4px 20px rgba(251, 155, 4, 0.4)",
              opacity: isSaving ? 0.7 : 1,
            }}
          >
            {t("save_configuration")}
          </Button>
        </div>
      </div>
    </div>
  )
}