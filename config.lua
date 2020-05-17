Config                  = {}
Config.Locale           = 'en'

-- [Config.EnableCommands]
-- Enables Commands Such As /char and /chardel
Config.EnableCommands   = true

-- [Config.UseSteamID]
-- Changes the identifiers from Rockstar License To Steam. In order to use this, you will have to have
-- made edits to your ESX in order to use Steam identifiers all around, because new ESX uses Rockstar
-- license. I just made it easier for people that convert to steam identifiers.
Config.UseSteamID       = false 

-- [Config.UseDeferrals]
-- EXPERIMENTAL Character Registration Method. This will allow players to create identities in deferrals
-- before they ever join the server. This still needs time of testing to see what issues that we have
-- in linux servers and windows servers, and which artifacts it will work on, and which artifacts it
-- will not work on. If you don't know a lot about this, I would suggest to set it false for now.
Config.UseDeferrals     = false -- EXPERIMENTAL Character Registration Method.


-- These values are for the second input validation in server/main.lua
Config.MaxNameLength    = 16
Config.MinHeight        = 48
Config.MaxHeight        = 96
Config.LowestYear       = 1900
Config.HighestYear      = 2020

Config.FullCharDelete   = false
Config.EnableDebugging  = false
