---@class CronJob
---@field h number Hour (0-23)
---@field m number Minute (0-59)
---@field cb function|table Callback function to execute
---@field lastRun number|nil Timestamp of last execution (prevents duplicates)

---@type CronJob[]
local cronJobs = {}

---@type number|false
local lastTimestamp = false

---Registers a new cron job to run at specified time daily
---@param h number Hour (0-23)
---@param m number Minute (0-59)
---@param cb function|table Callback function to execute
function RunAt(h, m, cb)
    cronJobs[#cronJobs + 1] = {
        h = h,
        m = m,
        cb = cb,
        lastRun = nil
    }
end

---Gets current Unix timestamp
---@return number Current timestamp
function GetUnixTimestamp()
    return os.time()
end

---Checks and executes due cron jobs for the current timestamp
---@param timestamp number Current Unix timestamp
function OnTime(timestamp)
    for i = 1, #cronJobs, 1 do
        -- Calculate today's scheduled timestamp for this job
        local scheduledTimestamp = os.time({
            hour = cronJobs[i].h,
            min = cronJobs[i].m,
            sec = 0，
            day = os.date("%d", timestamp),
            month = os.date("%m", timestamp),
            year = os.date("%Y", timestamp),
        })

        -- Execute if current time >= scheduled time and hasn't run today
        if timestamp >= scheduledTimestamp and (not cronJobs[i].lastRun or cronJobs[i].lastRun < scheduledTimestamp) then
            local dayOfWeek = os.date('*t', scheduledTimestamp).wday

            -- Execute the callback with day, hour, minute parameters
            cronJobs[i].cb(dayOfWeek, cronJobs[i].h, cronJobs[i].m)

            -- Mark this job as executed for today
            cronJobs[i].lastRun = scheduledTimestamp
        end
    end
end

---Main tick function that checks for minute changes and processes jobs
---Automatically reschedules itself for precise minute-boundary timing
function Tick()
    local timestamp = GetUnixTimestamp()

    -- Only process jobs when minute changes to avoid duplicate checks
    if not lastTimestamp or os.date("%M", timestamp) ~= os.date("%M", lastTimestamp) then
        OnTime(timestamp)
        lastTimestamp = timestamp
    end

    -- Schedule next check at the start of the next minute for precision
    local currentSeconds = tonumber(os.date("%S", timestamp))
    local msToNextMinute = (60 - currentSeconds) * 1000
    SetTimeout(msToNextMinute, Tick)
end

lastTimestamp = GetUnixTimestamp()
Tick()

---Event handler for external resources to register cron jobs
---Usage: TriggerEvent('cron:runAt', hour, minute, callback)
AddEventHandler("cron:runAt", function(h, m, cb)
    local invokingResource = GetInvokingResource() or "Unknown"

    -- Validate parameters with detailed error messages
    local typeH = type(h)
    local typeM = type(m)
    local typeCb = type(cb)

    assert(typeH == "number", ("Expected number for hour, got %s. Invoking Resource: '%s'"):format(typeH, invokingResource))
    assert(typeM == "number", ("Expected number for minute, got %s. Invoking Resource: '%s'"):format(typeM, invokingResource))
    assert(typeCb == "function" or (typeCb == "table" and type(getmetatable(cb)?.__call) == "function"), ("Expected function for callback, got %s. Invoking Resource: '%s'"):format(typeCb, invokingResource))

    -- Validate time ranges
    assert(h >= 0 and h <= 23, ("Hour must be between 0-23, got %d. Invoking Resource: '%s'"):format(h, invokingResource))
    assert(m >= 0 and m <= 59, ("Minute must be between 0-59, got %d. Invoking Resource: '%s'"):format(m, invokingResource))

    RunAt(h, m, cb)
end)
