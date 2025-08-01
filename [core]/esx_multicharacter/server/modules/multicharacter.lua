---@diagnostic disable: duplicate-set-field

Multicharacter = {}
Multicharacter._index = Multicharacter
Multicharacter.awaitingRegistration = {}

function Multicharacter:SetupCharacters(source)
    SetPlayerRoutingBucket(source, source)
    while not Database.connected do
        Wait(100)
    end

    local identifier = ESX.GetIdentifier(source)
    ESX.Players[identifier] = source

    local slots = Database:GetPlayerSlots(identifier)
    identifier = Server.prefix .. "%:" .. identifier

    local rawCharacters = Database:GetPlayerInfo(identifier, slots)
    local characters

    if rawCharacters then
        local characterCount = #rawCharacters
        characters = table.create(0, characterCount)

        for i = 1, characterCount, 1 do
            local v = rawCharacters[i]
            local job, grade = v.job or "unemployed", tostring(v.job_grade)

            if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
                if job ~= "unemployed" then
                    grade = ESX.Jobs[job].grades[grade].label
                else
                    grade = ""
                end
                job = ESX.Jobs[job].label
            end

            local accounts = json.decode(v.accounts)
            local idString = string.sub(v.identifier, #Server.prefix + 1, string.find(v.identifier, ":") - 1)
            local id = tonumber(idString)
            if id then
                characters[id] = {
                    id = id,
                    bank = accounts.bank,
                    money = accounts.money,
                    job = job,
                    job_grade = grade,
                    firstname = v.firstname,
                    lastname = v.lastname,
                    dateofbirth = v.dateofbirth,
                    skin = v.skin and json.decode(v.skin) or {},
                    disabled = v.disabled,
                    sex = v.sex == "m" and TranslateCap("male") or TranslateCap("female"),
                }
            end
        end
    end

    TriggerClientEvent("esx_multicharacter:SetupUI", source, characters, slots)
end

function Multicharacter:CharacterChosen(source, charid, isNew)
    if type(charid) ~= "number" or string.len(charid) > 2 or type(isNew) ~= "boolean" then
        return
    end

    if isNew then
        self.awaitingRegistration[source] = charid
    else
        SetPlayerRoutingBucket(source, 0)
        if not ESX.GetConfig().EnableDebug then
            local identifier = ("%s%s:%s"):format(Server.prefix, charid, ESX.GetIdentifier(source))

            if ESX.GetPlayerFromIdentifier(identifier) then
                DropPlayer(source, "[ESX Multicharacter] Your identifier " .. identifier .. " is already on the server!")
                return
            end
        end

        local charIdentifier = ("%s%s"):format(Server.prefix, charid)
        TriggerEvent("esx:onPlayerJoined", source, charIdentifier)
        ESX.Players[ESX.GetIdentifier(source)] = charIdentifier
    end
end

function Multicharacter:RegistrationComplete(source, data)
    local charId = self.awaitingRegistration[source]
    local charIdentifier = ("%s%s"):format(Server.prefix, charId)
    self.awaitingRegistration[source] = nil
    ESX.Players[ESX.GetIdentifier(source)] = charIdentifier

    SetPlayerRoutingBucket(source, 0)
    TriggerEvent("esx:onPlayerJoined", source, charIdentifier, data)
end

function Multicharacter:PlayerDropped(player)
    self.awaitingRegistration[player] = nil
    ESX.Players[ESX.GetIdentifier(player)] = nil
end
