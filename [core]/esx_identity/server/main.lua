local playerIdentity = {}
local alreadyRegistered = {}
local multichar = ESX.GetConfig().Multichar

local function deleteIdentityFromDatabase(xPlayer)
    MySQL.query.await("UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ?, skin = ? WHERE identifier = ?", { nil, nil, nil, nil, nil, nil, xPlayer.identifier })

    if Config.FullCharDelete then
        MySQL.update.await("UPDATE addon_account_data SET money = 0 WHERE account_name IN (?) AND owner = ?", { { "bank_savings", "caution" }, xPlayer.identifier })

        MySQL.prepare.await("UPDATE datastore_data SET data = ? WHERE name IN (?) AND owner = ?", { "'{}'", { "user_ears", "user_glasses", "user_helmet", "user_mask" }, xPlayer.identifier })
    end
end

---@param xPlayer StaticPlayer|xPlayer
---@param data {firstName:string?, lastName:string?, dateOfBirth:string?, height:number?, sex:"m"|"f"?}
function SetPlayerData(xPlayer, data)
    local name = ("%s %s"):format(data.firstName, data.lastName)
    xPlayer.setName(name)
    xPlayer.set("firstName", data.firstName)
    xPlayer.set("lastName", data.lastName)
    xPlayer.set("dateofbirth", data.dateOfBirth)
    xPlayer.set("sex", data.sex)
    xPlayer.set("height", data.height)

    local state = Player(xPlayer.getSource()).state
    state:set("name", name, true)
    state:set("firstName", data.firstName, true)
    state:set("lastName", data.lastName, true)
    state:set("dateofbirth", data.dateOfBirth, true)
    state:set("sex", data.sex, true)
    state:set("height", data.height, true)
end

---@param xPlayer xPlayer
local function deleteIdentity(xPlayer)
    if not alreadyRegistered[xPlayer.identifier] then
        return
    end

    SetPlayerData(xPlayer, { firstName = nil, lastName = nil, dateOfBirth = nil, sex = nil, height = nil })
    deleteIdentityFromDatabase(xPlayer)
end


local function saveIdentityToDatabase(identifier, identity)
    MySQL.update.await("UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ? WHERE identifier = ?", { identity.firstName, identity.lastName, identity.dateOfBirth, identity.sex, identity.height, identifier })
end

---@param year number Year
---@return boolean: true if the year is a leap year, false otherwise
local function isLeapYear(year)
    return (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
end

---@param dob string Date of Birth in the format DD/MM/YYYY
---@return boolean: true if the date is valid, false otherwise
local function checkDOBFormat(dob)
    dob = tostring(dob)

    local dayStr, monthStr, yearStr = dob:match("^(%d%d?)/(%d%d?)/(%d%d%d%d)$")
    if not dayStr or not monthStr or not yearStr then
        return false
    end

    local day, month, year = tonumber(dayStr), tonumber(monthStr), tonumber(yearStr)
    if not day or not month or not year then
        return false
    end

    local currentYear = os.date("*t").year
    local minYear = currentYear - Config.MaxAge
    local maxYear = currentYear - 18

    if year < minYear or year > maxYear then return false end
    if month < 1 or month > 12 then return false end

    -- Days in each month (starting from January.)
    local daysInMonth = { 31, isLeapYear(year) and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    return day >= 1 and day <= daysInMonth[month]
end

local function formatDate(str)
    local d, m, y = string.match(str, "(%d+)/(%d+)/(%d+)")
    local date = str

    if Config.DateFormat == "MM/DD/YYYY" then
        date = m .. "/" .. d .. "/" .. y
    elseif Config.DateFormat == "YYYY/MM/DD" then
        date = y .. "/" .. m .. "/" .. d
    end

    return date
end

local function checkNameFormat(name)
    if ESX.IsValidLocaleString(name) then
        local stringLength = string.len(name)
        return stringLength > 0 and stringLength < Config.MaxNameLength
    end

    return false
end

local function checkSexFormat(sex)
    if not sex then
        return false
    end
    return sex == "m" or sex == "M" or sex == "f" or sex == "F"
end

local function checkHeightFormat(height)
    local numHeight = tonumber(height) or 0
    return numHeight >= Config.MinHeight and numHeight <= Config.MaxHeight
end

local function convertToLowerCase(str)
    return string.lower(str)
end

local function convertFirstLetterToUpper(str)
    return str:gsub("^%l", string.upper)
end

local function formatName(name)
    local loweredName = convertToLowerCase(name)
    return convertFirstLetterToUpper(loweredName)
end

---@param xPlayer StaticPlayer
local function setIdentity(xPlayer)
    local playerIdentifier = xPlayer.getIdentifier()
    if not alreadyRegistered[playerIdentifier] then
        return
    end
    local currentIdentity = playerIdentity[playerIdentifier]
    SetPlayerData(xPlayer, currentIdentity)

    TriggerClientEvent("esx_identity:setPlayerData", xPlayer.src, currentIdentity)
    if currentIdentity.saveToDatabase then
        saveIdentityToDatabase(playerIdentifier, currentIdentity)
    end

    playerIdentity[playerIdentifier] = nil
end

---@param xPlayer StaticPlayer
local function checkIdentity(xPlayer)
    local playerIdentifier = xPlayer.getIdentifier()
    MySQL.single("SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?", { playerIdentifier }, function(result)
        if not result then
            return TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.src)
        end
        if not result.firstname then
            playerIdentity[playerIdentifier] = nil
            alreadyRegistered[playerIdentifier] = false
            return TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.src)
        end

        playerIdentity[playerIdentifier] = {
            firstName = result.firstname,
            lastName = result.lastname,
            dateOfBirth = result.dateofbirth,
            sex = result.sex,
            height = result.height,
        }

        alreadyRegistered[playerIdentifier] = true
        setIdentity(xPlayer)
    end)
