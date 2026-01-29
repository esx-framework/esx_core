local Callback = {}

local function validateRegistrationData(source, data)
    local validationRules = {
        { Modules.Validation.CheckNameFormat(data.firstname), "invalid_firstname_format" },
        { Modules.Validation.CheckNameFormat(data.lastname), "invalid_lastname_format" },
        { Modules.Validation.CheckSexFormat(data.sex), "invalid_sex_format" },
        { Modules.Validation.CheckDOBFormat(data.dateofbirth), "invalid_dob_format" },
        { Modules.Validation.CheckHeightFormat(data.height), "invalid_height_format" },
    }

    for _, rule in ipairs(validationRules) do
        if not rule[1] then
            Modules.Identity.SendNotification(source, rule[2])
            return false, rule[2]
        end
    end

    return true
end

function Callback.RegisterIdentity(source, cb, data)
    local xPlayer = ESX.Player(source)

    local isValid, errorKey = validateRegistrationData(source, data)
    if not isValid then
        return cb(false)
    end

    if xPlayer then
        local identifier = xPlayer.getIdentifier()
        if Modules.Identity.IsRegistered(identifier) then
            xPlayer.showNotification(TranslateCap("already_registered"), "error")
            return cb(false)
        end

        local formattedIdentity = {
            firstName = Modules.Util.FormatName(data.firstname),
            lastName = Modules.Util.FormatName(data.lastname),
            dateOfBirth = Modules.Util.FormatDate(data.dateofbirth),
            sex = data.sex,
            height = data.height,
        }

        Modules.Identity.SetPlayerData(xPlayer, formattedIdentity)
        TriggerClientEvent("esx_identity:setPlayerData", xPlayer.src, formattedIdentity)
        Modules.Database.SaveIdentity(identifier, formattedIdentity)
        Modules.Identity.MarkAsRegistered(identifier)
        Modules.Identity.ClearPlayerIdentity(identifier)
        return cb(true)
    end

    if not Modules.Multichar.IsEnabled() then
        Modules.Identity.SendNotification(source, "data_incorrect")
        return cb(false)
    end

    local formattedIdentity = {
        firstName = Modules.Util.FormatName(data.firstname),
        lastName = Modules.Util.FormatName(data.lastname),
        dateOfBirth = Modules.Util.FormatDate(data.dateofbirth),
        sex = data.sex,
        height = data.height,
    }

    data.firstname = formattedIdentity.firstName
    data.lastname = formattedIdentity.lastName
    data.dateofbirth = formattedIdentity.dateOfBirth

    TriggerEvent("esx_identity:completedRegistration", source, data)
    TriggerClientEvent("esx_identity:setPlayerData", source, formattedIdentity)
    cb(true)
end

Modules.Callback = Callback
return Callback

