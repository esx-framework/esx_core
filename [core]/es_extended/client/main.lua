-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core = {}
Core.Input = {}
Core.Events = {}

ESX.PlayerData = {}
ESX.PlayerLoaded = false
ESX.playerId = PlayerId()
ESX.serverId = GetPlayerServerId(ESX.playerId)

ESX.UI = {}
ESX.UI.Menu = {}
ESX.UI.Menu.RegisteredTypes = {}
ESX.UI.Menu.Opened = {}

ESX.Game = {}
ESX.Game.Utils = {}