end

if not multichar then
    AddEventHandler("playerConnecting", function(_, _, deferrals)
        deferrals.defer()
        local _, identifier = source, nil

        local correctLicense, _ = pcall(function()
            identifier = ESX.GetIdentifier(source)
        end)

        Wait(40)

        if not identifier or not correctLicense then
            return deferrals.done(TranslateCap("no_identifier"))
        end
        MySQL.single("SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?", { identifier }, function(result)
            if not result then
                playerIdentity[identifier] = nil
                alreadyRegistered[identifier] = false
                return deferrals.done()
            end
            if not result.firstname then
                playerIdentity[identifier] = nil
                alreadyRegistered[identifier] = false
                return deferrals.done()
            end

            playerIdentity[identifier] = {
                firstName = result.firstname,
                lastName = result.lastname,
                dateOfBirth = result.dateofbirth,
                sex = result.sex,
                height = result.height,
            }

            alreadyRegistered[identifier] = true

            deferrals.done()
        end)
    end)

    AddEventHandler("onResourceStart", function(resource)
        if resource ~= GetCurrentResourceName() then
            return
        end
        Wait(300)

        while not ESX do
            Wait(0)
        end

        local xPlayers = ESX.ExtendedPlayers() --[=[@as StaticPlayer[]]=]

        for i = 1, #xPlayers do
            if xPlayers[i] then
                checkIdentity(xPlayers[i])
            end
        end
    end)

    RegisterNetEvent("esx:playerLoaded", function(_, xPlayer)
        local currentIdentity = playerIdentity[xPlayer.identifier]

        if currentIdentity and alreadyRegistered[xPlayer.identifier] then
            SetPlayerData(xPlayer, currentIdentity)

            TriggerClientEvent("esx_identity:setPlayerData", xPlayer.source, currentIdentity)
            if currentIdentity.saveToDatabase then
                saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
            end

            Wait(0)

            TriggerClientEvent("esx_identity:alreadyRegistered", xPlayer.source)

            playerIdentity[xPlayer.identifier] = nil
        else
            TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.source)
        end
    end)
end

