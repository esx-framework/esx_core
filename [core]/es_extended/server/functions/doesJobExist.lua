--- @param job string
--- @param grade string
function ESX.DoesJobExist(job, grade)
    grade = tostring(grade)

    if job and grade then
        if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
            return true
        end
    end

    return false
end
