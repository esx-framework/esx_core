Config = {}
Config.Locale = GetConvar("esx:locale", "en")

-- [Config.EnableCommands]
-- Enables Commands Such As /char and /chardel
Config.EnableCommands = ESX.GetConfig().EnableDebug

-- These values are for the date format in the registration menu
-- Choices: DD/MM/YYYY | MM/DD/YYYY | YYYY/MM/DD
Config.DateFormat = "DD/MM/YYYY"

-- These values are for the second input validation in server/main.lua
Config.MaxNameLength = 20 -- Max Name Length.
Config.MinHeight = 120 -- 120 cm lowest height
Config.MaxHeight = 220 -- 220 cm max height.
Config.MaxAge = 100 -- 100 years old is the oldest you can be.

Config.FullCharDelete = true -- Delete all reference to character.
Config.EnableDebugging = ESX.GetConfig().EnableDebug -- prints for debugging :)
