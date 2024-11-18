---@class CronJob
---@field h number
---@field m number
---@field cb function|table

---@type CronJob[]
local cronJobs = {}
---@type number|false
local lastTimestamp = false

---@param h number
---@param m number
---@param cb function|table
function RunAt(h, m, cb)
    cronJobs[#cronJobs + 1] = {
        h = h,
        m = m,
        cb = cb,
    }
end

---@return number
function GetUnixTimestamp()
    return os.time()
end

---@param timestamp number
function OnTime(timestamp)
    for i = 1, #cronJobs, 1 do
        local scheduledTimestamp = os.time({
            hour = cronJobs[i].h,
            min = cronJobs[i].m,
            sec = 0, -- Assuming tasks run at the start of the minute
            day = os.date("%d", timestamp),
            month = os.date("%m", timestamp),
            year = os.date("%Y", timestamp),
        })

        if timestamp >= scheduledTimestamp and (not lastTimestamp or lastTimestamp < scheduledTimestamp) then
            local d = os.date('*t', scheduledTimestamp).wday
            cronJobs[i].cb(d, cronJobs[i].h, cronJobs[i].m)
        end
    end
end

---@return nil
function Tick()
    local timestamp = GetUnixTimestamp()

    if not lastTimestamp or os.date("%M", timestamp) ~= os.date("%M", lastTimestamp) then
        OnTime(timestamp)
        lastTimestamp = timestamp
    end

    SetTimeout(60000, Tick)
end

lastTimestamp = GetUnixTimestamp()
Tick()

---@param h number
---@param m number
---@param cb function|table
AddEventHandler("cron:runAt", function(h, m, cb)
    local invokingResource = GetInvokingResource() or "Unknown"
    local typeH = type(h)
    local typeM = type(m)
    local typeCb = type(cb)

    assert(typeH == "number", ("Expected number for h, got %s. Invoking Resource: '%s'"):format(typeH, invokingResource))
    assert(typeM == "number", ("Expected number for m, got %s. Invoking Resource: '%s'"):format(typeM, invokingResource))
    assert(typeCb == "function" or (typeCb == "table" and type(getmetatable(cb)?.__call) == "function"), ("Expected function for cb, got %s. Invoking Resource: '%s'"):format(typeCb, invokingResource))

    RunAt(h, m, cb)
end)
