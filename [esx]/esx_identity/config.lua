-- Default esx_identity Config
Config                  = {}
Config.Locale           = 'en'

-- [Config.EnableCommands]
-- Enables Commands Such As /char and /chardel
Config.EnableCommands   = false

Config.UseDeferrals     = false -- EXPERIMENTAL Character Registration Method.

-- These values are for the second input validation in server/main.lua
Config.MaxNameLength    = 16
Config.MinHeight        = 120
Config.MaxHeight        = 200
Config.LowestYear       = 1950
Config.HighestYear      = 2003

Config.FullCharDelete   = false
Config.EnableDebugging  = false

-- UI Config
Config.UI = {
    ["mainColor"] = "#2277FA",
    ["logo"] = "https://cdn.discordapp.com/attachments/835927155586236457/987828856469745674/cloud.png",
    ["warning"] = "https://media.discordapp.net/attachments/835927155586236457/987828855999963206/warning.png",
    ["ok"] = "https://cdn.discordapp.com/attachments/835927155586236457/987828855597334548/ok.png",
    ["linkicon1"] = "https://cdn.discordapp.com/attachments/835927155586236457/987828855794438154/ts.png",
    ["linkicon2"] = "https://cdn.discordapp.com/attachments/835927155586236457/987828856679464990/discord.png",
    ["linkicon3"] = "https://cdn.discordapp.com/attachments/835927155586236457/987828856247418920/web.png",
    ["link1"] = "behance.net/Vasili_Husak",
    ["link2"] = "discord.gg/mthzDPZG",
    ["link3"] = "DasteX #5802",
    ["clicktocopy"] = "Click to copy",
    ["titletext"] = "Character<br>registration",
    ["firstnameplaceholder"] = "Firstname",
    ["lastnameplaceholder"] = "Lastname",
    ["dateofbirthplaceholder"] = "Date of Birth",
    ["maxchars"] = "Max 16 characters",
    ["createtext"] = "Create a character",
    ["pleasefillin"] = "Please fill in this field",
    ["firstcapitalized"] = "The first letter must be capitalized",
    ["lastnamewhitespace"] = "The last name must not contain spaces",
    ["lastnamespecialchar"] = "The last name must not contain special characters",
    ["lastnamenumbers"] = "The last name must not contain numbers",
    ["lastname3letters"] = "The last name must contain at least 3 letters",
    ["firstnamewhitespace"] = "The first name must not contain spaces",
    ["firstnamespecialchar"] = "The first name must not contain special characters",
    ["firstnamenumbers"] = "The first name must not contain numbers",
    ["firstname3letters"] = "The first name must contain at least 3 letters",
    ["dateofbirthspecialchar"] = "The date of birth must not contain special characters",
    ["dateofbirthwhitespace"] = "The date of birth must not contain spaces",
    ["dateofbirthletters"] = "The date of birth must not contain letters",
    ["dateofbirthformat"] = "Please pay attention to the format! (DD/MM/YYYY)",
    ["dateofbirthday"] = "Please pay attention to the format! (DD/MM/YYYY). Please pay attention to the day in this case!",
    ["dateofbirthmonth"] = "Please pay attention to the format! (DD/MM/YYYY). Please pay attention to the month in this case!",
    ["dateofbirthyear"] = "Please pay attention to the format! (DD/MM/YYYY). Please pay attention to the year in this case!",
    ["infotitle"] = "lorem Ipsum is simply",
    ["infotext"] = "orem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been",
    ["height"] = "height"
}