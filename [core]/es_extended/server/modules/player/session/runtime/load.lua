-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local function decodeJsonObject(value, fallback)
    if type(value) == "table" then
        return value
    end

    if type(value) ~= "string" or value == "" then
        return fallback
    end

    local ok, decoded = pcall(json.decode, value)
    if not ok or type(decoded) ~= "table" then
        return fallback
    end

    return decoded
end

function loadESXPlayer(identifier, playerId, isNew, loading)
    if not Core.PlayerSession.IsPlayerLoadActive(playerId, loading) then
        return
    end

    local userData = {
        accounts = {},
        inventory = {},
        loadout = {},
        weight = 0,
        name = GetPlayerName(playerId),
        identifier = identifier,
        firstName = "John",
        lastName = "Doe",
        dateofbirth = "01/01/2000",
        height = 120,
        dead = false,
    }

    local result = MySQL.prepare.await(Core.PlayerSession.loadPlayerQuery, { identifier })

    if not Core.PlayerSession.IsPlayerLoadActive(playerId, loading) then
        return
    end

    if not result then
        print(("[^1ERROR^7] esx_core could not load data for identifier ^5%s^7"):format(identifier))
        return DropPlayer(playerId --[[@as string]], "There was an error loading your character!\nError code: data-load-failed\n\nYour character data could not be retrieved. Please reconnect, and contact the server administration team if this keeps happening.")
    end

    local accounts = (result.accounts and result.accounts ~= "") and json.decode(result.accounts) or {}

    for account, data in pairs(Config.Accounts) do
        data.round = data.round or data.round == nil

        local index = #userData.accounts + 1
        userData.accounts[index] = {
            name = account,
            money = accounts[account] or Config.StartingAccountMoney[account] or 0,
            label = data.label,
            round = data.round,
            index = index,
        }
    end

    userData.ssn = result.ssn

    local job, grade = result.job, tostring(result.job_grade)

    if not ESX.DoesJobExist(job, grade) then
        print(("[^3WARNING^7] Ignoring invalid job for ^5%s^7 [job: ^5%s^7, grade: ^5%s^7]"):format(identifier, job, grade))
        job, grade = "unemployed", "0"
    end

    local jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]

    userData.job = {
        id = jobObject.id,
        name = jobObject.name,
        label = jobObject.label,
        type = jobObject.type,

        grade = tonumber(grade),
        grade_name = gradeObject.name,
        grade_label = gradeObject.label,
        grade_salary = gradeObject.salary,

        skin_male = decodeJsonObject(gradeObject.skin_male, {}),
        skin_female = decodeJsonObject(gradeObject.skin_female, {}),
    }

    if not Config.CustomInventory then
        local inventory = decodeJsonObject(result.inventory, {})

        userData.inventory, userData.weight = Core.PlayerClass.BuildInventory(inventory)
    elseif result.inventory and result.inventory ~= "" then
        userData.inventory = json.decode(result.inventory)
    end

    if result.group then
        if result.group == "superadmin" then
            userData.group = "admin"
            print("[^3WARNING^7] ^5Superadmin^7 detected, setting group to ^5admin^7")
        else
            userData.group = result.group
        end
    else
        userData.group = "user"
    end

    if not Config.CustomInventory and result.loadout and result.loadout ~= "" then
        local loadout = json.decode(result.loadout)
        for name, weapon in pairs(loadout) do
            local found, label = pcall(ESX.GetWeaponLabel, name)

            if found and label then
                userData.loadout[#userData.loadout + 1] = {
                    name = name,
                    ammo = weapon.ammo,
                    label = label,
                    components = weapon.components or {},
                    tintIndex = weapon.tintIndex or 0,
                }
            end
        end
    end

    userData.coords = (result.position and result.position ~= "") and json.decode(result.position) or Config.DefaultSpawns[ESX.Math.Random(1, #Config.DefaultSpawns)]
    userData.skin = decodeJsonObject(result.skin, { sex = result.sex == "f" and 1 or 0 })
    userData.metadata = (result.metadata and result.metadata ~= "") and json.decode(result.metadata) or {}

    local xPlayer = CreateExtendedPlayer(playerId, identifier, userData.ssn, userData.group, userData.accounts, userData.inventory, userData.weight, userData.job, userData.loadout, GetPlayerName(playerId), userData.coords, userData.metadata)

    GlobalState["playerCount"] = (GlobalState["playerCount"] or 0) + 1
    ESX.Players[playerId] = xPlayer
    Core.playersByIdentifier[identifier] = xPlayer

    if result.firstname and result.firstname ~= "" then
        userData.firstName = result.firstname
        userData.lastName = result.lastname

        local name = ("%s %s"):format(result.firstname, result.lastname)
        userData.name = name

        xPlayer.set("firstName", result.firstname)
        xPlayer.set("lastName", result.lastname)
        xPlayer.setName(name)

        if result.dateofbirth then
            userData.dateofbirth = result.dateofbirth
            xPlayer.set("dateofbirth", result.dateofbirth)
        end

        if result.sex then
            userData.sex = result.sex
            xPlayer.set("sex", result.sex)
        end

        if result.height then
            userData.height = result.height
            xPlayer.set("height", result.height)
        end
    end

    TriggerEvent("esx:playerLoaded", playerId, xPlayer, isNew)
    userData.money = xPlayer.getMoney()
    userData.maxWeight = xPlayer.getMaxWeight()
    userData.variables = xPlayer.variables or {}

    if not Config.CustomInventory then
        userData.inventory = xPlayer.getInventory()
        userData.weight = xPlayer.getWeight()
    end

    xPlayer.triggerEvent("esx:playerLoaded", userData, isNew, userData.skin)

    if Config.CustomInventory and setPlayerInventory then
        setPlayerInventory(playerId, xPlayer, userData.inventory, isNew)
    end

    xPlayer.triggerEvent("esx:registerSuggestions", Core.RegisteredCommands)
    print(('[^2INFO^0] Player ^5"%s"^0 has connected to the server. ID: ^5%s^7'):format(xPlayer.getName(), playerId))
end

Core.PlayerSession.LoadESXPlayer = loadESXPlayer