ESX.RegisterServerCallback("esx_identity:registerIdentity", function(source, cb, data)
    local xPlayer = ESX.Player(source)

    if not checkNameFormat(data.firstname) then
        TriggerClientEvent("esx:showNotification", source, TranslateCap("invalid_firstname_format"), "error")
        return cb(false)
    end
    if not checkNameFormat(data.lastname) then
        TriggerClientEvent("esx:showNotification", source, TranslateCap("invalid_lastname_format"), "error")
        return cb(false)
    end
    if not checkSexFormat(data.sex) then
        TriggerClientEvent("esx:showNotification", source, TranslateCap("invalid_sex_format"), "error")
        return cb(false)
    end
    if not checkDOBFormat(data.dateofbirth) then
        TriggerClientEvent("esx:showNotification", source, TranslateCap("invalid_dob_format"), "error")
        return cb(false)
    end
    if not checkHeightFormat(data.height) then
        TriggerClientEvent("esx:showNotification", source, TranslateCap("invalid_height_format"), "error")
        return cb(false)
    end

    if xPlayer then
        local identifier = xPlayer.getIdentifier()
        if alreadyRegistered[identifier] then
            xPlayer.showNotification(TranslateCap("already_registered"), "error")
            return cb(false)
        end

        playerIdentity[identifier] = {
            firstName = formatName(data.firstname),
            lastName = formatName(data.lastname),
            dateOfBirth = formatDate(data.dateofbirth),
            sex = data.sex,
            height = data.height,
        }

        local currentIdentity = playerIdentity[identifier]

        SetPlayerData(xPlayer, currentIdentity)

        TriggerClientEvent("esx_identity:setPlayerData", xPlayer.src, currentIdentity)
        saveIdentityToDatabase(identifier, currentIdentity)
        alreadyRegistered[identifier] = true
        playerIdentity[identifier] = nil
        return cb(true)
    end

    if not multichar then
        TriggerClientEvent("esx:showNotification", source, TranslateCap("data_incorrect"), "error")
        return cb(false)
    end

    local formattedFirstName = formatName(data.firstname)
    local formattedLastName = formatName(data.lastname)
    local formattedDate = formatDate(data.dateofbirth)

    data.firstname = formattedFirstName
    data.lastname = formattedLastName
    data.dateofbirth = formattedDate
    local Identity = {
        firstName = formattedFirstName,
        lastName = formattedLastName,
        dateOfBirth = formattedDate,
        sex = data.sex,
        height = data.height,
    }

    TriggerEvent("esx_identity:completedRegistration", source, data)
    TriggerClientEvent("esx_identity:setPlayerData", source, Identity)
    cb(true)
end)

if Config.EnableCommands then
    ESX.RegisterCommand("char", "user", function(xPlayer)
        if xPlayer and xPlayer.getName() then
            xPlayer.showNotification(TranslateCap("active_character", xPlayer.getName()))
        else
            xPlayer.showNotification(TranslateCap("error_active_character"))
        end
    end, false, { help = TranslateCap("show_active_character") })

    ESX.RegisterCommand("chardel", "user", function(xPlayer)
        if xPlayer and xPlayer.getName() then
            local identifier = xPlayer.getIdentifier()
            if Config.UseDeferrals then
                xPlayer.kick(TranslateCap("deleted_identity"))
                Wait(1500)
                deleteIdentity(xPlayer)
                xPlayer.showNotification(TranslateCap("deleted_character"))
                playerIdentity[identifier] = nil
                alreadyRegistered[identifier] = false
            else
                deleteIdentity(xPlayer)
                xPlayer.showNotification(TranslateCap("deleted_character"))
                playerIdentity[identifier] = nil
                alreadyRegistered[identifier] = false
                TriggerClientEvent("esx_identity:showRegisterIdentity", xPlayer.source)
            end
        else
            xPlayer.showNotification(TranslateCap("error_delete_character"))
        end
    end, false, { help = TranslateCap("delete_character") })
end

if Config.EnableDebugging then
    ESX.RegisterCommand("xPlayerGetFirstName", "user", function(xPlayer)
        if xPlayer and xPlayer.get("firstName") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_first_name", xPlayer.get("firstName")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_first_name"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_first_name") })

    ESX.RegisterCommand("xPlayerGetLastName", "user", function(xPlayer)
        if xPlayer and xPlayer.get("lastName") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_last_name", xPlayer.get("lastName")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_last_name"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_last_name") })

    ESX.RegisterCommand("xPlayerGetFullName", "user", function(xPlayer)
        if xPlayer and xPlayer.getName() then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_full_name", xPlayer.getName()))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_full_name"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_full_name") })

    ESX.RegisterCommand("xPlayerGetSex", "user", function(xPlayer)
        if xPlayer and xPlayer.get("sex") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_sex", xPlayer.get("sex")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_sex"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_sex") })

    ESX.RegisterCommand("xPlayerGetDOB", "user", function(xPlayer)
        if xPlayer and xPlayer.get("dateofbirth") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_dob", xPlayer.get("dateofbirth")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_dob"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_dob") })

    ESX.RegisterCommand("xPlayerGetHeight", "user", function(xPlayer)
        if xPlayer and xPlayer.get("height") then
            xPlayer.showNotification(TranslateCap("return_debug_xPlayer_get_height", xPlayer.get("height")))
        else
            xPlayer.showNotification(TranslateCap("error_debug_xPlayer_get_height"))
        end
    end, false, { help = TranslateCap("debug_xPlayer_get_height") })
end
