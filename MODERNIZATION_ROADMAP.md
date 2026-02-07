# MODERNIZATION ROADMAP: Project "Total Root"
**Target Repository:** `shadowcoder8/esx_core`  
**Architect:** Sovereign Multi-Agent Engineering Team  
**Objective:** Full-State Bag Migration, O(1) Optimization, and Network Silence.

---

## 📅 Phase 1: Core State Bag Migration & The Local Bridge
**Goal:** Move all Player Data (Job, Money, Inventory) to `StateBags` and create the "Emulator" to support legacy scripts.

### 1.1 The Global vs. Local State Strategy
| Data Point | State Scope | Reason |
| :--- | :--- | :--- |
| **Job / Grade** | `GlobalState` (Mapped) | Allows "Online Police Count" without iterating players. |
| **Cash / Bank** | `LocalPlayer.state` (Private) | Security. Only the owner needs to see this. |
| **Inventory** | `LocalPlayer.state` (Private) | Large table data. Only sync to owner. |
| **Skin / Appearance**| `GlobalState` (Replicated) | All clients must see your character's clothes. |
| **Position** | Native `CNetGamePlayer` | Handled by OneSync. No manual sync needed. |

### 1.2 The "Emulator" (Compatibility Bridge)
**Location:** `es_extended/client/modules/bridge.lua`
We will NOT break 3rd party scripts. We will implement a `StateBagChangeHandler` that listens for changes and fires the old events locally.

**Logic Flow:**
1. **Server:** `Player(src).state:set('job', newJob, true)`
2. **Client Bridge:** 
   ```lua
   AddStateBagChangeHandler('job', nil, function(bagName, key, value)
       -- FIRES LOCALLY for legacy script compatibility
       TriggerEvent('esx:setJob', value) 
   end)
   ```
3. **Legacy Script:** Receives `esx:setJob` and works normally.

### 1.3 O(N) Inventory Refactor
**Current Legacy:** `table.insert` (Array) -> O(N) Lookup time.
**New Standard:** Hash Map (Key-Value).
```lua
-- OLD (Bad)
Inventory = { {name = "bread", count = 1}, {name = "water", count = 1} } 

-- NEW (O(1) Lookup)
Inventory = { ["bread"] = 1, ["water"] = 1 }
```
*Requirement:* All loop-based item checks in `es_extended` must be replaced with direct Key lookups.

---

## 💾 Phase 2: Database Dirty-Write Caching (Lazy Saving)
**Goal:** Eliminate "Save on Transaction". Reduce SQL IO by 90%.

### 2.1 The "Dirty" Flag System
Instead of running `MySQL.update` every time a player buys bread:
1. `xPlayer.addInventoryItem` updates memory & sets `self.isDirty = true`.
2. **Global Ticker** (Every 5-10 minutes) scans for dirty players.
3. Batch saves all dirty players to SQL.
4. Force Save on `PlayerDropped`.

---

## 🎨 Phase 3: UI Modernization (React/Svelte)
**Goal:** Decouple UI from NUI Callbacks and bind directly to State Bags.

### 3.1 Reactive HUD
- **Old:** Server triggers `esx_status:update` event -> Client NUI message.
- **New:** UI Component subscribes to `useData(LocalPlayer.state.hunger)`.
- **Result:** Zero network events for HUD updates.

### 3.2 Inventory UI
- Rewrite `esx_inventory` JS to handle the new Hash Map data structure.

---

## 🧹 Phase 4: Root-wide Event Cleanup
**Goal:** The Great Purge.

### 4.1 Delete Legacy Network Events
Scan and REMOVE the following server-side event handlers after Phase 1 verification:
- `esx:setJob` (Server-side handler)
- `esx:setAccountMoney`
- `esx:addInventoryItem`
- `esx:playerLoaded` (Replace with `playerSpawned` + State Bag Ready check)

### 4.2 fxmanifest.lua Audit
Force update all manifests to:
- `fx_version 'cerulean'` (or `granite`)
- `lua54 'yes'`

---

## 🛡️ QA & Validation Standards
1. **The "Police Count" Test:** Can we get the number of online police WITHOUT looping through `GetPlayers()`?
2. **The "Spam Click" Test:** Does spamming inventory use cause SQL lag? (Should be 0 SQL queries).
3. **The "Legacy Job" Test:** Does `esx_policejob` (legacy) still work via the Bridge?
