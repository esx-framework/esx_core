-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

local function copyJob(job)
    local copiedJob = {}

    for key, value in pairs(job) do
        copiedJob[key] = value
    end

    return copiedJob
end

local function decodeJobSkin(value)
    if type(value) == "table" then
        return value
    end

    if type(value) ~= "string" or value == "" then
        return {}
    end

    local ok, decoded = pcall(json.decode, value)
    if not ok or type(decoded) ~= "table" then
        return {}
    end

    return decoded
end

function Core.PlayerClass.AttachJob(self)
    function self.getJob()
        return self.job
    end

    function self.setJob(newJob, grade, onDuty)
        grade = tostring(grade)
        local lastJob = self.job

        if not ESX.DoesJobExist(newJob, grade) then
            return print(("[ESX] [^3WARNING^7] Ignoring invalid ^5.setJob()^7 usage for ID: ^5%s^7, Job: ^5%s^7"):format(self.source, newJob))
        end

        if newJob == "unemployed" then
            onDuty = false
        end

        if type(onDuty) ~= "boolean" then
            onDuty = Config.DefaultJobDuty
        end

        local jobObject, gradeObject = ESX.Jobs[newJob], ESX.Jobs[newJob].grades[grade]

        self.job = {
            id = jobObject.id,
            name = jobObject.name,
            label = jobObject.label,
            type = jobObject.type,
            onDuty = onDuty,

            grade = tonumber(grade) or 0,
            grade_name = gradeObject.name,
            grade_label = gradeObject.label,
            grade_salary = gradeObject.salary,

            skin_male = decodeJobSkin(gradeObject.skin_male),
            skin_female = decodeJobSkin(gradeObject.skin_female),
        }

        self.metadata.jobDuty = onDuty
        TriggerEvent("esx:setJob", self.source, self.job, lastJob)
        self.triggerEvent("esx:setJob", self.job, lastJob)
        Player(self.source).state:set("job", self.job, true)
    end

    function self.refreshJob()
        local jobObject = ESX.Jobs[self.job.name]
        local gradeObject = jobObject and jobObject.grades[tostring(self.job.grade)]

        if not gradeObject then
            self.setJob("unemployed", 0, false)
            return false
        end

        local lastJob = copyJob(self.job)

        self.job = {
            id = jobObject.id,
            name = jobObject.name,
            label = jobObject.label,
            type = jobObject.type,
            onDuty = lastJob.onDuty,

            grade = lastJob.grade,
            grade_name = gradeObject.name,
            grade_label = gradeObject.label,
            grade_salary = gradeObject.salary,

            skin_male = decodeJobSkin(gradeObject.skin_male),
            skin_female = decodeJobSkin(gradeObject.skin_female),
        }

        TriggerEvent("esx:jobDataRefreshed", self.source, self.job, lastJob)
        self.triggerEvent("esx:jobDataRefreshed", self.job, lastJob)
        Player(self.source).state:set("job", self.job, true)

        return true
    end

end
