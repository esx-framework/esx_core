<script module lang="ts">
  declare global {
    interface Window {
      GetParentResourceName?: () => string
      invokeNative?: unknown
    }
  }
</script>

<script lang="ts">
  import { onMount } from 'svelte'
  import type { WhitelistConfig, WhitelistEntry, WhitelistRule } from './types'
  import { applyThemeConvars } from './theme'
  import { sounds } from './audio'
  import logo from '/esx-logo.png'

  // Detect if running inside browser or FiveM CEF
  const isBrowser = typeof window !== 'undefined' && typeof window.invokeNative !== 'function'

  const demoConfig: WhitelistConfig = {
    whitelistEnabled: true,
    gracePeriod: 60,
    kickConnected: false,
    discordWebhook: 'https://discord.com/api/webhooks/...',
    discordEnabled: true,
    discordGuildId: '123456789012345678',
    discordRoleId: '987654321098765432',
    authorizationMethod: 'discord',
    rules: [
      { id: '1', type: 'admin-presence', enabled: true, priority: 1, operator: '<', value: 1, action: 'enable' },
      { id: '2', type: 'player-count', enabled: false, priority: 2, operator: '>', value: 64, action: 'enable' },
      { id: '3', type: 'scheduled', enabled: true, priority: 3, startTime: '02:00', endTime: '06:00' }
    ]
  }

  const demoEntries: WhitelistEntry[] = [
    {
      id: 1,
      playerName: 'John_Doe',
      whitelisted: 1,
      identifiers: ['license:40charhex11111111111111111111111111111', 'discord:123456789012345678', 'steam:110000101234567']
    },
    {
      id: 2,
      playerName: 'Jane_Smith',
      whitelisted: 1,
      identifiers: ['license:40charhex22222222222222222222222222222', 'discord:234567890123456789']
    },
    {
      id: 3,
      playerName: 'Alex_Vance',
      whitelisted: 0,
      identifiers: ['license2:33333333-3333-3333-3333-333333333333', 'fivem:1234567']
    }
  ]

  let visible = $state(isBrowser)
  let activeTab = $state<'general' | 'rules' | 'manage' | 'list'>('general')
  let searchQuery = $state('')
  let expandedEntryId = $state<number | null>(null)
  let notification = $state<{ text: string; type: 'success' | 'danger' | 'info' } | null>(null)

  // Form states
  let config = $state<WhitelistConfig>(isBrowser ? demoConfig : {
    whitelistEnabled: false,
    gracePeriod: 60,
    kickConnected: false,
    discordWebhook: '',
    discordEnabled: false,
    discordGuildId: '',
    discordRoleId: '',
    authorizationMethod: 'identifier',
    rules: []
  })

  let entries = $state<WhitelistEntry[]>(isBrowser ? demoEntries : [])
  let currentPage = $state(1)
  let pageCursors = $state<(number | null)[]>([null])
  let nextCursor = $state<number | null>(null)
  let hasMoreEntries = $state(false)
  let pageSize = $state(50)
  let isLoadingEntries = $state(false)
  let entriesRequest = 0
  let searchTimer: ReturnType<typeof setTimeout> | null = null
  let entryRefreshTimer: ReturnType<typeof setTimeout> | null = null
  let newIdentifier = $state('')
  let newAction = $state<'add' | 'remove'>('add')
  let isSaving = $state(false)

  // New Rule Modal state
  let isAddingRule = $state(false)
  let newRuleType = $state<'admin-presence' | 'player-count' | 'scheduled'>('admin-presence')
  let newRuleOperator = $state<'<' | '>' | '<=' | '>=' | '=='>('<')
  let newRuleValue = $state<number>(1)
  let newRuleAction = $state<'enable' | 'disable'>('enable')
  let newRuleStartTime = $state('00:00')
  let newRuleEndTime = $state('06:00')

  function isWhitelisted(entry: { whitelisted: number | string | boolean }): boolean {
    return Number(entry.whitelisted) === 1
  }

  function normalizeEntries(resultEntries: WhitelistEntry[]): WhitelistEntry[] {
    return resultEntries.map((entry) => ({
      ...entry,
      whitelisted: isWhitelisted(entry) ? 1 : 0
    }))
  }

  function showToast(text: string, type: 'success' | 'danger' | 'info' = 'info') {
    notification = { text, type }
    if (type === 'success') sounds.playSuccess()
    else if (type === 'danger') sounds.playError()
    else sounds.playClick()

    setTimeout(() => {
      notification = null
    }, 3000)
  }

  const browserSuccess = <T>() => true as unknown as T

  async function postNui<T = unknown>(action: string, data: unknown = {}): Promise<T | null> {
    if (isBrowser) {
      if (action === 'getWhitelistEntries') {
        const payload = data as {
          cursor?: number | null
            limit?: number
            search?: string
        }

        const cursor = payload.cursor ?? null
        const limit = Math.max(1, payload.limit ?? 50)
        const search = (payload.search ?? '').trim().toLowerCase()

        const filtered = demoEntries.filter((entry) => {
            if (!search) return true

          if (/^[a-z0-9_]+:/.test(search)) {
            return entry.identifiers.some((id) => id.toLowerCase().startsWith(search))
          }
          return entry.playerName.toLowerCase().startsWith(search)
        })

        const available = filtered
          .filter((entry) => cursor === null || entry.id < cursor)
          .sort((first, second) => second.id - first.id)
        const pageEntries = available.slice(0, limit)
        const hasMore = available.length > limit

        return {
          entries: pageEntries,
          cursor,
          nextCursor: hasMore ? pageEntries[pageEntries.length - 1]?.id ?? null : null,
          hasMore,
            limit,
        } as unknown as T
      }
      if (action === 'updateConfig') {
        return browserSuccess<T>()
      }
      if (action === 'testWebhook') {
        return browserSuccess<T>()
      }
      if (action === 'toggleWhitelistStatus') {
        return browserSuccess<T>()
      }
      if (action === 'managePlayer') {
        const payload = data as { identifier?: string; action?: string }
        if (payload.action === 'add' && payload.identifier) {
          const newEntry: WhitelistEntry = {
            id: entries.length + 1,
            playerName: 'New_Player',
            whitelisted: 1,
            identifiers: [payload.identifier]
          }
          entries = [...entries, newEntry]
        }
        return { success: true, message: 'Browser demo: action simulated successfully' } as unknown as T
      }
      if (action === 'closeUI') {
        visible = false
        return 'ok' as unknown as T
      }
    }

    try {
      const resource = window.GetParentResourceName?.() ?? 'esx_whitelist'
      const resp = await fetch(`https://${resource}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
      })
      return await resp.json()
    } catch {
      return null
    }
  }

  function closeUI() {
    sounds.playClick()
    cancelEntryRefresh()
    visible = false
    postNui('closeUI')
  }

  async function saveConfig() {
    isSaving = true
    sounds.playClick()
    const success = await postNui<boolean>('updateConfig', config)
    isSaving = false
    if (success) {
      showToast('Configuration saved successfully', 'success')
    } else {
      showToast('Failed to save configuration', 'danger')
    }
  }

  async function testWebhook() {
    sounds.playClick()
    const ok = await postNui<boolean>('testWebhook')
    if (ok) {
      showToast('Test webhook sent to Discord', 'success')
    } else {
      showToast('Failed to send test webhook', 'danger')
    }
  }

  async function loadEntries(cursor = pageCursors[currentPage - 1] ?? null, search = searchQuery, page = currentPage) {
    cancelEntryRefresh()
    const requestId = ++entriesRequest
    isLoadingEntries = true

    try {
      const result = await postNui<{
        entries: WhitelistEntry[]
        cursor: number | null
        nextCursor: number | null
        hasMore: boolean
        limit: number
      }>('getWhitelistEntries', {
        cursor,
        limit: pageSize,
        search: search.trim()
      })

      if (!result || requestId !== entriesRequest) return

      entries = normalizeEntries(result.entries ?? [])
      currentPage = page
      pageCursors[page - 1] = cursor
      nextCursor = result.nextCursor ?? null
      hasMoreEntries = result.hasMore === true
    } finally {
      if (requestId === entriesRequest) isLoadingEntries = false
    }
  }

  function cancelEntryRefresh() {
    if (entryRefreshTimer === null) return
    clearTimeout(entryRefreshTimer)
    entryRefreshTimer = null
  }

  function scheduleEntryRefresh() {
    if (entryRefreshTimer !== null) return
    entryRefreshTimer = setTimeout(() => {
      entryRefreshTimer = null
      if (visible) loadEntries()
    }, 500)
  }

  function loadPreviousPage() {
    if (currentPage <= 1 || isLoadingEntries) return
    const page = currentPage - 1
    loadEntries(pageCursors[page - 1] ?? null, searchQuery, page)
  }

  function loadNextPage() {
    if (!hasMoreEntries || nextCursor === null || isLoadingEntries) return
    const page = currentPage + 1
    pageCursors = [...pageCursors.slice(0, currentPage), nextCursor]
    loadEntries(nextCursor, searchQuery, page)
  }

  async function handleManagePlayer() {
    if (!newIdentifier.trim()) {
      showToast('Please enter a valid identifier', 'danger')
      return
    }

    sounds.playClick()
    const result = await postNui<{ success: boolean; message: string }>('managePlayer', {
      identifier: newIdentifier.trim(),
      action: newAction
    })

    if (result && result.success) {
      showToast(result.message || 'Action executed successfully', 'success')
      newIdentifier = ''
      await loadEntries()
    } else {
      showToast(result?.message || 'Action failed', 'danger')
    }
  }

  async function toggleStatus(entry: WhitelistEntry) {
    sounds.playClick()
    const newStatus = isWhitelisted(entry) ? 0 : 1
    const ok = await postNui<boolean>('toggleWhitelistStatus', {
      id: entry.id,
      status: newStatus
    })

    if (ok) {
      entries = entries.map((item) =>
        item.id === entry.id
          ? { ...item, whitelisted: newStatus }
          : item
      )
      showToast(`Status updated to ${newStatus === 1 ? 'Whitelisted' : 'Not Whitelisted'}`, 'success')
    } else {
      showToast('Failed to update status', 'danger')
    }
  }

  function addRule() {
    const newId = (config.rules.length + 1).toString()
    const rule: WhitelistRule = {
      id: newId,
      type: newRuleType,
      enabled: true,
      priority: config.rules.length + 1,
      operator: newRuleOperator,
      value: Number(newRuleValue),
      action: newRuleAction,
      startTime: newRuleStartTime,
      endTime: newRuleEndTime
    }

    config.rules = [...config.rules, rule]
    isAddingRule = false
    sounds.playSuccess()
    showToast('Rule added', 'info')
  }

  function removeRule(index: number) {
    sounds.playClick()
    config.rules = config.rules.filter((_, i) => i !== index)
    showToast('Rule removed', 'info')
  }

  function toggleRule(index: number) {
    config.rules[index].enabled = !config.rules[index].enabled
    sounds.playToggle(config.rules[index].enabled)
  }

  function handleSearchInput() {
    if (searchTimer) {
        clearTimeout(searchTimer)
    }

    searchTimer = setTimeout(() => {
        currentPage = 1
      pageCursors = [null]
      loadEntries(null, searchQuery, 1)
    }, 250)
  }

  onMount(() => {
    if (isBrowser) {
      document.body.classList.add('is-browser')
    }

    function handleMessage(event: MessageEvent) {
      const item = event.data
      if (item.action === 'openUI') {
        if (item.data) {
          config = { ...config, ...item.data }
          applyThemeConvars(item.data.theme)
        }
        visible = true
        loadEntries()
      } else if (item.action === 'closeUI') {
        cancelEntryRefresh()
        visible = false
      } else if (item.action === 'whitelistStateChanged' && item.data) {
        config = { ...config, ...item.data }
      } else if (item.action === 'whitelistEntryChanged' && visible) {
        scheduleEntryRefresh()
      }
    }

    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape' && visible) {
        closeUI()
      }
    }

    window.addEventListener('message', handleMessage)
    window.addEventListener('keydown', handleKeyDown)

    return () => {
      cancelEntryRefresh()
      window.removeEventListener('message', handleMessage)
      window.removeEventListener('keydown', handleKeyDown)
    }
  })
</script>

{#if visible}
  <main class="panel-container">
    <!-- Header -->
    <header class="panel-header">
      <div class="header-left">
        <div class="header-emblem">
          <img src={logo} alt="ESX" />
        </div>
        <div>
          <h2>Whitelist Control Panel</h2>
          <p class="subtitle">ESX Dynamic Whitelist Management</p>
        </div>
      </div>
      <div class="header-right">
        <div class="status-indicator">
          <span class="status-dot" class:active={config.whitelistEnabled}></span>
          <span class="status-text">{config.whitelistEnabled ? 'WHITELIST ON' : 'WHITELIST OFF'}</span>
        </div>
        <button class="btn btn-ghost close-btn" onclick={closeUI} title="Close (ESC)">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
    </header>

    <!-- Navigation Tabs -->
    <nav class="nav-tabs">
      <button
        class="tab-btn"
        class:active={activeTab === 'general'}
        onclick={() => { activeTab = 'general'; sounds.playClick() }}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        General Settings
      </button>
      <button
        class="tab-btn"
        class:active={activeTab === 'rules'}
        onclick={() => { activeTab = 'rules'; sounds.playClick() }}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        Dynamic Rules ({config.rules.length})
      </button>
      <button
        class="tab-btn"
        class:active={activeTab === 'manage'}
        onclick={() => { activeTab = 'manage'; sounds.playClick() }}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7.5" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
        Quick Manage
      </button>
      <button
        class="tab-btn"
        class:active={activeTab === 'list'}
        onclick={() => { activeTab = 'list'; currentPage = 1; pageCursors = [null]; loadEntries(null, searchQuery, 1); sounds.playClick() }}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>
        Database
      </button>
    </nav>

    <!-- Tab Content -->
    <section class="tab-content" class:no-scroll={activeTab === 'general'}>
      {#if activeTab === 'general'}
        <div class="content-grid">
          <!-- Whitelist Mode Card -->
          <div class="card">
            <h3>Master Whitelist</h3>
            <p class="card-desc">Enable or disable server-wide whitelist enforcement.</p>

            <div class="setting-row">
              <div class="setting-info">
                <span class="setting-label">Enforce Whitelist</span>
                <p class="setting-hint">When off, normal players can join without whitelist checks</p>
              </div>
              <label class="switch" for="master-toggle">
                <input
                  id="master-toggle"
                  type="checkbox"
                  bind:checked={config.whitelistEnabled}
                  onchange={() => sounds.playToggle(config.whitelistEnabled)}
                />
                <span class="slider"></span>
              </label>
            </div>

            <div class="setting-row">
              <div class="setting-info">
                <label for="grace-input" class="setting-label">Grace Period (seconds)</label>
                <p class="setting-hint">Time allowed before connected non-whitelisted players are kicked</p>
              </div>
              <input
                id="grace-input"
                type="number"
                min="0"
                max="600"
                class="text-input"
                style="width: 90px; text-align: center;"
                bind:value={config.gracePeriod}
              />
            </div>

            <div class="setting-row">
              <div class="setting-info">
                <span class="setting-label">Immediate Kick Connected</span>
                <p class="setting-hint">Kick non-whitelisted players instantly when enabled without grace period</p>
              </div>
              <label class="switch" for="kick-connected-toggle">
                <input
                  id="kick-connected-toggle"
                  type="checkbox"
                  bind:checked={config.kickConnected}
                  onchange={() => sounds.playToggle(config.kickConnected)}
                />
                <span class="slider"></span>
              </label>
            </div>
          </div>

          <!-- Discord Integration Card -->
          <div class="card">
            <h3>Discord Integration</h3>
            <p class="card-desc">Automatic role verification and audit log webhook</p>

            <div class="input-group">
              <label for="authorization-method" class="input-label">Whitelist Method</label>
              <select id="authorization-method" class="select-input" bind:value={config.authorizationMethod} onchange={() => sounds.playClick()}>
                <option value="identifier">Identifier database</option>
                <option value="discord">Discord role</option>
              </select>
              <p class="setting-hint">When enabled, normal players must pass the selected method; ESX/ACE administrators are exempt.</p>
            </div>

            <div class="input-group">
              <label for="discord-guild-id" class="input-label">Discord Guild ID</label>
              <input
                id="discord-guild-id"
                type="text"
                placeholder="e.g. 112233445566778899"
                class="text-input"
                bind:value={config.discordGuildId}
              />
            </div>

            <div class="input-group">
              <label for="discord-role-id" class="input-label">Whitelisted Role ID</label>
              <input
                id="discord-role-id"
                type="text"
                placeholder="e.g. 998877665544332211"
                class="text-input"
                bind:value={config.discordRoleId}
              />
            </div>

            <div class="input-group">
              <label for="discord-webhook-url" class="input-label">Discord Webhook URL</label>
              <div style="display: flex; gap: 8px;">
                <input
                  id="discord-webhook-url"
                  type="text"
                  placeholder="https://discord.com/api/webhooks/..."
                  class="text-input"
                  style="flex: 1;"
                  bind:value={config.discordWebhook}
                />
                <button class="btn btn-info" onclick={testWebhook}>Test</button>
              </div>
            </div>
          </div>
        </div>

        <div class="footer-actions">
          <button class="btn btn-brand" onclick={saveConfig} disabled={isSaving}>
            {#if isSaving}
              Saving...
            {:else}
              Save Configuration
            {/if}
          </button>
        </div>
      {:else if activeTab === 'rules'}
        <div class="rules-container">
          <div class="rules-header">
            <div>
              <h3>Dynamic Automation Rules</h3>
              <p class="subtitle">Automate whitelist activation based on server conditions</p>
            </div>
            <button class="btn btn-brand" onclick={() => { isAddingRule = true; sounds.playClick() }}>
              + Add Rule
            </button>
          </div>

          {#if isAddingRule}
            <div class="card add-rule-card">
              <h4>Create New Dynamic Rule</h4>
              <div class="rule-inputs-grid">
                <div class="input-group">
                  <label for="rule-type-select" class="input-label">Trigger Type</label>
                  <select id="rule-type-select" class="select-input" bind:value={newRuleType}>
                    <option value="admin-presence">Admin Presence</option>
                    <option value="player-count">Player Count</option>
                    <option value="scheduled">Scheduled Time (UTC/Local)</option>
                  </select>
                </div>

                {#if newRuleType !== 'scheduled'}
                  <div class="input-group">
                    <label for="rule-operator-select" class="input-label">Operator</label>
                    <select id="rule-operator-select" class="select-input" bind:value={newRuleOperator}>
                      <option value="<">Less Than (&lt;)</option>
                      <option value="<=">Less or Equal (&lt;=)</option>
                      <option value=">">Greater Than (&gt;)</option>
                      <option value=">=">Greater or Equal (&gt;=)</option>
                      <option value="==">Equals (==)</option>
                    </select>
                  </div>

                  <div class="input-group">
                    <label for="rule-value-input" class="input-label">Target Count</label>
                    <input id="rule-value-input" type="number" class="text-input" bind:value={newRuleValue} />
                  </div>

                  <div class="input-group">
                    <label for="rule-action-select" class="input-label">Action</label>
                    <select id="rule-action-select" class="select-input" bind:value={newRuleAction}>
                      <option value="enable">Enable Whitelist</option>
                      <option value="disable">Disable Whitelist</option>
                    </select>
                  </div>
                {:else}
                  <div class="input-group">
                    <label for="rule-start-time" class="input-label">Start Time (HH:MM)</label>
                    <input id="rule-start-time" type="time" class="text-input" bind:value={newRuleStartTime} />
                  </div>
                  <div class="input-group">
                    <label for="rule-end-time" class="input-label">End Time (HH:MM)</label>
                    <input id="rule-end-time" type="time" class="text-input" bind:value={newRuleEndTime} />
                  </div>
                {/if}
              </div>

              <div style="display: flex; gap: 8px; justify-content: flex-end; margin-top: 14px;">
                <button class="btn btn-ghost" onclick={() => (isAddingRule = false)}>Cancel</button>
                <button class="btn btn-success" onclick={addRule}>Confirm Rule</button>
              </div>
            </div>
          {/if}

          <div class="rules-list">
            {#each config.rules as rule, i}
              <div class="rule-card" class:disabled={!rule.enabled}>
                <div class="rule-priority">#{i + 1}</div>
                <div class="rule-info">
                  <div class="rule-title-row">
                    <span class="rule-badge">{rule.type.toUpperCase()}</span>
                    <span class="badge" class:badge-success={rule.enabled} class:badge-danger={!rule.enabled}>
                      {rule.enabled ? 'ACTIVE' : 'MUTED'}
                    </span>
                  </div>
                  <p class="rule-condition">
                    {#if rule.type === 'admin-presence'}
                      When Online Admins {rule.operator} {rule.value} &rarr; <strong>{rule.action?.toUpperCase()}</strong>
                    {:else if rule.type === 'player-count'}
                      When Total Players {rule.operator} {rule.value} &rarr; <strong>{rule.action?.toUpperCase()}</strong>
                    {:else if rule.type === 'scheduled'}
                      Active daily between <strong>{rule.startTime}</strong> and <strong>{rule.endTime}</strong>
                    {/if}
                  </p>
                </div>
                <div class="rule-actions">
                  <button
                    class="btn btn-ghost"
                    onclick={() => toggleRule(i)}
                    title={rule.enabled ? 'Disable' : 'Enable'}
                  >
                    {rule.enabled ? 'Disable' : 'Enable'}
                  </button>
                  <button
                    class="btn btn-danger"
                    onclick={() => removeRule(i)}
                    title="Delete Rule"
                  >
                    Remove
                  </button>
                </div>
              </div>
            {/each}

            {#if config.rules.length === 0}
              <div class="empty-state">
                <p>No dynamic rules configured. The whitelist will adhere strictly to manual state.</p>
              </div>
            {/if}
          </div>

          <div class="footer-actions">
            <button class="btn btn-brand" onclick={saveConfig} disabled={isSaving}>Save Rules</button>
          </div>
        </div>
      {:else if activeTab === 'manage'}
        <div class="card manage-card">
          <h3>Quick Whitelist Management</h3>
          <p class="card-desc">Add or revoke whitelist status for any player using their identifier or ID.</p>

          <div class="manage-form">
            <div class="input-group" style="flex: 2;">
              <label for="manage-identifier-input" class="input-label">Player Identifier (License, Discord, Steam, XBL, FiveM)</label>
              <input
                id="manage-identifier-input"
                type="text"
                placeholder="e.g. license:40charhex, discord:18digits, steam:1100001..."
                class="text-input"
                bind:value={newIdentifier}
              />
            </div>

            <div class="input-group" style="flex: 1;">
              <label for="manage-action-select" class="input-label">Desired Action</label>
              <select id="manage-action-select" class="select-input" bind:value={newAction}>
                <option value="add">Add to Whitelist</option>
                <option value="remove">Remove from Whitelist</option>
              </select>
            </div>

            <button
              class="btn"
              class:btn-success={newAction === 'add'}
              class:btn-danger={newAction === 'remove'}
              style="margin-top: auto; height: 42px;"
              onclick={handleManagePlayer}
            >
              Execute Action
            </button>
          </div>

          <div class="identifier-hints">
            <span class="hint-tag">license:</span>
            <span class="hint-tag">steam:</span>
            <span class="hint-tag">discord:</span>
            <span class="hint-tag">fivem:</span>
            <span class="hint-tag">xbl:</span>
          </div>
        </div>
      {:else if activeTab === 'list'}
        <div class="list-container">
          <div class="list-controls">
            <div class="search-box">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
              </svg>
              <input
                type="text"
                placeholder="Search by player name or identifier..."
                class="search-input"
                bind:value={searchQuery} oninput={handleSearchInput}
              />
            </div>
            <button class="btn btn-secondary" onclick={() => loadEntries()}>Refresh List</button>
          </div>

          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Player Name</th>
                  <th>Status</th>
                  <th>Linked Identifiers</th>
                  <th style="text-align: right;">Actions</th>
                </tr>
              </thead>
              <tbody>
                {#each entries as entry}
                  <tr>
                    <td>#{entry.id}</td>
                    <td class="player-col">
                      <strong>{entry.playerName}</strong>
                    </td>
                    <td>
                      <span class="badge" class:badge-success={isWhitelisted(entry)} class:badge-danger={!isWhitelisted(entry)}>
                        {isWhitelisted(entry) ? 'Whitelisted' : 'Unwhitelisted'}
                      </span>
                    </td>
                    <td>
                      <button
                        class="btn-link"
                        onclick={() => {
                          expandedEntryId = expandedEntryId === entry.id ? null : entry.id
                          sounds.playClick()
                        }}
                      >
                        {entry.identifiers.length} identifier(s) {expandedEntryId === entry.id ? '▲' : '▼'}
                      </button>
                      {#if expandedEntryId === entry.id}
                        <div class="identifiers-dropdown">
                          {#each entry.identifiers as id}
                            <span class="identifier-chip">{id}</span>
                          {/each}
                        </div>
                      {/if}
                    </td>
                    <td style="text-align: right;">
                      <button
                        class="btn btn-ghost btn-sm"
                        onclick={() => toggleStatus(entry)}
                      >
                        {isWhitelisted(entry) ? 'Revoke' : 'Grant'}
                      </button>
                    </td>
                  </tr>
                {/each}

                {#if entries.length === 0}
                  <tr>
                    <td colspan="5" style="text-align: center; padding: 32px; color: var(--color-light);">
                      No matching whitelist records found.
                    </td>
                  </tr>
                {/if}
              </tbody>
            </table>
          </div>

          <div class="pagination">
            <button
                class="btn btn-secondary pagination-btn"
                disabled={currentPage <= 1 || isLoadingEntries}
                onclick={loadPreviousPage}
                aria-label="Previous page"
                title="Previous page"
            >
                ‹
            </button>
          
            <span>
                Page {currentPage} · {entries.length} records
            </span>
          
            <button
                class="btn btn-secondary pagination-btn"
                disabled={!hasMoreEntries || isLoadingEntries}
                onclick={loadNextPage}
                aria-label="Next page"
                title="Next page"
            >
                ›
            </button>
          </div>
        </div>
      {/if}
    </section>

    <!-- Toast Notification -->
    {#if notification}
      <div class="toast toast-{notification.type}">
        {notification.text}
      </div>
    {/if}
  </main>
{/if}

<style>
  .panel-container {
    width: 960px;
    max-width: 95vw;
    height: 680px;
    max-height: 92vh;
    background: rgba(22, 22, 22, 0.94);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: var(--radius-lg);
    box-shadow: 0 24px 60px rgba(0, 0, 0, 0.65), 0 0 0 1px rgba(251, 155, 4, 0.15);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    animation: fadeIn 200ms ease-out;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
  }

  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 28px;
    border-bottom: 1px solid var(--color-mid);
    background: rgba(37, 37, 37, 0.5);
  }

  .header-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .header-emblem {
    width: 48px;
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .header-emblem img {
    width: 48px;
    height: 48px;
    object-fit: contain;
    display: block;
  }
  
  .subtitle {
    font-size: 13px;
    color: var(--color-light);
  }

  .header-right {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .status-indicator {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(0, 0, 0, 0.3);
    padding: 6px 12px;
    border-radius: var(--radius-full);
    border: 1px solid var(--color-mid);
  }

  .status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--color-danger);
  }

  .status-dot.active {
    background: var(--color-success);
    box-shadow: 0 0 8px var(--color-success);
  }

  .status-text {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.5px;
  }

  .close-btn {
    padding: 8px;
    border-radius: 50%;
  }

  .nav-tabs {
    display: flex;
    gap: 6px;
    padding: 10px 28px;
    background: #1a1a1a;
    border-bottom: 1px solid var(--color-mid);
  }

  .tab-btn {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: var(--radius-sm);
    background: transparent;
    border: none;
    color: var(--color-light);
    cursor: pointer;
    font-weight: 500;
    transition: all var(--transition-fast);
  }

  .tab-btn:hover {
    color: var(--color-lightest);
    background: rgba(255, 255, 255, 0.04);
  }

  .tab-btn.active {
    color: #121212;
    background: var(--color-brand);
    font-weight: 600;
  }

  .tab-content {
    flex: 1;
    overflow-y: auto;
    padding: 18px 24px;
    display: flex;
    flex-direction: column;
  }

  .tab-content.no-scroll {
    overflow-y: hidden !important;
  }

  .content-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  .card {
    background: rgba(37, 37, 37, 0.4);
    border: 1px solid var(--color-mid);
    border-radius: var(--radius-md);
    padding: 16px 18px;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .card-desc {
    font-size: 13px;
    color: var(--color-light);
    margin-top: -6px;
  }

  .setting-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 6px 0;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    gap: 12px;
  }

  .setting-info {
    flex: 1;
    min-width: 0;
  }

  .setting-label {
    font-weight: 500;
    font-size: 14px;
  }

  .setting-hint {
    font-size: 12px;
    color: var(--color-light);
  }

  .footer-actions {
    margin-top: 12px;
    padding-top: 0;
    display: flex;
    justify-content: flex-end;
  }

  /* Rules Tab */
  .rules-container {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .rules-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .rule-inputs-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-top: 8px;
  }

  .rules-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 8px;
  }

  .rule-card {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 14px 18px;
    background: rgba(37, 37, 37, 0.5);
    border: 1px solid var(--color-mid);
    border-radius: var(--radius-sm);
    transition: all var(--transition-fast);
  }

  .rule-card.disabled {
    opacity: 0.5;
  }

  .rule-priority {
    font-weight: 700;
    color: var(--color-brand);
    font-size: 16px;
  }

  .rule-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .rule-title-row {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .rule-badge {
    font-size: 11px;
    font-weight: 700;
    color: var(--color-light);
  }

  .rule-actions {
    display: flex;
    gap: 8px;
  }

  /* Quick Manage Tab */
  .manage-card {
    max-width: 700px;
    margin: 20px auto;
  }

  .manage-form {
    display: flex;
    gap: 12px;
    align-items: flex-end;
  }

  .identifier-hints {
    display: flex;
    gap: 8px;
    margin-top: 12px;
  }

  .hint-tag {
    font-size: 12px;
    background: rgba(255, 255, 255, 0.05);
    padding: 4px 8px;
    border-radius: var(--radius-sm);
    color: var(--color-brand);
  }

  /* Database List Tab */
  .list-container {
    display: flex;
    flex-direction: column;
    gap: 16px;
    height: 100%;
  }

  .list-controls {
    display: flex;
    justify-content: space-between;
    gap: 16px;
  }

  .search-box {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 10px;
    background: #1e1e1e;
    border: 1px solid var(--color-mid);
    border-radius: var(--radius-sm);
    padding: 8px 14px;
    color: var(--color-light);
  }

  .search-input {
    flex: 1;
    background: transparent;
    border: none;
    color: var(--color-lightest);
    outline: none;
  }

  .table-wrap {
    flex: 1;
    overflow-y: auto;
    border: 1px solid var(--color-mid);
    border-radius: var(--radius-sm);
    background: rgba(22, 22, 22, 0.5);
  }

  .data-table {
    width: 100%;
    border-collapse: collapse;
    text-align: left;
  }

  .data-table th {
    background: #1f1f1f;
    padding: 12px 16px;
    font-size: 12px;
    text-transform: uppercase;
    color: var(--color-light);
    letter-spacing: 0.5px;
    border-bottom: 1px solid var(--color-mid);
    position: sticky;
    top: 0;
  }

  .data-table td {
    padding: 12px 16px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.04);
  }

  .data-table tr:hover td {
    background: rgba(255, 255, 255, 0.02);
  }

  .btn-link {
    background: transparent;
    border: none;
    color: var(--color-brand);
    cursor: pointer;
    font-size: 13px;
  }

  .identifiers-dropdown {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-top: 8px;
    padding: 8px;
    background: #121212;
    border-radius: var(--radius-sm);
  }

  .identifier-chip {
    font-size: 11px;
    background: var(--color-mid);
    padding: 2px 6px;
    border-radius: 3px;
    font-family: monospace;
  }

  .btn-sm {
    padding: 4px 10px;
    font-size: 12px;
  }

  .empty-state {
    text-align: center;
    padding: 40px;
    color: var(--color-light);
  }

  /* Toast notification */
  .toast {
    position: fixed;
    bottom: 24px;
    right: 24px;
    padding: 10px 18px;
    border-radius: var(--radius-sm);
    font-size: 14px;
    font-weight: 500;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
    animation: slideUp 200ms ease-out;
    z-index: 1000;
  }

  @keyframes slideUp {
    from { opacity: 0; transform: translateY(12px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .toast-success { background: var(--color-success); color: white; }
  .toast-danger { background: var(--color-danger); color: white; }
  .toast-info { background: var(--color-info); color: white; }

 .pagination {
    margin-top: auto;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 24px;
    width: 100%;
    padding-top: 16px;
  }

  .pagination-btn {
      width: 38px;
      height: 38px;
      padding: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      line-height: 1;
  }
</style>
