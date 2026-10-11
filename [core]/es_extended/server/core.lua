-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core = {}
Core.JobsPlayerCount = {}
Core.UsableItemsCallbacks = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0
Core.PlayerFunctionOverrides = {}
Core.DatabaseConnected = false
Core.playersByIdentifier = {}
Core.JobsLoaded = false

---@type table<string, CVehicleData>
Core.vehicles = {}
Core.vehicleTypesByModel = {}