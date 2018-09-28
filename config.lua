Config                          = {}
Config.Locale                   = 'fr'

Config.Accounts                 = { 'bank', 'black_money' }
Config.AccountLabels            = { bank = _U('bank'), black_money = _U('black_money') }

Config.EnableSocietyPayouts     = false -- pay from the society account that the plyayers are employeed at instead of plain giving money. Requirement: esx_society
Config.ShowDotAbovePlayer       = false
Config.DisableWantedLevel       = true
Config.EnableWeaponPickup       = true
Config.EnableHud                = true -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.RemoveInventoryItemDelay = 5 * 60000
Config.PaycheckInterval         = 7 * 60000
Config.MaxPlayers               = 32
Config.EnableDebug              = false
