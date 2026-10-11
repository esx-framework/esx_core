-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@return nil
function ESX.RefreshJobs()
    Core.JobsLoaded = false

    local Jobs = {}
    local jobs = MySQL.query.await("SELECT * FROM jobs") or {}

    for _, v in ipairs(jobs) do
        Jobs[v.name] = v
        Jobs[v.name].grades = {}
    end

    local jobGrades = MySQL.query.await("SELECT * FROM job_grades") or {}

    for _, v in ipairs(jobGrades) do
        if Jobs[v.job_name] then
            Jobs[v.job_name].grades[tostring(v.grade)] = v
        else
            print(('[^3WARNING^7] Ignoring job grades for ^5"%s"^0 due to missing job'):format(v.job_name))
        end
    end

    for _, v in pairs(Jobs) do
        if xLib.table.sizeOf(v.grades) == 0 then
            Jobs[v.name] = nil
            print(('[^3WARNING^7] Ignoring job ^5"%s"^0 due to no job grades found'):format(v.name))
        end
    end

    local unemployed = Jobs["unemployed"]

    if not unemployed then
        unemployed = {
            name = "unemployed",
            label = "Unemployed",
            type = "civ",
            whitelisted = false,
            grades = {},
        }
        Jobs["unemployed"] = unemployed
    end

    if not unemployed.grades["0"] then
        unemployed.grades["0"] = {
            grade = 0,
            name = "unemployed",
            label = "Unemployed",
            salary = 200,
            skin_male = "{}",
            skin_female = "{}",
        }

        print('[^3WARNING^7] Missing unemployed grade 0, using the default fallback')
    end

    ESX.Jobs = Jobs

    TriggerEvent("esx:jobsRefreshed")
    Core.JobsLoaded = true
end

local function removeStaleJob(jobName, reason)
    ESX.Jobs[jobName] = nil
    print(('[^3WARNING^7] Ignoring refresh of job ^5"%s"^0 due to %s'):format(jobName, reason))

    if jobName == "unemployed" or not ESX.DoesJobExist("unemployed", 0) then
        return false
    end

    for _, xPlayer in pairs(ESX.Players) do
        if xPlayer.job.name == jobName then
            xPlayer.setJob("unemployed", 0, false)
        end
    end

    TriggerEvent("esx:jobRemoved", jobName, reason)
    return false
end

---@param jobName string
---@return boolean
function ESX.RefreshJob(jobName)
    if type(jobName) ~= "string" or jobName == "" then
        return false
    end

    local job = MySQL.single.await("SELECT * FROM jobs WHERE name = ?", { jobName })

    if not job then
        return removeStaleJob(jobName, "missing job")
    end

    local jobGrades = MySQL.query.await("SELECT * FROM job_grades WHERE job_name = ?", { jobName })

    if #jobGrades == 0 then
        return removeStaleJob(jobName, "no job grades found")
    end

    job.grades = {}

    for i = 1, #jobGrades do
        job.grades[tostring(jobGrades[i].grade)] = jobGrades[i]
    end

    ESX.Jobs[jobName] = job

    for _, xPlayer in pairs(ESX.Players) do
        if xPlayer.job.name == jobName then
            xPlayer.refreshJob()
        end
    end

    TriggerEvent("esx:jobRefreshed", jobName, job)

    return true
end

---@param jobType string|string[]?
---@return table
function ESX.GetJobs(jobType)
    while not Core.JobsLoaded do
        Citizen.Wait(200)
    end

    if not jobType then
        return ESX.Jobs
    end

    jobType = type(jobType) == "string" and { jobType } or jobType

    local jobTypeLookup = {}
    for i = 1, #jobType do
        jobTypeLookup[jobType[i]] = true
    end

    local filteredJobs = {}
    for jobName, jobObject in pairs(ESX.Jobs) do
        if jobTypeLookup[jobObject.type] then
            filteredJobs[jobName] = jobObject
        end
    end

    return filteredJobs
end

---@param job string
---@param grade string
---@return boolean
function ESX.DoesJobExist(job, grade)
    while not Core.JobsLoaded do
        Citizen.Wait(200)
    end

    return (ESX.Jobs[job] and ESX.Jobs[job].grades[tostring(grade)] ~= nil) or false
end
