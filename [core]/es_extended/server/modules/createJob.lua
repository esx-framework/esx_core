
local NOTIFY_TYPES = {
    INFO = "^5[%s]^7-^6[INFO]^7 %s",
    SUCCESS = "^5[%s]^7-^2[SUCCESS]^7 %s",
    ERROR = "^5[%s]^7-^1[ERROR]^7 %s"
}

local function generateNewJobTable(name, label, grades, jobType)
    local job = ESX.Jobs[name] or { name = name, label = label, type = jobType, grades = {} }
    for _, v in pairs(grades) do
        job.grades[tostring(v.grade)] = { job_name = name, grade = v.grade, name = v.name, label = v.label, salary = v.salary, skin_male = v.skin_male, skin_female = v.skin_female }
    end

    return job
end

local function notify(notifyType,resourceName,message,...)
    local formattedMessage = string.format(message, ...)

    if not NOTIFY_TYPES[notifyType] then
        return print(NOTIFY_TYPES.INFO:format(resourceName,formattedMessage))
    end

    return print(NOTIFY_TYPES[notifyType]:format(resourceName,formattedMessage))
end

--- Create Job at Runtime
--- @param name string
--- @param label string
--- @param grades table
--- @param jobType string
function ESX.CreateJob(name, label, grades, jobType)
    local currentResourceName = GetInvokingResource()
    local success = false

    if not name or name == '' then
        notify("ERROR",currentResourceName, 'Missing argument `name`')
        return success
    end

    if not label or label == '' then
        notify("ERROR",currentResourceName, 'Missing argument `label`')
        return success
    end

    if not grades or not next(grades) then
        notify("ERROR",currentResourceName, 'Missing argument `grades`')
        return success
    end

    if type(jobType) ~= "string" then
        jobType = "civ"
    end

    local existingJob = MySQL.single.await('SELECT `label`, `type` FROM `jobs` WHERE `name` = ?', { name })
    local jobExists = existingJob ~= nil
    local existingGrades = {}

    if jobExists then
        label, jobType = existingJob.label, existingJob.type

        local rows = MySQL.query.await('SELECT `grade` FROM `job_grades` WHERE `job_name` = ?', { name })

        for i = 1, #(rows or {}) do
            existingGrades[tostring(rows[i].grade)] = true
        end
    end

    local queries = {}

    if not jobExists then
        queries[#queries + 1] = {
            query = 'INSERT INTO `jobs` (`name`, `label`, `type`) VALUES (?, ?, ?)',
            values = { name, label, jobType }
        }
    end

    local newGrades = {}

    for _, grade in pairs(grades) do
        if not existingGrades[tostring(grade.grade)] then
            local skinMale = grade.skin_male and json.encode(grade.skin_male) or '{}'
            local skinFemale = grade.skin_female and json.encode(grade.skin_female) or '{}'

            newGrades[#newGrades + 1] = { grade = grade.grade, name = grade.name, label = grade.label, salary = grade.salary, skin_male = skinMale, skin_female = skinFemale }
            queries[#queries + 1] = {
                query = 'INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?)',
                values = { name, grade.grade, grade.name, grade.label, grade.salary, skinMale, skinFemale }
            }
        end
    end

    if not queries[1] then
        notify("ERROR",currentResourceName, 'Job or grades already exists: `%s`', name)
        return success
    end

    success = exports.oxmysql:transaction_async(queries)

    if not success then
        notify("ERROR", currentResourceName, 'Failed to insert one or more grades for job: `%s`', name)
        return success
    end

    ESX.Jobs[name] = generateNewJobTable(name, label, newGrades, jobType)

    notify("SUCCESS", currentResourceName, 'Job created successfully: `%s`', name)

    TriggerEvent('esx:jobCreated', name, ESX.Jobs[name])

    return success
end
