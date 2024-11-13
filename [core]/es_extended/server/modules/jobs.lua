ESX.Jobs = {}
ESX.JobsPlayerCount = {}

---@param job string
---@param grade string
---@return boolean
function ESX.DoesJobExist(job, grade)
    return (ESX.Jobs[job] and ESX.Jobs[job].grades[tostring(grade)] ~= nil) or false
end

---@return table
function ESX.GetJobs()
    return ESX.Jobs
end

---@return nil
function ESX.RefreshJobs()
    local Jobs = {}
    local jobs = MySQL.query.await("SELECT * FROM jobs")

    for _, v in ipairs(jobs) do
        Jobs[v.name] = v
        Jobs[v.name].grades = {}
    end

    local jobGrades = MySQL.query.await("SELECT * FROM job_grades")

    for _, v in ipairs(jobGrades) do
        if Jobs[v.job_name] then
            Jobs[v.job_name].grades[tostring(v.grade)] = v
        else
            print(('[^3WARNING^7] Ignoring job grades for ^5"%s"^0 due to missing job'):format(v.job_name))
        end
    end

    for _, v in pairs(Jobs) do
        if ESX.Table.SizeOf(v.grades) == 0 then
            Jobs[v.name] = nil
            print(('[^3WARNING^7] Ignoring job ^5"%s"^0 due to no job grades found'):format(v.name))
        end
    end

    if not Jobs then
        -- Fallback data, if no jobs exist
        ESX.Jobs["unemployed"] = { label = "Unemployed", grades = { ["0"] = { grade = 0, label = "Unemployed", salary = 200, skin_male = {}, skin_female = {} } } }
    else
        ESX.Jobs = Jobs
    end
end
