-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@diagnostic disable: duplicate-set-field

Multicharacter = {}
Multicharacter._index = Multicharacter
Multicharacter.awaitingRegistration = {}
Multicharacter.sessions = {}
local setupLimiter = xLib.rateLimiter({ capacity = 1, refill = 1, interval = 5000 })
local actionLimiter = xLib.rateLimiter({ capacity = 2, refill = 1, interval = 2000 })

local function isCurrent(source, session)
    return Multicharacter.sessions[source] == session
        and ESX.GetIdentifier(source) == session.identifier
        and not ESX.GetPlayerFromId(source)
end

local function normalizeCharacterSlot(charid)
    charid = tonumber(charid)

    if not charid or charid ~= charid or charid == math.huge or charid < 1 or charid ~= math.floor(charid) then
        return nil
    end

    return charid
end

local function isCharacterDisabled(character)
    return character and (character.disabled == true or character.disabled == 1 or character.disabled == "1")
end

local function loadCharacters(self, source, session)
    local deadline = GetGameTimer() + 15000

    while not Database.connected do
        if not isCurrent(source, session) or GetGameTimer() >= deadline then return false end
        Wait(100)
    end

    if not isCurrent(source, session) then return false end
    local identifier = session.identifier

    local slots = tonumber(Database:GetPlayerSlots(identifier)) or tonumber(Server.slots) or 1
    if slots ~= slots or slots == math.huge or slots == -math.huge then slots = 1 end
    slots = math.max(1, math.min(100, math.floor(slots)))

    if not isCurrent(source, session) then return false end
    local rawCharacters = Database:GetPlayerInfo(identifier, slots)
    if not isCurrent(source, session) then return false end

    local characters = {}

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

    self.awaitingRegistration[source] = nil
    session.slots = slots
    session.characters = characters
    session.phase = 'ready'
    ESX.Players[identifier] = source
    SetPlayerRoutingBucket(source, source)
    TriggerClientEvent("esx_multicharacter:SetupUI", source, characters, slots)
    return true
end

function Multicharacter:SetupCharacters(source, refreshSession)
    local closing = self.sessions[source]
    if closing and closing.phase == 'logout' and closing.identifier == ESX.GetIdentifier(source) then
        closing.setupRequested = true
        return false
    end

    if ESX.GetPlayerFromId(source) then return false end

    if refreshSession then
        if not isCurrent(source, refreshSession) or refreshSession.phase ~= 'deleting' then return false end
    elseif self.sessions[source] or not setupLimiter:consume(source) then
        return false
    end

    local identifier = ESX.GetIdentifier(source)
    if type(identifier) ~= 'string' or identifier == '' then return false end

    local session = { identifier = identifier, phase = 'loading' }
    self.sessions[source] = session
    local ok, ready = pcall(loadCharacters, self, source, session)

    if not ok or not ready then
        if self.sessions[source] == session then self.sessions[source] = nil end
        if not ok then print(('[esx_multicharacter] Setup failed: %s'):format(tostring(ready))) end
        return false
    end
    return true
end

function Multicharacter:CharacterChosen(source, charid, isNew)
    charid = normalizeCharacterSlot(charid)

    if not charid or type(isNew) ~= "boolean" then
        return
    end

    local identifier = ESX.GetIdentifier(source)
    local session = self.sessions[source]

    if not identifier or not session or session.phase ~= 'ready' or not isCurrent(source, session)
        or charid > session.slots or not actionLimiter:consume(source) then
        return
    end

    local character = session.characters and session.characters[charid]
    session.phase = 'choosing'

    local ok, databaseCharacter = pcall(Database.GetCharacter, Database, identifier, charid)
    if not isCurrent(source, session) then return end
    session.phase = 'ready'

    if not ok then return end

    if isNew then
        if character or databaseCharacter then
            return
        end

        session.phase = 'registering'
        self.awaitingRegistration[source] = charid
    else
        if not character or not databaseCharacter or isCharacterDisabled(character) or isCharacterDisabled(databaseCharacter) then
            return
        end

        SetPlayerRoutingBucket(source, 0)
        if not ESX.GetConfig().EnableDebug then
            local identifier = ("%s%s:%s"):format(Server.prefix, charid, ESX.GetIdentifier(source))

            if ESX.GetPlayerFromIdentifier(identifier) then
                DropPlayer(source, "[ESX Multicharacter] Your identifier " .. identifier .. " is already on the server!")
                return
            end
        end

        local charIdentifier = ("%s%s"):format(Server.prefix, charid)
        session.phase = 'joining'
        ESX.Players[identifier] = charIdentifier
        TriggerEvent("esx:onPlayerJoined", source, charIdentifier)
    end
end

function Multicharacter:RegistrationComplete(source, data)
    local charId = normalizeCharacterSlot(self.awaitingRegistration[source])
    local identifier = ESX.GetIdentifier(source)
    local session = self.sessions[source]

    self.awaitingRegistration[source] = nil

    if not charId or not identifier or not session or session.phase ~= 'registering' or not isCurrent(source, session)
        or charId > session.slots or session.characters[charId] then
        return
    end

    session.phase = 'joining'

    local ok, existing = pcall(Database.GetCharacter, Database, identifier, charId)
    if not ok or existing or not isCurrent(source, session) then
        if self.sessions[source] == session then self.sessions[source] = nil end
        return
    end
    local charIdentifier = ("%s%s"):format(Server.prefix, charId)
    ESX.Players[ESX.GetIdentifier(source)] = charIdentifier

    SetPlayerRoutingBucket(source, 0)
    TriggerEvent("esx:onPlayerJoined", source, charIdentifier, data)
end

function Multicharacter:DeleteCharacter(source, charid)
    if not Config.CanDelete then
        return
    end

    charid = normalizeCharacterSlot(charid)

    local identifier = ESX.GetIdentifier(source)
    local session = self.sessions[source]

    if not charid or not identifier or not session or session.phase ~= 'ready' or not isCurrent(source, session)
        or charid > session.slots or not session.characters[charid] or not actionLimiter:consume(source) then
        return
    end

    session.phase = 'deleting'
    local ok, err = pcall(Database.DeleteCharacter, Database, source, charid, session)
    if not ok and self.sessions[source] == session then
        session.phase = 'ready'
        print(('[esx_multicharacter] Delete failed: %s'):format(tostring(err)))
    end
end

function Multicharacter:PlayerDropped(player)
    self.awaitingRegistration[player] = nil
    self.sessions[player] = nil

    local identifier = ESX.GetIdentifier(player)
    if identifier then ESX.Players[identifier] = nil end

    setupLimiter:reset(player)
    actionLimiter:reset(player)
end

function Multicharacter:Relog(source)
    if not Config.Relog or self.sessions[source] or not ESX.GetPlayerFromId(source)
        or not actionLimiter:consume(source) then return end

    local session = { identifier = ESX.GetIdentifier(source), phase = 'logout' }
    self.sessions[source] = session
    
    TriggerEvent('esx:playerLogout', source, function()
        if self.sessions[source] == session then
            self.sessions[source] = nil
            if session.setupRequested then self:SetupCharacters(source) end
        end
    end)
end

AddEventHandler('esx:playerLoaded', function(playerId)
    Multicharacter.sessions[playerId] = nil
    Multicharacter.awaitingRegistration[playerId] = nil
end)
